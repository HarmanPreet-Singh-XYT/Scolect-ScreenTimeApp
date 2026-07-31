// ─── Scolect Background Service Worker ───────────────────────────────────────
// Tracks active tab's domain, stores seconds in chrome.storage.local.
// Runs in Standalone, Tracker-Only, and Hybrid modes.

const STORAGE_PREFIX    = 'scolect_';
const ALARM_TICK        = 'scolect_tick';
const FLUTTER_PORT      = 46000;
const TICK_PERIOD       = 1 / 60; // minutes (~1 second)
const WS_URL            = `ws://localhost:${FLUTTER_PORT}/ws`;

// ─── WebSocket state ──────────────────────────────────────────────────────────
// MV3 service workers can be killed at any time; _ws is reconnected on demand
// inside tick() and refreshBlockedDomains(). On localhost a reconnect is <1ms.

let _ws = null;
// Last focus_state pushed by the desktop; used as a cache when the SW restarts
// so refreshBlockedDomains() can apply the last known state without a network call.
let _pendingFocusState = null;

function getWs() {
  if (_ws && (_ws.readyState === WebSocket.OPEN || _ws.readyState === WebSocket.CONNECTING)) {
    return _ws;
  }
  _ws = new WebSocket(WS_URL);
  _ws.onmessage = handleDesktopMessage;
  _ws.onerror   = () => { _ws = null; };
  _ws.onclose   = () => { _ws = null; };
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
      const ext = currentMeta[domain] ?? {};
      const merged = {
        category:          ext.category          || desktopMeta.category          || 'Uncategorized',
        isTracking:        ext.isTracking  !== undefined ? ext.isTracking  : (desktopMeta.isTracking  ?? true),
        isProductive:      ext.isProductive !== undefined ? ext.isProductive : (desktopMeta.isProductive ?? false),
        dailyLimitSeconds: (ext.dailyLimitSeconds ?? 0) > 0
          ? ext.dailyLimitSeconds
          : (desktopMeta.dailyLimitSeconds ?? 0),
        siteName: ext.siteName || desktopMeta.siteName || '',
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
  });

  // Apply blocked set (excluding manually unblocked domains)
  _blockedDomains = new Set(blocked.filter(d => !unblockedToday.has(d)));
  for (const domain of _blockedDomains) {
    await _redirectBlockedDomainTabs(domain);
  }
}

// ─── Blocked domains & limit notifications ────────────────────────────────────

let _blockedDomains = new Set();

let _warned90 = new Set();
let _warned90Date = '';

function _resetWarningsIfNewDay() {
  const today = getTodayKey();
  if (_warned90Date !== today) {
    _warned90 = new Set();
    _warned90Date = today;
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

async function _redirectBlockedDomainTabs(domain) {
  try {
    const tabs = await chrome.tabs.query({});
    for (const tab of tabs) {
      if (tab.url && !tab.url.startsWith(chrome.runtime.getURL('blocked.html'))) {
        const d = extractDomain(tab.url);
        if (d === domain) {
          const blockedUrl = chrome.runtime.getURL('blocked.html') + '?domain=' + encodeURIComponent(domain);
          await chrome.tabs.update(tab.id, { url: blockedUrl });
        }
      }
    }
  } catch (e) {
    console.error('Error redirecting tabs for domain:', domain, e);
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
      await _redirectBlockedDomainTabs(domain);
    }
  }
}

const IGNORED_DOMAINS = new Set([
  '', 'newtab', 'extensions', 'settings', 'history',
  'localhost', '127.0.0.1', 'chrome', 'about',
]);

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
    // Still on the same site — update name but also record a re-visit if the
    // user left and came back (startedAt was reset by a previous pauseTracking).
    await updateSiteName(domain, title);
    return;
  }
  // Flush pending seconds for the site we're leaving.
  if (current && current.pendingSeconds > 0) {
    await updateDomain(today, current.domain, current.pendingSeconds, 0);
  }
  await setActive({ domain, startedAt: Date.now(), pendingSeconds: 0, date: today });
  // Record a visit every time we switch to this domain (covers re-visits).
  await updateDomain(today, domain, 0, 1);
  await updateSiteName(domain, title);
}

async function pauseTracking() {
  const current = await getActive();
  if (!current) return;
  if (current.pendingSeconds > 0) {
    await updateDomain(getTodayKey(), current.domain, current.pendingSeconds, 0);
  }
  await setActive(null);
}

async function tick() {
  const settings = await getSettings();

  // Local focus timer runs regardless of whether a tab is being tracked.
  if (settings.mode === 'standalone') {
    await _tickLocalFocus();
  }

  const current = await getActive();
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
  }

  current.pendingSeconds = (current.pendingSeconds || 0) + 1;

  if (current.pendingSeconds % 5 === 0) {
    await updateDomain(today, current.domain, current.pendingSeconds, 0);
    current.pendingSeconds = 0;

    const day = await getDayData(today);
    const domainEntry = day.domains.find(d => d.domain === current.domain);
    if (domainEntry) {
      await checkLimitNotifications(current.domain, domainEntry.seconds);
    }

    // Push usage to desktop over WebSocket (replaces 1-min ALARM_SYNC poll).
    // Fire-and-forget so a slow/absent desktop never delays the tick.
    if (settings.mode !== 'standalone') {
      runSync().catch(console.error);
    }
  } else {
    const meta = settings.metadata?.[current.domain];
    if (meta?.dailyLimitSeconds > 0) {
      const today2 = getTodayKey();
      const day2 = await getDayData(today2);
      const committed = day2.domains.find(d => d.domain === current.domain)?.seconds ?? 0;
      const estimated = committed + current.pendingSeconds;
      const ratio = estimated / meta.dailyLimitSeconds;
      if (ratio >= 0.9) {
        await checkLimitNotifications(current.domain, estimated);
      }
    }
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
    for (const entry of day.domains) {
      const m = meta[entry.domain];
      if (m && m.dailyLimitSeconds > 0 && entry.seconds >= m.dailyLimitSeconds) {
        blocked.push(entry.domain);
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
    await _redirectBlockedDomainTabs(domain);
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
  await chrome.storage.local.set({
    [stateKey]: { ...prev, appConnected: connected, lastSyncAt: connected ? Date.now() : prev.lastSyncAt },
  });
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
  }
});

function setupAlarms() {
  chrome.alarms.get(ALARM_TICK, a => {
    if (!a) chrome.alarms.create(ALARM_TICK, { periodInMinutes: TICK_PERIOD });
  });
}

// ─── Tab / window events ──────────────────────────────────────────────────────

chrome.tabs.onActivated.addListener(async ({ tabId }) => {
  try {
    const tab = await chrome.tabs.get(tabId);
    if (tab.url) await startTracking(tab.url, tab.title);
  } catch { /* tab closed */ }
});

chrome.tabs.onUpdated.addListener((tabId, info, tab) => {
  if (!tab.url) return;

  if (info.status === 'loading' && !tab.url.startsWith(chrome.runtime.getURL('blocked.html'))) {
    const domain = extractDomain(tab.url);
    if (domain && _blockedDomains.has(domain)) {
      const blockedUrl = chrome.runtime.getURL('blocked.html') + '?domain=' + encodeURIComponent(domain);
      chrome.tabs.update(tabId, { url: blockedUrl });
      return;
    }
  }

  if (info.status === 'complete' && tab.active) {
    startTracking(tab.url, tab.title).catch(console.error);
  }
});

chrome.tabs.onRemoved.addListener(() => {
  chrome.tabs.query({ active: true, currentWindow: true }, tabs => {
    if (tabs.length === 0) pauseTracking().catch(console.error);
  });
});

chrome.windows.onFocusChanged.addListener(windowId => {
  if (windowId === chrome.windows.WINDOW_ID_NONE) {
    pauseTracking().catch(console.error);
  } else {
    chrome.tabs.query({ active: true, windowId }, tabs => {
      if (tabs[0]?.url) startTracking(tabs[0].url).catch(console.error);
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
  return false;
});

// ─── Lifecycle ────────────────────────────────────────────────────────────────

chrome.runtime.onInstalled.addListener(() => {
  setupAlarms();
  refreshAppState().catch(console.error);
  refreshBlockedDomains().catch(console.error);
});

chrome.runtime.onStartup.addListener(() => {
  setupAlarms();
  refreshBlockedDomains().catch(console.error);
});

setupAlarms();
refreshBlockedDomains().catch(console.error);
