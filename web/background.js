// ─── Scolect Background Service Worker ───────────────────────────────────────
// Tracks active tab's domain, stores seconds in chrome.storage.local.
// Runs in Standalone, Tracker-Only, and Hybrid modes.

const STORAGE_PREFIX = 'scolect_';
const ALARM_TICK     = 'scolect_tick';
const ALARM_SYNC     = 'scolect_sync';
const FLUTTER_PORT   = 46000;
const TICK_PERIOD    = 1 / 60; // minutes (~1 second)
const SYNC_PERIOD    = 1;       // minutes

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

async function startTracking(url) {
  const domain = extractDomain(url);
  if (!domain || IGNORED_DOMAINS.has(domain)) {
    await setActive(null);
    return;
  }
  const current = await getActive();
  if (current?.domain === domain) return; // already tracking
  // Flush old entry
  if (current && current.pendingSeconds > 0) {
    const day = getTodayKey();
    await updateDomain(day, current.domain, current.pendingSeconds, 0);
  }
  await setActive({ domain, startedAt: Date.now(), pendingSeconds: 0 });
  // Record a visit
  await updateDomain(getTodayKey(), domain, 0, 1);
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

  const domains = [...day.domains].sort((a, b) => b.seconds - a.seconds);

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

// ─── Desktop sync (Hybrid / Tracker-Only) ────────────────────────────────────

async function runSync() {
  const settings = await getSettings();
  if (settings.mode === 'standalone') return;

  const today = getTodayKey();
  const day = await getDayData(today);
  if (day.domains.length === 0) return;

  const url = `${settings.desktopUrl ?? `http://localhost:${FLUTTER_PORT}`}/api/browser-sync`;
  let connected = false;

  try {
    const resp = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ date: today, domains: day.domains }),
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
});

function setupAlarms() {
  chrome.alarms.get(ALARM_TICK, a => {
    if (!a) chrome.alarms.create(ALARM_TICK, { periodInMinutes: TICK_PERIOD });
  });
  chrome.alarms.get(ALARM_SYNC, a => {
    if (!a) chrome.alarms.create(ALARM_SYNC, { periodInMinutes: SYNC_PERIOD });
  });
}

// ─── Tab / window events ──────────────────────────────────────────────────────

chrome.tabs.onActivated.addListener(async ({ tabId }) => {
  try {
    const tab = await chrome.tabs.get(tabId);
    if (tab.url) await startTracking(tab.url);
  } catch { /* tab closed */ }
});

chrome.tabs.onUpdated.addListener((_id, info, tab) => {
  if (info.status === 'complete' && tab.active && tab.url) {
    startTracking(tab.url).catch(console.error);
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
  return false;
});

// ─── Lifecycle ────────────────────────────────────────────────────────────────

chrome.runtime.onInstalled.addListener(() => {
  setupAlarms();
  refreshAppState().catch(console.error);
});

chrome.runtime.onStartup.addListener(() => {
  setupAlarms();
});

setupAlarms();
