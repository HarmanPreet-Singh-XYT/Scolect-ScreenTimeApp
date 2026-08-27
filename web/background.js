// ─── Scolect Background Service Worker ───────────────────────────────────────
// Tracks active tab's domain, stores seconds in chrome.storage.local.
// Runs in Standalone, Tracker-Only, and Hybrid modes.

const STORAGE_PREFIX    = 'scolect_';
const ALARM_TICK        = 'scolect_tick';
const FLUTTER_PORT      = 46000;
const TICK_PERIOD       = 1; // minutes (Chrome enforces ≥1 min for published extensions)
const WS_URL            = `ws://localhost:${FLUTTER_PORT}/ws`;

// ─── Browser identity ─────────────────────────────────────────────────────────
// A UUID generated once on first run and persisted forever in chrome.storage.local
// so the desktop app can tell apart usage synced from different browsers/profiles.
// Never regenerated once set — this is the whole point of the identifier.

const BROWSER_ID_KEY = `${STORAGE_PREFIX}browser_id`;
let _browserId = null;

async function getBrowserId() {
  if (_browserId) return _browserId;
  const result = await chrome.storage.local.get(BROWSER_ID_KEY);
  if (result[BROWSER_ID_KEY]) {
    _browserId = result[BROWSER_ID_KEY];
    return _browserId;
  }
  _browserId = crypto.randomUUID();
  await chrome.storage.local.set({ [BROWSER_ID_KEY]: _browserId });
  return _browserId;
}

// Best-effort browser family detection from the extension's own user agent.
// Order matters: Edge/Opera/Brave UAs also contain "Chrome", so check them first.
function detectBrowserName() {
  const ua = navigator.userAgent || '';
  if (ua.includes('Edg/')) return 'Edge';
  if (ua.includes('OPR/') || ua.includes('Opera')) return 'Opera';
  if (navigator.brave) return 'Brave';
  if (ua.includes('Firefox/')) return 'Firefox';
  if (ua.includes('Chrome/')) return 'Chrome';
  if (ua.includes('Safari/')) return 'Safari';
  return 'Unknown';
}

// ─── WebSocket state ──────────────────────────────────────────────────────────
// MV3 service workers can be killed at any time; _ws is reconnected on demand
// inside tick() and refreshBlockedDomains(). On localhost a reconnect is <1ms.

let _ws = null;
// Last focus_state pushed by the desktop; used as a cache when the SW restarts
// so refreshBlockedDomains() can apply the last known state without a network call.
let _pendingFocusState = null;

// ─── Idle detection state ─────────────────────────────────────────────────────
// True while the system is idle or locked — tick() skips time accumulation.
let _isIdle = false;
// Resolves once the first queryState() callback fires after SW (re)start.
// tick() awaits this before deciding whether to accumulate time.
let _idleReady = false;
let _idleReadyResolve = null;
const _idleReadyPromise = new Promise(resolve => { _idleReadyResolve = resolve; });

function getWs() {
  if (_ws && (_ws.readyState === WebSocket.OPEN || _ws.readyState === WebSocket.CONNECTING)) {
    return _ws;
  }
  _ws = new WebSocket(WS_URL);
  _ws.onmessage = handleDesktopMessage;
  _ws.onerror   = () => { _ws = null; };
  _ws.onclose   = () => { _ws = null; };
  // A fresh open means the desktop just became reachable — either it just
  // started, or this is the first connection attempt since the service
  // worker woke up. Either way, push current usage immediately instead of
  // waiting for the next 1-minute alarm tick, and register this browser's
  // identity so it shows up in the desktop's browser list even before any
  // usage has been recorded today.
  _ws.addEventListener('open', async () => {
    try {
      const browserId = await getBrowserId();
      await _sendWhenOpen(_ws, { type: 'register', browserId, browserName: detectBrowserName() });
    } catch (e) { console.warn('Browser registration send failed:', e); }
    tick().catch(console.error);
  }, { once: true });
  return _ws;
}

// Send payload over WebSocket, waiting for the socket to open if still CONNECTING.
// Returns a Promise; rejects if the desktop is not running or the socket errors.
function _sendWhenOpen(ws, payload) {
  const str = typeof payload === 'string' ? payload : JSON.stringify(payload);
  return new Promise((resolve, reject) => {
    if (ws.readyState === WebSocket.OPEN) {
      try { ws.send(str); resolve(); } catch (e) { reject(e); }
      return;
    }
    if (ws.readyState !== WebSocket.CONNECTING) {
      reject(new Error('WebSocket not connectable'));
      return;
    }
    const timeout = setTimeout(() => reject(new Error('WS open timeout')), 5000);
    ws.addEventListener('open', () => {
      clearTimeout(timeout);
      try { ws.send(str); resolve(); } catch (e) { reject(e); }
    }, { once: true });
    ws.addEventListener('error', () => {
      clearTimeout(timeout);
      reject(new Error('WS error before open'));
    }, { once: true });
  });
}

// ─── Handle messages pushed from the desktop ──────────────────────────────────

function handleDesktopMessage(event) {
  let msg;
  try { msg = JSON.parse(event.data); } catch { return; }
  if (msg.type === 'focus_state') {
    _pendingFocusState = msg;
    _applyFocusState(msg).catch(console.error);
  }
}

async function _applyFocusState(focusJson) {
  const unblockedToday = await getUnblockedToday();
  let blocked = focusJson.blockedDomains || [];

  // Merge domainLimits from desktop into scolect_settings.metadata.
  // Extension values always win; desktop only fills gaps.
  if (focusJson.domainLimits) {
    const currentSettings = await getSettings();
    const currentMeta = currentSettings.metadata ?? {};
    let changed = false;

    for (const [domain, desktopMeta] of Object.entries(focusJson.domainLimits)) {
      // A domain the extension has never recorded metadata for yet (first
      // time seeing it, e.g. desktop synced it before the extension did)
      // has no opinion — take the desktop's values to fill the gap. Once the
      // extension has its own entry, it is authoritative for every field,
      // including "no limit" (0) — a 0 is a real, explicit user choice, not
      // an absence of one, so it must not be overridden by a stale desktop
      // value on the next merge.
      const hasExtEntry = currentMeta[domain] !== undefined;
      const ext = currentMeta[domain] ?? {};
      const merged = {
        category:          hasExtEntry ? (ext.category ?? 'Uncategorized') : (desktopMeta.category || 'Uncategorized'),
        isTracking:        hasExtEntry ? (ext.isTracking ?? true) : (desktopMeta.isTracking ?? true),
        isProductive:      hasExtEntry ? (ext.isProductive ?? false) : (desktopMeta.isProductive ?? false),
        dailyLimitSeconds: hasExtEntry ? (ext.dailyLimitSeconds ?? 0) : (desktopMeta.dailyLimitSeconds ?? 0),
        // siteName is always sourced from the browser (scolect_app_metadata via
        // updateSiteName). Never import it from the desktop — desktop may have
        // stale or wrong titles accumulated from earlier sessions.
        siteName: ext.siteName || '',
      };
      if (JSON.stringify(ext) !== JSON.stringify(merged)) {
        currentMeta[domain] = { ...ext, ...merged };
        changed = true;
      }
    }

    if (changed) {
      await chrome.storage.local.set({
        'scolect_settings': { ...currentSettings, metadata: currentMeta },
      });
      // Recompute blocked from the freshly merged metadata so limits set on
      // desktop are enforced immediately without waiting for the next alarm.
      const mergedSettings = await getSettings();
      const today2 = getTodayKey();
      const day2 = await getDayData(today2);
      for (const entry of day2.domains) {
        const m = mergedSettings.metadata?.[entry.domain];
        if (m && m.dailyLimitSeconds > 0 && entry.seconds >= m.dailyLimitSeconds) {
          if (!blocked.includes(entry.domain)) blocked.push(entry.domain);
        }
      }
    }
  }

  // Mark desktop as connected + persist live focus session state for popup
  const stateKey = `${STORAGE_PREFIX}app_state`;
  const existing = await chrome.storage.local.get(stateKey);
  const prev = existing[stateKey] ?? {};
  await chrome.storage.local.set({
    [stateKey]: {
      ...prev,
      appConnected:   true,
      lastSyncAt:     Date.now(),
      focusActive:    focusJson.active    ?? false,
      sessionLabel:   focusJson.sessionLabel  ?? null,
      endTimeEpochMs: focusJson.endTimeEpochMs ?? null,
    },
    [`${STORAGE_PREFIX}ever_connected`]: true,
  });

  // Apply blocked set (excluding manually unblocked domains)
  _blockedDomains = new Set(blocked.filter(d => !unblockedToday.has(d)));
  for (const domain of _blockedDomains) {
    await _showBlockOverlayOnTabs(domain);
  }
}

// ─── Blocked domains & limit notifications ────────────────────────────────────

let _blockedDomains = new Set();

let _warned90 = new Set();
let _warned90Date = '';
let _overallLimitWarned = false;
let _overallLimitWarnedDate = '';

function _resetWarningsIfNewDay() {
  const today = getTodayKey();
  if (_warned90Date !== today) {
    _warned90 = new Set();
    _warned90Date = today;
  }
  if (_overallLimitWarnedDate !== today) {
    _overallLimitWarned = false;
    _overallLimitWarnedDate = today;
  }
}

function _showNotification(id, title, message) {
  chrome.notifications.create(id, {
    type: 'basic',
    iconUrl: 'icons/Icon-192.png',
    title,
    message,
    priority: 1,
  });
}

async function _buildOverlayPayload(domain) {
  const all = await chrome.storage.local.get(null);
  const settings = all.scolect_settings || {};
  const metadata = settings.metadata || {};
  const appMeta = all.scolect_app_metadata || {};

  const cleanDomain = domain.replace(/^www\./, '').toLowerCase();
  const meta = metadata[domain] || metadata['www.' + cleanDomain] || metadata[cleanDomain];
  const siteName = meta?.siteName || appMeta[domain]?.siteName || appMeta[cleanDomain]?.siteName || domain;
  const limitSecs = meta?.dailyLimitSeconds || 0;

  const todayStr = (() => {
    const d = new Date();
    return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
  })();

  const matchDomain = (d) => d && d.replace(/^www\./, '').toLowerCase() === cleanDomain;
  let entry = null;
  const todayData = all[`scolect_day_${todayStr}`];
  if (todayData?.domains) entry = todayData.domains.find(d => matchDomain(d.domain));
  if (!entry) {
    const dayKeys = Object.keys(all).filter(k => k.startsWith('scolect_day_')).sort().reverse();
    for (const dk of dayKeys) {
      const dayObj = all[dk];
      if (dayObj?.domains) { entry = dayObj.domains.find(d => matchDomain(d.domain)); if (entry) break; }
    }
  }

  const themeColors = all.scolect_theme_colors || null;
  const themeId = all.scolect_theme_id || null;
  const strings = all.scolect_overlay_strings || null;

  return {
    domain,
    siteName,
    spentSecs: entry?.seconds || 0,
    limitSecs,
    visits: entry?.visits || 0,
    themeColors,
    themeId,
    strings,
  };
}

async function _showBlockOverlayOnTabs(domain) {
  try {
    const payload = await _buildOverlayPayload(domain);
    const tabs = await chrome.tabs.query({});
    for (const tab of tabs) {
      if (
        tab.url &&
        !tab.url.startsWith(chrome.runtime.getURL('')) &&
        !tab.url.startsWith('chrome-extension://') &&
        !tab.url.startsWith('moz-extension://')
      ) {
        const d = extractDomain(tab.url);
        if (d === domain) {
          chrome.tabs.sendMessage(tab.id, { type: 'SHOW_BLOCK_OVERLAY', ...payload }).catch(() => {});
        }
      }
    }
  } catch (e) {
    console.error('Error showing block overlay for domain:', domain, e);
  }
}

async function checkLimitNotifications(domain, totalSeconds) {
  _resetWarningsIfNewDay();
  const settings = await getSettings();
  const meta = settings.metadata?.[domain];
  if (!meta?.dailyLimitSeconds || meta.dailyLimitSeconds <= 0) return;

  const limit = meta.dailyLimitSeconds;
  const ratio = totalSeconds / limit;
  const siteName = meta.siteName || domain;

  if (ratio >= 0.9 && ratio < 1.0 && !_warned90.has(domain)) {
    _warned90.add(domain);
    const remaining = Math.ceil((limit - totalSeconds) / 60);
    _showNotification(
      `scolect_warn_${domain}`,
      'Time limit approaching',
      `${siteName} — ${remaining} min left of your daily limit.`,
    );
  }

  if (ratio >= 1.0 && !_blockedDomains.has(domain)) {
    const unblockedToday = await getUnblockedToday();
    if (!unblockedToday.has(domain)) {
      _blockedDomains.add(domain);
      const bKey = `${STORAGE_PREFIX}blocked_domains`;
      const bResult = await chrome.storage.local.get([bKey]);
      const bList = bResult[bKey] || [];
      if (!bList.includes(domain)) {
        await chrome.storage.local.set({ [bKey]: [...bList, domain] });
      }
      _showNotification(
        `scolect_blocked_${domain}`,
        'Daily limit reached',
        `${siteName} has been blocked for today.`,
      );
      await _showBlockOverlayOnTabs(domain);
    }
  }
}

const IGNORED_DOMAINS = new Set([
  '', 'newtab', 'extensions', 'settings', 'history',
  'localhost', '127.0.0.1', 'chrome', 'about',
]);

// ─── Overall screen time limit ────────────────────────────────────────────────
// Checks total usage across all tracked domains against the overall daily limit.
// When exceeded, blocks every tracked domain for the rest of the day.

async function checkOverallLimitNotifications(totalSeconds, settings) {
  _resetWarningsIfNewDay();
  const limit = settings.overallLimitSeconds;
  if (!settings.overallLimitEnabled || !limit || limit <= 0) return;

  const ratio = totalSeconds / limit;

  if (ratio >= 0.9 && ratio < 1.0 && !_overallLimitWarned) {
    _overallLimitWarned = true;
    const remaining = Math.ceil((limit - totalSeconds) / 60);
    _showNotification(
      'scolect_warn_overall',
      'Daily screen time limit approaching',
      `${remaining} min left of your daily overall screen time limit.`,
    );
  }

  if (ratio >= 1.0) {
    await _enforceOverallLimit(settings);
  }
}

async function _enforceOverallLimit(settings) {
  const unblockedToday = await getUnblockedToday();
  const today = getTodayKey();
  const day = await getDayData(today);

  // Collect all domains tracked today that aren't manually unblocked.
  const domainsToBlock = day.domains
    .map(e => e.domain)
    .filter(d => !IGNORED_DOMAINS.has(d) && !unblockedToday.has(d));

  let changed = false;
  const bKey = `${STORAGE_PREFIX}blocked_domains`;
  const bResult = await chrome.storage.local.get([bKey]);
  const bList = new Set(bResult[bKey] || []);

  for (const domain of domainsToBlock) {
    if (!_blockedDomains.has(domain)) {
      _blockedDomains.add(domain);
      changed = true;
    }
    if (!bList.has(domain)) {
      bList.add(domain);
      changed = true;
    }
  }

  if (changed) {
    await chrome.storage.local.set({ [bKey]: [...bList] });
    _showNotification(
      'scolect_blocked_overall',
      'Daily screen time limit reached',
      'All websites have been blocked for today.',
    );
    for (const domain of domainsToBlock) {
      await _showBlockOverlayOnTabs(domain);
    }
  }
}

// ─── Date helpers ─────────────────────────────────────────────────────────────

function getTodayKey() {
  const d = new Date();
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

function extractDomain(url) {
  try {
    const u = new URL(url);
    if (!u.hostname) return null;
    return u.hostname.replace(/^www\./, '').toLowerCase();
  } catch {
    return null;
  }
}

// ─── Storage helpers ──────────────────────────────────────────────────────────

async function getDayData(dateKey) {
  const storageKey = `${STORAGE_PREFIX}day_${dateKey}`;
  const result = await chrome.storage.local.get(storageKey);
  return result[storageKey] ?? { date: dateKey, domains: [] };
}

async function setDayData(dateKey, data) {
  const storageKey = `${STORAGE_PREFIX}day_${dateKey}`;
  await chrome.storage.local.set({ [storageKey]: data });
}

function _getBaseName(domain) {
  const parts = domain.replace(/^www\./, '').split('.');
  return parts.length > 1 ? parts[parts.length - 2] : domain;
}

function _getCleanSiteName(domain, rawTitle) {
  const baseName = _getBaseName(domain);
  const fallback = baseName.charAt(0).toUpperCase() + baseName.slice(1);

  if (!rawTitle) return fallback;

  let cleaned = rawTitle
    .replace(/^\(\d+\)\s*/, '')
    .replace(/^\[\d+\]\s*/, '')
    .replace(/^[•★]\s*/, '')
    .trim();

  const titleParts = cleaned.split(/\s*[\-\|:—–\/]\s*/).filter(p => p.length > 0);

  const exactMatch = titleParts.find(p => p.toLowerCase() === baseName.toLowerCase());
  if (exactMatch) return exactMatch;

  const containsMatch = titleParts.find(p => p.toLowerCase().includes(baseName.toLowerCase()));
  if (containsMatch && containsMatch.length <= 30) return containsMatch;

  return fallback;
}

async function updateSiteName(domain, rawTitle) {
  if (!rawTitle) return;

  const cleanName = _getCleanSiteName(domain, rawTitle);
  if (!cleanName || cleanName.toLowerCase() === domain) return;

  const key = `${STORAGE_PREFIX}app_metadata`;
  const result = await chrome.storage.local.get(key);
  const meta = result[key] ?? {};

  const currentSaved = meta[domain]?.siteName;
  if (currentSaved !== cleanName) {
    meta[domain] = { ...(meta[domain] ?? {}), siteName: cleanName };
    await chrome.storage.local.set({ [key]: meta });
  }
}

async function updateDomain(dateKey, domain, deltaSeconds, deltaVisits) {
  domain = domain.replace(/^www\./, '').toLowerCase();
  const day = await getDayData(dateKey);
  const idx = day.domains.findIndex(d => d.domain === domain);
  const now = Date.now();
  if (idx >= 0) {
    day.domains[idx].seconds += deltaSeconds;
    day.domains[idx].visits  += deltaVisits;
    day.domains[idx].lastSeen = now;
  } else {
    day.domains.push({ domain, seconds: deltaSeconds, visits: deltaVisits, lastSeen: now });
  }
  await setDayData(dateKey, day);
}

async function getSettings() {
  const result = await chrome.storage.local.get(`${STORAGE_PREFIX}settings`);
  return result[`${STORAGE_PREFIX}settings`] ?? { mode: 'standalone', desktopUrl: `http://localhost:${FLUTTER_PORT}`, metadata: {} };
}

async function getActive() {
  const result = await chrome.storage.local.get(`${STORAGE_PREFIX}active`);
  return result[`${STORAGE_PREFIX}active`] ?? null;
}

async function setActive(entry) {
  await chrome.storage.local.set({ [`${STORAGE_PREFIX}active`]: entry });
}

// ─── Tracking logic ───────────────────────────────────────────────────────────

// Last domain that was paused and the timestamp of the pause.
// Used to detect brief focus interruptions (e.g. macOS Space transition when
// going fullscreen) so we don't count a resume as a new visit.
let _lastPausedDomain = null;
let _lastPausedAt = 0;
const RESUME_DEBOUNCE_MS = 3000; // treat same-domain refocus within 3s as a resume

async function startTracking(url, title) {
  if (url && (url.startsWith('chrome-extension://') || url.startsWith('moz-extension://'))) {
    await setActive(null);
    return;
  }
  const domain = extractDomain(url);
  if (!domain || IGNORED_DOMAINS.has(domain)) {
    await setActive(null);
    return;
  }
  const today = getTodayKey();
  const current = await getActive();
  if (current?.domain === domain) {
    // Still on the same site — update name but don't record a new visit.
    await updateSiteName(domain, title);
    return;
  }
  // Flush pending seconds for the site we're leaving.
  if (current && current.pendingSeconds > 0) {
    await updateDomain(today, current.domain, current.pendingSeconds, 0);
  }
  const nowMs = Date.now();
  await setActive({ domain, startedAt: nowMs, lastTickAt: nowMs, pendingSeconds: 0, date: today });

  // Only count a new visit if this isn't a quick resume after a brief focus gap
  // (e.g. macOS Space transition when going fullscreen pauses then immediately resumes).
  const isResume = domain === _lastPausedDomain && (nowMs - _lastPausedAt) < RESUME_DEBOUNCE_MS;
  if (!isResume) {
    await updateDomain(today, domain, 0, 1);
  }
  _lastPausedDomain = null;
  await updateSiteName(domain, title);
}

async function pauseTracking() {
  const current = await getActive();
  if (!current) return;
  if (current.pendingSeconds > 0) {
    await updateDomain(getTodayKey(), current.domain, current.pendingSeconds, 0);
  }
  // Remember which domain was paused so startTracking() can detect a quick resume.
  _lastPausedDomain = current.domain;
  _lastPausedAt = Date.now();
  await setActive(null);
}

async function tick() {
  const settings = await getSettings();

  // Local focus timer runs regardless of whether a tab is being tracked.
  if (settings.mode === 'standalone') {
    await _tickLocalFocus();
  }

  // Wait for the post-restart queryState() to complete before trusting _isIdle.
  // Without this, a SW restart resets _isIdle to false and tick() would credit
  // time during the async window before queryState() fires its callback.
  // The 2s timeout is a safety fallback in case setupIdleDetection() fails to
  // resolve the promise (e.g., chrome.idle API unavailable or settings read error).
  await Promise.race([
    _idleReadyPromise,
    new Promise(r => setTimeout(r, 2000)),
  ]);

  // ── Active idle state check on every tick ──────────────────────────────────
  if (settings.idleDetection) {
    const threshold = Math.max(
      IDLE_THRESHOLD_MIN,
      settings.idleTimeoutSeconds ?? IDLE_THRESHOLD_DEFAULT,
    );
    const systemState = await new Promise(resolve => {
      chrome.idle.queryState(threshold, resolve);
    });

    if (systemState === 'active') {
      _isIdle = false;
    } else {
      // System is idle or locked — check if media playback bypass is active
      const ignoreOnMedia = settings.ignoreIdleOnMedia ?? true;
      const mediaPlaying = ignoreOnMedia ? await _isMediaPlayingInActiveTab() : false;
      if (mediaPlaying) {
        _isIdle = false;
      } else {
        _isIdle = true;
        await pauseTracking();
        await refreshAppState();
        return;
      }
    }
  } else {
    _isIdle = false;
  }

  let current = await getActive();
  if (!current && !_isIdle) {
    let tabs = await chrome.tabs.query({ active: true, lastFocusedWindow: true });
    if (!tabs[0]) tabs = await chrome.tabs.query({ active: true, currentWindow: true });
    if (!tabs[0]) tabs = await chrome.tabs.query({ active: true });
    if (tabs[0]?.url) {
      await startTracking(tabs[0].url, tabs[0].title);
      current = await getActive();
    }
  }

  if (!current) {
    await refreshAppState();
    return;
  }

  const today = getTodayKey();
  if (current.date && current.date !== today) {
    // Day rolled over — flush yesterday's pending seconds and reset day-scoped state.
    await updateDomain(current.date, current.domain, current.pendingSeconds, 0);
    current.pendingSeconds = 0;
    current.date = today;
    // Clear blocked domains list so yesterday's limits don't carry over.
    await chrome.storage.local.set({ [`${STORAGE_PREFIX}blocked_domains`]: [] });
    _blockedDomains = new Set();
    _warned90 = new Set();
    _overallLimitWarned = false;
  }

  // Compute elapsed seconds since startedAt to handle any alarm period accurately.
  // Chrome enforces periodInMinutes ≥ 1 for published extensions, so tick() fires
  // once per minute rather than every second. Using wall-clock elapsed time means
  // we accumulate the correct number of seconds regardless of how often tick() fires.
  const now = Date.now();
  const lastTick = current.lastTickAt ?? current.startedAt ?? now;
  const elapsedSecs = Math.round((now - lastTick) / 1000);
  const delta = Math.max(1, Math.min(elapsedSecs, 120)); // clamp: at least 1s, at most 2min

  current.pendingSeconds = (current.pendingSeconds || 0) + delta;
  current.lastTickAt = now;

  await updateDomain(today, current.domain, current.pendingSeconds, 0);
  current.pendingSeconds = 0;

  const day = await getDayData(today);
  const domainEntry = day.domains.find(d => d.domain === current.domain);
  if (domainEntry) {
    await checkLimitNotifications(current.domain, domainEntry.seconds);
  }

  // Check overall daily limit against total usage across all domains.
  const totalSecondsToday = day.domains.reduce((s, e) => s + e.seconds, 0);
  await checkOverallLimitNotifications(totalSecondsToday, settings);

  // Push usage to desktop over WebSocket.
  if (settings.mode !== 'standalone') {
    runSync().catch(console.error);
  }

  await setActive({ ...current, date: today });

  await refreshAppState();
}

// ─── App state (used by popup) ────────────────────────────────────────────────

async function refreshAppState() {
  const today = getTodayKey();
  const day = await getDayData(today);
  const active = await getActive();
  const settings = await getSettings();
  const existing = await chrome.storage.local.get(`${STORAGE_PREFIX}app_state`);
  const prev = existing[`${STORAGE_PREFIX}app_state`] ?? {};

  const metaKey = `${STORAGE_PREFIX}app_metadata`;
  const metaResult = await chrome.storage.local.get(metaKey);
  const siteMeta = metaResult[metaKey] ?? {};

  const domains = [...day.domains]
    .sort((a, b) => b.seconds - a.seconds)
    .map(d => ({
      ...d,
      siteName: siteMeta[d.domain]?.siteName || '',
    }));

  // Preserve or recompute focus state depending on mode.
  let focusPatch = {};
  if (settings.mode === 'standalone') {
    // Standalone: derive focus state from the local timer.
    const lf = await getLocalFocus();
    const now = Date.now();
    const isRunning = lf.running && lf.endMs != null && lf.endMs > now;
    focusPatch = {
      focusActive:    isRunning,
      sessionLabel:   isRunning ? LOCAL_FOCUS_LABELS[lf.phase] : null,
      endTimeEpochMs: isRunning ? lf.endMs : null,
    };
  } else {
    // Hybrid / Tracker-Only: focus state is pushed by the desktop via _applyFocusState.
    // Preserve whatever was last written so tick() doesn't erase it every second.
    focusPatch = {
      focusActive:    prev.focusActive    ?? false,
      sessionLabel:   prev.sessionLabel   ?? null,
      endTimeEpochMs: prev.endTimeEpochMs ?? null,
    };
  }

  await chrome.storage.local.set({
    [`${STORAGE_PREFIX}app_state`]: {
      todayDomains: domains,
      activeDomain: active?.domain ?? null,
      totalSeconds: domains.reduce((s, d) => s + d.seconds, 0),
      mode: settings.mode,
      appConnected: prev.appConnected ?? false,
      lastSyncAt: prev.lastSyncAt ?? null,
      ...focusPatch,
    }
  });
}

// ─── Blocked domains refresh ──────────────────────────────────────────────────

async function getUnblockedToday() {
  const today = new Date().toDateString();
  const result = await chrome.storage.local.get(['scolect_unblocked_today']);
  const map = result['scolect_unblocked_today'] || {};
  return new Set(Object.entries(map).filter(([, d]) => d === today).map(([k]) => k));
}

async function refreshBlockedDomains() {
  const settings = await getSettings();
  const mode = settings.mode || 'standalone';
  const unblockedToday = await getUnblockedToday();

  let blocked = [];

  if (mode === 'standalone') {
    // Authoritative computation from local settings + today's usage — no network.
    const today = getTodayKey();
    const day = await getDayData(today);
    const meta = settings.metadata ?? {};
    const totalSeconds = day.domains.reduce((s, e) => s + e.seconds, 0);

    // Check per-domain limits.
    for (const entry of day.domains) {
      const m = meta[entry.domain];
      if (m && m.dailyLimitSeconds > 0 && entry.seconds >= m.dailyLimitSeconds) {
        blocked.push(entry.domain);
      }
    }

    // Check overall daily limit — if exceeded, block all tracked domains.
    if (settings.overallLimitEnabled && settings.overallLimitSeconds > 0
        && totalSeconds >= settings.overallLimitSeconds) {
      const overallBlocked = day.domains
        .map(e => e.domain)
        .filter(d => !IGNORED_DOMAINS.has(d));
      for (const d of overallBlocked) {
        if (!blocked.includes(d)) blocked.push(d);
      }
    }

    await chrome.storage.local.set({ [`${STORAGE_PREFIX}blocked_domains`]: blocked });

  } else {
    // Hybrid / Tracker-Only: focus_state is pushed over WebSocket by the desktop.
    // Ensure the WS connection is being established (getWs() is idempotent).
    getWs();

    if (_pendingFocusState) {
      // Desktop already pushed state this SW session — apply it.
      await _applyFocusState(_pendingFocusState);
      // Re-read blocked after _applyFocusState wrote it.
      const bResult = await chrome.storage.local.get(`${STORAGE_PREFIX}blocked_domains`);
      blocked = bResult[`${STORAGE_PREFIX}blocked_domains`] || [];
    } else {
      // No pushed state yet (e.g., SW just restarted). Fall back to local
      // computation so blocking is enforced immediately, even without a desktop push.
      const today = getTodayKey();
      const day = await getDayData(today);
      const meta = settings.metadata ?? {};
      for (const entry of day.domains) {
        const m = meta[entry.domain];
        if (m && m.dailyLimitSeconds > 0 && entry.seconds >= m.dailyLimitSeconds) {
          blocked.push(entry.domain);
        }
      }
    }
  }

  _blockedDomains = new Set(blocked.filter(d => !unblockedToday.has(d)));
  for (const domain of _blockedDomains) {
    await _showBlockOverlayOnTabs(domain);
  }
}

// ─── Local focus timer (standalone mode) ─────────────────────────────────────
// Stored in scolect_local_focus: { phase, startMs, endMs, pausedSecsLeft, running }
// phase: 'work' | 'shortBreak' | 'longBreak'

const LOCAL_FOCUS_KEY = 'scolect_local_focus';
const LOCAL_FOCUS_DURATIONS = { work: 25 * 60, shortBreak: 5 * 60, longBreak: 15 * 60 };
const LOCAL_FOCUS_LABELS    = { work: 'Work Session', shortBreak: 'Short Break', longBreak: 'Long Break' };

async function getLocalFocus() {
  const r = await chrome.storage.local.get(LOCAL_FOCUS_KEY);
  return r[LOCAL_FOCUS_KEY] ?? { phase: 'work', running: false, pausedSecsLeft: null, startMs: null, endMs: null };
}

async function setLocalFocus(state) {
  await chrome.storage.local.set({ [LOCAL_FOCUS_KEY]: state });
}

async function _saveLocalSession(phase, durationSecs, completed) {
  const r = await chrome.storage.local.get('scolect_focus_sessions');
  const sessions = r['scolect_focus_sessions'] ?? [];
  sessions.push({
    startTime: new Date(Date.now() - durationSecs * 1000).toISOString(),
    duration: durationSecs,
    completed,
    appsBlocked: [],
  });
  await chrome.storage.local.set({ 'scolect_focus_sessions': sessions });
}

async function localFocusControl(action) {
  const f = await getLocalFocus();
  const now = Date.now();

  if (action === 'start') {
    const total = LOCAL_FOCUS_DURATIONS[f.phase] * 1000;
    await setLocalFocus({ ...f, running: true, startMs: now, endMs: now + total, pausedSecsLeft: null });

  } else if (action === 'pause' && f.running) {
    const secsLeft = Math.max(0, Math.round((f.endMs - now) / 1000));
    await setLocalFocus({ ...f, running: false, pausedSecsLeft: secsLeft, endMs: null });

  } else if (action === 'resume' && !f.running && f.pausedSecsLeft != null) {
    const endMs = now + f.pausedSecsLeft * 1000;
    await setLocalFocus({ ...f, running: true, endMs, pausedSecsLeft: null });

  } else if (action === 'reset') {
    if (f.running || f.pausedSecsLeft != null) {
      const total = LOCAL_FOCUS_DURATIONS[f.phase];
      const secsLeft = f.running ? Math.max(0, Math.round((f.endMs - now) / 1000)) : (f.pausedSecsLeft ?? total);
      const elapsed = total - secsLeft;
      if (elapsed > 5) await _saveLocalSession(f.phase, elapsed, false);
    }
    await setLocalFocus({ phase: f.phase, running: false, pausedSecsLeft: null, startMs: null, endMs: null });

  } else if (action === 'skip_forward') {
    if (f.running || f.pausedSecsLeft != null) {
      const total = LOCAL_FOCUS_DURATIONS[f.phase];
      const secsLeft = f.running ? Math.max(0, Math.round((f.endMs - now) / 1000)) : (f.pausedSecsLeft ?? total);
      await _saveLocalSession(f.phase, total - secsLeft, true);
    }
    const nextPhase = f.phase === 'work' ? 'shortBreak' : 'work';
    const total = LOCAL_FOCUS_DURATIONS[nextPhase] * 1000;
    await setLocalFocus({ phase: nextPhase, running: true, startMs: now, endMs: now + total, pausedSecsLeft: null });

  } else if (action === 'skip_backward') {
    const total = LOCAL_FOCUS_DURATIONS[f.phase] * 1000;
    await setLocalFocus({ ...f, running: true, startMs: now, endMs: now + total, pausedSecsLeft: null });

  } else if (action === 'phase_work' || action === 'phase_shortBreak' || action === 'phase_longBreak') {
    const phase = action.replace('phase_', '');
    const total = LOCAL_FOCUS_DURATIONS[phase] * 1000;
    await setLocalFocus({ phase, running: true, startMs: now, endMs: now + total, pausedSecsLeft: null });
  }
}

// Called from tick() to detect phase completion in standalone mode.
async function _tickLocalFocus() {
  const f = await getLocalFocus();
  if (!f.running || !f.endMs) return;
  if (Date.now() < f.endMs) return;

  const total = LOCAL_FOCUS_DURATIONS[f.phase];
  await _saveLocalSession(f.phase, total, true);
  _showNotification('focus_complete', 'Focus session complete', `${LOCAL_FOCUS_LABELS[f.phase]} finished!`);

  const nextPhase = f.phase === 'work' ? 'shortBreak' : 'work';
  await setLocalFocus({ phase: nextPhase, running: false, pausedSecsLeft: null, startMs: null, endMs: null });
}

// ─── Focus control — send a command to the desktop timer ─────────────────────
// Actions: 'start' | 'pause' | 'resume' | 'reset' | 'skip_forward' | 'skip_backward'

async function sendFocusControl(action) {
  const settings = await getSettings();
  if (settings.mode === 'standalone') {
    await localFocusControl(action);
    await refreshAppState();
    return;
  }
  try {
    const ws = getWs();
    await _sendWhenOpen(ws, { type: 'focus_control', action });
  } catch (e) {
    console.warn('Focus control send failed:', e);
  }
}

// ─── Desktop sync — send usage over WebSocket ─────────────────────────────────

async function runSync() {
  const settings = await getSettings();
  if (settings.mode === 'standalone') return;

  // If a previous clear-data attempt failed (desktop was offline), retry it now
  // before pushing any new usage — otherwise the desktop would receive fresh data
  // on top of the stale entries we intended to delete.
  const pendingClear = await chrome.storage.local.get(_PENDING_CLEAR_KEY);
  if (pendingClear[_PENDING_CLEAR_KEY]) {
    await _clearDesktopWebData();
    // If still pending (desktop still offline), skip the sync entirely so we
    // don't re-populate the very data we're trying to erase.
    const stillPending = await chrome.storage.local.get(_PENDING_CLEAR_KEY);
    if (stillPending[_PENDING_CLEAR_KEY]) return;
  }

  const today = getTodayKey();
  const day = await getDayData(today);
  if (day.domains.length === 0) return;

  const metaKey = `${STORAGE_PREFIX}app_metadata`;
  const metaResult = await chrome.storage.local.get(metaKey);
  const siteMeta = metaResult[metaKey] ?? {};
  const meta = settings.metadata ?? {};

  const payload = {
    type: 'usage',
    date: today,
    browserId: await getBrowserId(),
    browserName: detectBrowserName(),
    domains: day.domains.map(d => ({
      ...d,
      siteName:          siteMeta[d.domain]?.siteName    ?? meta[d.domain]?.siteName    ?? null,
      dailyLimitSeconds: meta[d.domain]?.dailyLimitSeconds ?? 0,
      isTracking:        meta[d.domain]?.isTracking        ?? true,
      isProductive:      meta[d.domain]?.isProductive      ?? false,
      category:          meta[d.domain]?.category          ?? '',
    })),
  };

  let connected = false;
  try {
    const ws = getWs();
    await _sendWhenOpen(ws, payload);
    connected = true;
  } catch {
    // WebSocket failed (service worker restarted, desktop not running, etc.).
    // Fall back to HTTP POST which works even without a persistent connection.
    try {
      const desktopUrl = settings.desktopUrl || `http://localhost:${FLUTTER_PORT}`;
      const resp = await fetch(`${desktopUrl}/usage`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      connected = resp.ok;
    } catch {
      connected = false;
    }
  }

  const stateKey = `${STORAGE_PREFIX}app_state`;
  const existing = await chrome.storage.local.get(stateKey);
  const prev = existing[stateKey] ?? {};
  const update = { [stateKey]: { ...prev, appConnected: connected, lastSyncAt: connected ? Date.now() : prev.lastSyncAt } };
  if (connected) update[`${STORAGE_PREFIX}ever_connected`] = true;
  await chrome.storage.local.set(update);
}

// ─── Alarms ───────────────────────────────────────────────────────────────────

chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === ALARM_TICK) tick().catch(console.error);
});

// ─── React instantly to limit changes saved from the Flutter dashboard ────────

chrome.storage.onChanged.addListener((changes, area) => {
  if (area !== 'local') return;
  if (changes['scolect_settings']) {
    refreshBlockedDomains().catch(console.error);
    setupIdleDetection().catch(console.error);
  }
  if (changes['scolect_clear_web_data']?.newValue === true) {
    chrome.storage.local.remove('scolect_clear_web_data');
    _clearDesktopWebData().catch(console.error);
  }
});

const _PENDING_CLEAR_KEY = 'scolect_pending_desktop_clear';

async function _clearDesktopWebData() {
  const settings = await getSettings();
  if (settings.mode === 'standalone') return;
  const desktopUrl = settings.desktopUrl || `http://localhost:${FLUTTER_PORT}`;
  try {
    const resp = await fetch(`${desktopUrl}/clear-web-data`, { method: 'POST' });
    if (resp.ok) {
      // Clear succeeded — remove the pending flag so we don't retry.
      await chrome.storage.local.remove(_PENDING_CLEAR_KEY);
    } else {
      // Desktop responded but with an error — keep the flag and retry later.
      await chrome.storage.local.set({ [_PENDING_CLEAR_KEY]: true });
    }
  } catch (e) {
    // Desktop is offline — persist the flag so runSync() retries before the
    // next usage push, preventing stale data from surviving on the desktop.
    await chrome.storage.local.set({ [_PENDING_CLEAR_KEY]: true });
    console.warn('Could not clear desktop web data (will retry on next sync):', e);
  }
}

function setupAlarms() {
  chrome.alarms.get(ALARM_TICK, a => {
    if (!a) chrome.alarms.create(ALARM_TICK, { periodInMinutes: TICK_PERIOD });
  });
}

// ─── Idle detection ───────────────────────────────────────────────────────────
// Uses chrome.idle API to pause time tracking when the user is away.
// The detection threshold is read from scolect_settings.idleTimeoutSeconds
// (set by the Flutter dashboard). Chrome requires a minimum of 15 seconds.

const IDLE_THRESHOLD_MIN = 15;
const IDLE_THRESHOLD_DEFAULT = 60;

async function setupIdleDetection() {
  const settings = await getSettings();
  if (!settings.idleDetection) {
    // Idle detection disabled — treat system as always active.
    _isIdle = false;
    if (!_idleReady) { _idleReady = true; _idleReadyResolve(); }
    return;
  }
  const threshold = Math.max(
    IDLE_THRESHOLD_MIN,
    settings.idleTimeoutSeconds ?? IDLE_THRESHOLD_DEFAULT,
  );
  chrome.idle.setDetectionInterval(threshold);

  // Query current idle state so that if the SW restarts while the user is away
  // we don't start counting time immediately. Resolves _idleReadyPromise so
  // tick() knows _isIdle is authoritative and not the default false.
  chrome.idle.queryState(threshold, async state => {
    _isIdle = state !== 'active';
    if (_isIdle) {
      const ignoreOnMedia = settings.ignoreIdleOnMedia ?? true;
      const mediaPlaying = ignoreOnMedia ? await _isMediaPlayingInActiveTab() : false;
      if (mediaPlaying) {
        _isIdle = false;
      } else {
        await pauseTracking().catch(console.error);
      }
    }
    if (!_idleReady) { _idleReady = true; _idleReadyResolve(); }
  });
}

// Returns true if the active tab is producing media (audio output or playing video/audio element).
// Used to skip idle-pause when the user is watching/listening hands-free (e.g. Netflix, Spotify, YouTube).
// Checks tab.audible first (no message needed), then falls back to DOM query via content script.
async function _isMediaPlayingInActiveTab() {
  try {
    let tabs = await chrome.tabs.query({ active: true, lastFocusedWindow: true });
    if (!tabs[0]) {
      tabs = await chrome.tabs.query({ active: true, currentWindow: true });
    }
    if (!tabs[0]) {
      tabs = await chrome.tabs.query({ active: true });
    }
    if (!tabs[0]) return false;

    // 1. Check if any active tab is producing audio (e.g. YouTube video with audio)
    const audibleTab = tabs.find(t => t.audible);
    if (audibleTab) return true;

    // 2. Also check if any tab across windows is audible
    const allAudible = await chrome.tabs.query({ audible: true });
    if (allAudible.length > 0) return true;

    // 3. Fall back to DOM check for playing video/audio elements in active tab
    for (const tab of tabs) {
      try {
        const response = await chrome.tabs.sendMessage(tab.id, { type: 'CHECK_MEDIA_PLAYING' });
        if (response?.playing) return true;
      } catch {
        // Tab not ready or restricted page
      }
    }
    return false;
  } catch {
    // Content script not injected (e.g. chrome:// page) or tab not ready.
    return false;
  }
}

chrome.idle.onStateChanged.addListener(async state => {
  const settings = await getSettings();
  if (!settings.idleDetection) return;

  const wasIdle = _isIdle;
  _isIdle = state !== 'active';

  if (_isIdle && !wasIdle) {
    // Just went idle — check if media playback bypass is enabled
    const ignoreOnMedia = settings.ignoreIdleOnMedia ?? true;
    const mediaPlaying = ignoreOnMedia ? await _isMediaPlayingInActiveTab() : false;
    if (mediaPlaying) {
      // Keep _isIdle false so tick() continues accumulating time.
      _isIdle = false;
    } else {
      await pauseTracking();
    }
  } else if (!_isIdle && wasIdle) {
    // Returned from idle — resume tracking the current active tab.
    chrome.tabs.query({ active: true, currentWindow: true }, tabs => {
      if (tabs[0]?.url) startTracking(tabs[0].url, tabs[0].title).catch(console.error);
    });
  }
});

// ─── Tab / window events ──────────────────────────────────────────────────────

chrome.tabs.onActivated.addListener(async ({ tabId }) => {
  try {
    const settings = await getSettings();
    const tab = await chrome.tabs.get(tabId);
    if (tab?.url) {
      await startTracking(tab.url, tab.title);
    } else if (settings.pauseOnTabUnfocus) {
      await pauseTracking();
    }
  } catch {
    const settings = await getSettings();
    if (settings.pauseOnTabUnfocus) await pauseTracking().catch(console.error);
  }
});

chrome.tabs.onUpdated.addListener((tabId, info, tab) => {
  if (!tab.url) return;

  if (
    (info.status === 'complete' || info.url) &&
    !tab.url.startsWith(chrome.runtime.getURL('')) &&
    !tab.url.startsWith('chrome-extension://') &&
    !tab.url.startsWith('moz-extension://')
  ) {
    const domain = extractDomain(tab.url);
    if (domain && _blockedDomains.has(domain)) {
      _buildOverlayPayload(domain).then(payload => {
        chrome.tabs.sendMessage(tabId, { type: 'SHOW_BLOCK_OVERLAY', ...payload }).catch(() => {});
      });
    }
  }

  if ((info.status === 'complete' || info.url) && tab.active) {
    startTracking(tab.url, tab.title).catch(console.error);
  }
});

chrome.tabs.onRemoved.addListener(() => {
  chrome.tabs.query({ active: true, currentWindow: true }, tabs => {
    if (tabs.length === 0) pauseTracking().catch(console.error);
  });
});

chrome.windows.onFocusChanged.addListener(async windowId => {
  const settings = await getSettings();
  const pauseOnBlur = settings.pauseOnWindowBlur ?? false;
  if (windowId === chrome.windows.WINDOW_ID_NONE) {
    if (pauseOnBlur) {
      // Don't pause if media (video/audio) is active and media bypass is enabled
      const ignoreOnMedia = (settings.ignoreWindowBlurOnMedia ?? settings.ignoreIdleOnMedia) ?? true;
      const mediaPlaying = ignoreOnMedia ? await _isMediaPlayingInActiveTab() : false;
      if (!mediaPlaying) {
        pauseTracking().catch(console.error);
      }
    }
  } else {
    chrome.tabs.query({ active: true, windowId }, tabs => {
      if (tabs[0]?.url) startTracking(tabs[0].url, tabs[0].title).catch(console.error);
    });
  }
});

// ─── Messages ────────────────────────────────────────────────────────────────

chrome.runtime.onMessage.addListener((msg, _sender, sendResponse) => {
  if (msg.type === 'GET_STATE') {
    chrome.storage.local.get(`${STORAGE_PREFIX}app_state`).then(result => {
      sendResponse(result[`${STORAGE_PREFIX}app_state`] ?? null);
    });
    return true;
  }
  if (msg.type === 'GET_SETTINGS') {
    getSettings().then(sendResponse);
    return true;
  }
  if (msg.type === 'SET_SETTINGS') {
    chrome.storage.local.set({ [`${STORAGE_PREFIX}settings`]: msg.settings }).then(() => sendResponse({ ok: true }));
    return true;
  }
  if (msg.type === 'FLUSH') {
    tick().then(() => sendResponse({ ok: true }));
    return true;
  }
  if (msg.type === 'TRIGGER_SYNC') {
    (async () => {
      await tick();
      await runSync();
      sendResponse({ ok: true });
    })();
    return true;
  }
  if (msg.type === 'FOCUS_CONTROL') {
    sendFocusControl(msg.action).then(() => sendResponse({ ok: true })).catch(e => {
      console.error(e);
      sendResponse({ ok: false });
    });
    return true;
  }
  if (msg.type === 'UNBLOCK_DOMAIN') {
    _blockedDomains.delete(msg.domain);
    refreshBlockedDomains().then(() => sendResponse({ ok: true })).catch(e => {
      console.error(e);
      sendResponse({ ok: false });
    });
    return true;
  }
  if (msg.type === 'CHECK_BLOCK_STATUS') {
    const domain = extractDomain(msg.url || '');
    if (domain && _blockedDomains.has(domain)) {
      _buildOverlayPayload(domain).then(payload => {
        sendResponse({ blocked: true, ...payload });
      }).catch(() => sendResponse({ blocked: false }));
      return true;
    }
    sendResponse({ blocked: false });
    return false;
  }
  if (msg.type === 'OPEN_DASHBOARD') {
    chrome.tabs.create({ url: chrome.runtime.getURL('index.html') });
    return false;
  }
  return false;
});

// ─── Lifecycle ────────────────────────────────────────────────────────────────

chrome.runtime.onInstalled.addListener(() => {
  setupAlarms();
  refreshAppState().catch(console.error);
  refreshBlockedDomains().catch(console.error);
  setupIdleDetection().catch(console.error);
});

chrome.runtime.onStartup.addListener(() => {
  setupAlarms();
  refreshBlockedDomains().catch(console.error);
  setupIdleDetection().catch(console.error);
});

setupAlarms();
refreshBlockedDomains().catch(console.error);
setupIdleDetection().catch(console.error);
