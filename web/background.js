// ─── Scolect Background Service Worker ───────────────────────────────────────
// Tracks active tab's domain, stores seconds in chrome.storage.local.
// Runs in Standalone, Tracker-Only, and Hybrid modes.

const STORAGE_PREFIX    = 'scolect_';
const ALARM_TICK        = 'scolect_tick';
const ALARM_SYNC        = 'scolect_sync';
const ALARM_REFRESH_BLOCKED = 'scolect_refresh_blocked';
const FLUTTER_PORT      = 46000;
const TICK_PERIOD       = 1 / 60; // minutes (~1 second)
const SYNC_PERIOD       = 1;       // minutes

// ─── Blocked domains & limit notifications ────────────────────────────────────

let _blockedDomains = new Set();

// Tracks which domains have already had the 90% warning fired today (reset on day change).
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

async function checkLimitNotifications(domain, totalSeconds) {
  _resetWarningsIfNewDay();
  const settings = await getSettings();
  const meta = settings.metadata?.[domain];
  if (!meta?.dailyLimitSeconds || meta.dailyLimitSeconds <= 0) return;

  const limit = meta.dailyLimitSeconds;
  const ratio = totalSeconds / limit;
  const siteName = meta.siteName || domain;

  // 90% warning — fire once per domain per day
  if (ratio >= 0.9 && ratio < 1.0 && !_warned90.has(domain)) {
    _warned90.add(domain);
    const remaining = Math.ceil((limit - totalSeconds) / 60);
    _showNotification(
      `scolect_warn_${domain}`,
      'Time limit approaching',
      `${siteName} — ${remaining} min left of your daily limit.`,
    );
  }

  // Limit reached — add to blocked set and notify (unless user unblocked it today)
  if (ratio >= 1.0 && !_blockedDomains.has(domain)) {
    const unblockedToday = await getUnblockedToday();
    if (!unblockedToday.has(domain)) {
      _blockedDomains.add(domain);
      _showNotification(
        `scolect_blocked_${domain}`,
        'Daily limit reached',
        `${siteName} has been blocked for today.`,
      );
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

async function updateSiteName(domain, rawTitle) {
  if (!rawTitle) return;
  // Strip leading notification badges: "(2) ", "[3] ", "• ", "★ "
  const cleaned = rawTitle
    .replace(/^\(\d+\)\s*/, '')
    .replace(/^\[\d+\]\s*/, '')
    .replace(/^[•★]\s*/, '')
    .trim();
  if (!cleaned || cleaned.toLowerCase() === domain) return;

  const key = `${STORAGE_PREFIX}app_metadata`;
  const result = await chrome.storage.local.get(key);
  const meta = result[key] ?? {};
  // Only set on first visit — don't overwrite with per-page titles
  if (!meta[domain]?.siteName) {
    meta[domain] = { ...(meta[domain] ?? {}), siteName: cleaned };
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
  const domain = extractDomain(url);
  if (!domain || IGNORED_DOMAINS.has(domain)) {
    await setActive(null);
    return;
  }
  const current = await getActive();
  if (current?.domain === domain) {
    // Still update site name even if already tracking (e.g. first load)
    await updateSiteName(domain, title);
    return;
  }
  // Flush old entry
  if (current && current.pendingSeconds > 0) {
    const day = getTodayKey();
    await updateDomain(day, current.domain, current.pendingSeconds, 0);
  }
  await setActive({ domain, startedAt: Date.now(), pendingSeconds: 0 });
  // Record a visit
  await updateDomain(getTodayKey(), domain, 0, 1);
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
  const current = await getActive();
  if (!current) return;

  const today = getTodayKey();
  // Day rolled over
  if (current.date && current.date !== today) {
    await updateDomain(current.date, current.domain, current.pendingSeconds, 0);
    current.pendingSeconds = 0;
    current.date = today;
  }

  current.pendingSeconds = (current.pendingSeconds || 0) + 1;

  // Flush every 10 seconds to storage to avoid data loss on worker kill
  if (current.pendingSeconds % 10 === 0) {
    await updateDomain(today, current.domain, current.pendingSeconds, 0);
    current.pendingSeconds = 0;

    // Check if this domain is approaching or has hit its daily limit
    const day = await getDayData(today);
    const domainEntry = day.domains.find(d => d.domain === current.domain);
    if (domainEntry) {
      await checkLimitNotifications(current.domain, domainEntry.seconds);
    }
  }

  await setActive({ ...current, date: today });

  // Update AppState for popup
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

  await chrome.storage.local.set({
    [`${STORAGE_PREFIX}app_state`]: {
      todayDomains: domains,
      activeDomain: active?.domain ?? null,
      totalSeconds: domains.reduce((s, d) => s + d.seconds, 0),
      mode: settings.mode,
      appConnected: prev.appConnected ?? false,
      lastSyncAt: prev.lastSyncAt ?? null,
    }
  });
}

// ─── Blocked domains refresh ──────────────────────────────────────────────────

async function getUnblockedToday() {
  const today = new Date().toDateString();
  const result = await chrome.storage.local.get(['scolect_unblocked_today']);
  const map = result['scolect_unblocked_today'] || {};
  // Return set of domains the user manually unblocked today
  return new Set(Object.entries(map).filter(([, d]) => d === today).map(([k]) => k));
}

async function refreshBlockedDomains() {
  const settings = await getSettings();
  const mode = settings.mode || 'standalone';
  const unblockedToday = await getUnblockedToday();

  let blocked = [];
  if (mode === 'standalone') {
    // Read from storage (set by Flutter web app via WebBrowserDataProvider)
    const data = await chrome.storage.local.get([`${STORAGE_PREFIX}blocked_domains`]);
    blocked = data[`${STORAGE_PREFIX}blocked_domains`] || [];
  } else {
    // Fetch from desktop Flutter app
    let connected = false;
    try {
      const desktopUrl = settings.desktopUrl || `http://localhost:${FLUTTER_PORT}`;
      const resp = await fetch(`${desktopUrl}/ping`, {
        signal: AbortSignal.timeout(3000),
      });
      if (resp.ok) {
        connected = true;
        const focusResp = await fetch(`${desktopUrl}/focus`, {
          signal: AbortSignal.timeout(3000),
        });
        if (focusResp.ok) {
          const json = await focusResp.json();
          blocked = json.blockedDomains || [];
        }
      }
    } catch (_) {}

    const stateKey = `${STORAGE_PREFIX}app_state`;
    const existing = await chrome.storage.local.get(stateKey);
    const prev = existing[stateKey] ?? {};
    await chrome.storage.local.set({
      [stateKey]: { ...prev, appConnected: connected, lastSyncAt: connected ? Date.now() : prev.lastSyncAt }
    });
  }

  // Exclude domains the user explicitly unblocked for today
  _blockedDomains = new Set(blocked.filter(d => !unblockedToday.has(d)));
}

// ─── Desktop sync (Hybrid / Tracker-Only) ────────────────────────────────────

async function runSync() {
  const settings = await getSettings();
  if (settings.mode === 'standalone') return;

  const today = getTodayKey();
  const day = await getDayData(today);
  if (day.domains.length === 0) return;

  const url = `${settings.desktopUrl ?? `http://localhost:${FLUTTER_PORT}`}/usage`;
  let connected = false;

  const metaKey = `${STORAGE_PREFIX}app_metadata`;
  const metaResult = await chrome.storage.local.get(metaKey);
  const siteMeta = metaResult[metaKey] ?? {};

  try {
    const resp = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        date: today,
        domains: day.domains.map(d => ({
          ...d,
          siteName: siteMeta[d.domain]?.siteName ?? null,
        })),
      }),
      signal: AbortSignal.timeout(3000),
    });
    connected = resp.ok;
  } catch {
    connected = false;
  }

  const stateKey = `${STORAGE_PREFIX}app_state`;
  const existing = await chrome.storage.local.get(stateKey);
  const prev = existing[stateKey] ?? {};
  await chrome.storage.local.set({
    [stateKey]: { ...prev, appConnected: connected, lastSyncAt: connected ? Date.now() : prev.lastSyncAt }
  });
}

// ─── Alarms ───────────────────────────────────────────────────────────────────

chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === ALARM_TICK) tick().catch(console.error);
  if (alarm.name === ALARM_SYNC) runSync().catch(console.error);
  if (alarm.name === ALARM_REFRESH_BLOCKED) refreshBlockedDomains().catch(console.error);
});

function setupAlarms() {
  chrome.alarms.get(ALARM_TICK, a => {
    if (!a) chrome.alarms.create(ALARM_TICK, { periodInMinutes: TICK_PERIOD });
  });
  chrome.alarms.get(ALARM_SYNC, a => {
    if (!a) chrome.alarms.create(ALARM_SYNC, { periodInMinutes: SYNC_PERIOD });
  });
  chrome.alarms.get(ALARM_REFRESH_BLOCKED, a => {
    if (!a) chrome.alarms.create(ALARM_REFRESH_BLOCKED, { periodInMinutes: 1 });
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

  // Block sites that have exceeded their daily limit.
  // Only intercept on 'loading' to catch the navigation early, and skip if we
  // are already on the blocked page (avoids infinite redirect loops).
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

// ─── Extension icon click → open dashboard tab ────────────────────────────────

// Note: popup.html handles the mini-popup; the "Open Dashboard" button there
// calls chrome.tabs.create({ url: chrome.runtime.getURL('index.html') })

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
