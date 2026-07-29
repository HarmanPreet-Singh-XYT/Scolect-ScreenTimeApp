// ─── Scolect Popup Script ─────────────────────────────────────────────────────

const PREFIX = 'scolect_';

// ─── Helpers ──────────────────────────────────────────────────────────────────

function formatSeconds(seconds) {
  if (!seconds || seconds <= 0) return '0m';
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  if (h > 0) return m > 0 ? `${h}h ${m}m` : `${h}h`;
  if (m > 0) return `${m}m`;
  return `${s}s`;
}

function domainInitial(domain) {
  return (domain || '?').charAt(0).toUpperCase();
}

function timeSince(epochMs) {
  const secs = Math.floor((Date.now() - epochMs) / 1000);
  if (secs < 60)  return `${secs}s`;
  if (secs < 3600) return `${Math.floor(secs / 60)}m`;
  return `${Math.floor(secs / 3600)}h`;
}

function getTodayDateString() {
  const d = new Date();
  const y = d.getFullYear();
  const mo = String(d.getMonth() + 1).padStart(2, '0');
  const da = String(d.getDate()).padStart(2, '0');
  return `${y}-${mo}-${da}`;
}

// ─── Theme ────────────────────────────────────────────────────────────────────

function colorIntToHex(intVal) {
  if (intVal === undefined || intVal === null) return null;
  const r = (intVal >> 16) & 0xFF;
  const g = (intVal >> 8) & 0xFF;
  const b = intVal & 0xFF;
  return '#' + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
}

function colorIntToRgba(intVal, alphaOverride) {
  if (intVal === undefined || intVal === null) return null;
  const a = alphaOverride !== undefined
    ? alphaOverride
    : (((intVal >> 24) & 0xFF) / 255);
  const r = (intVal >> 16) & 0xFF;
  const g = (intVal >> 8) & 0xFF;
  const b = intVal & 0xFF;
  return `rgba(${r}, ${g}, ${b}, ${typeof a === 'number' ? a.toFixed(2) : a})`;
}

/**
 * Apply scolect_theme_colors to CSS custom properties immediately,
 * before any content is rendered, to avoid a flash of wrong colours.
 */
async function applyTheme() {
  try {
    const res = await chrome.storage.local.get(['scolect_theme_colors', 'scolect_theme_id']);
    const tc = res?.scolect_theme_colors;
    const themeId = res?.scolect_theme_id;

    if (tc) {
      const root = document.documentElement;
      const accent   = colorIntToHex(tc.primaryAccent);
      const accent2  = colorIntToHex(tc.secondaryAccent);
      const bg       = colorIntToHex(tc.darkBackground);
      const surface  = colorIntToHex(tc.darkSurface);
      const surface2 = colorIntToHex(tc.darkSurfaceSecondary);
      const border   = colorIntToRgba(tc.darkBorder, 1);
      const textPri  = colorIntToHex(tc.darkTextPrimary);
      const textSec  = colorIntToHex(tc.darkTextSecondary);

      if (accent)   root.style.setProperty('--accent', accent);
      if (accent2)  root.style.setProperty('--accent2', accent2);
      if (bg)       root.style.setProperty('--bg', bg);
      if (surface)  root.style.setProperty('--surface', surface);
      if (surface2) root.style.setProperty('--surface2', surface2);
      if (border)   root.style.setProperty('--border', border);
      if (textPri)  root.style.setProperty('--text-primary', textPri);
      if (textSec)  root.style.setProperty('--text-secondary', textSec);
      // Derive muted from secondary text color at 60% opacity
      if (tc.darkTextSecondary) {
        root.style.setProperty('--text-muted', colorIntToRgba(tc.darkTextSecondary, 0.6));
      }

      // derived: glow and subtle are always accent-based
      if (accent) {
        const r = parseInt(accent.slice(1, 3), 16);
        const g = parseInt(accent.slice(3, 5), 16);
        const bv = parseInt(accent.slice(5, 7), 16);
        root.style.setProperty('--accent-glow',   `rgba(${r},${g},${bv},0.18)`);
        root.style.setProperty('--accent-subtle',  `rgba(${r},${g},${bv},0.10)`);
      }
    } else if (themeId) {
      document.body.dataset.theme = themeId;
    } else {
      delete document.body.dataset.theme;
    }
  } catch (e) {
    console.warn('Popup: could not apply theme', e);
  }
}

// ─── Render ───────────────────────────────────────────────────────────────────

async function render() {
  let state    = null;
  let settings = null;
  let storageData = {};

  try {
    [state, settings, storageData] = await Promise.all([
      new Promise(resolve => chrome.runtime.sendMessage({ type: 'GET_STATE' }, resolve)),
      new Promise(resolve => chrome.runtime.sendMessage({ type: 'GET_SETTINGS' }, resolve)),
      chrome.storage.local.get([
        'scolect_focus_sessions',
        'scolect_blocked_domains',
        'scolect_settings',
      ]),
    ]);
  } catch (e) {
    console.error('Popup render error:', e);
  }

  const mode    = settings?.mode ?? state?.mode ?? 'standalone';
  const domains = state?.todayDomains ?? [];

  // ── Mode chip
  const chip = document.getElementById('modeChip');
  chip.textContent = mode === 'standalone'
    ? 'Standalone'
    : mode === 'hybrid'
    ? 'Hybrid'
    : 'Tracker Only';
  chip.className = `mode-chip${mode === 'hybrid' ? ' hybrid' : mode === 'trackerOnly' ? ' tracker' : ''}`;

  // ── Active tracking bar
  const activeRow      = document.getElementById('activeRow');
  const activeLabel    = document.getElementById('activeLabel');
  const activeDuration = document.getElementById('activeDuration');
  if (state?.activeDomain) {
    activeRow.style.display = 'flex';
    activeLabel.textContent = state.activeDomain;
    const activeSite = domains.find(d => d.domain === state.activeDomain);
    activeDuration.textContent = activeSite ? formatSeconds(activeSite.seconds) : '';
  } else {
    activeRow.style.display = 'none';
  }

  // ── Hero stat
  const totalSec   = state?.totalSeconds ?? 0;
  const siteCount  = domains.length;
  const visitCount = domains.reduce((s, d) => s + (d.visits ?? 0), 0);

  document.getElementById('todayTime').textContent = formatSeconds(totalSec);
  document.getElementById('chipSites').textContent  = `${siteCount} site${siteCount !== 1 ? 's' : ''}`;
  document.getElementById('chipVisits').textContent = `${visitCount} visit${visitCount !== 1 ? 's' : ''}`;

  // Donut ring: 8 hours = 100%
  const DAILY_TARGET_SECS = 8 * 3600;
  const ringPct = Math.min(totalSec / DAILY_TARGET_SECS, 1);
  const CIRCUMFERENCE = 2 * Math.PI * 22;
  const offset = CIRCUMFERENCE * (1 - ringPct);
  document.getElementById('ringFill').style.strokeDashoffset = offset.toFixed(2);
  document.getElementById('ringLabel').textContent = `${Math.round(ringPct * 100)}%`;

  // ── Mini info cards
  const todayStr = getTodayDateString();

  const allSessions = storageData?.scolect_focus_sessions ?? [];
  const todaySessions = allSessions.filter(s => {
    if (!s.startTime) return false;
    const d = new Date(s.startTime);
    const key = `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
    return key === todayStr;
  });
  document.getElementById('focusCount').textContent = String(todaySessions.length);

  const blockedDomains = storageData?.scolect_blocked_domains ?? [];
  document.getElementById('blockedCount').textContent = String(blockedDomains.length);

  // ── Top sites (max 4)
  const list = document.getElementById('sitesList');
  list.innerHTML = '';

  const siteMetadata = storageData?.scolect_settings?.metadata ?? {};

  if (domains.length === 0) {
    list.innerHTML = `
      <div class="empty-state">
        <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="var(--text-muted)" stroke-width="1.5" stroke-linecap="round">
          <path d="M3 12a9 9 0 1 0 18 0 9 9 0 0 0-18 0"/>
          <path d="M3.6 9h16.8M3.6 15h16.8"/>
          <path d="M11.5 3a17 17 0 0 0 0 18"/>
          <path d="M12.5 3a17 17 0 0 1 0 18"/>
        </svg>
        <p>Start browsing to see<br>your top sites here.</p>
      </div>`;
  } else {
    const top    = domains.slice(0, 4);
    const maxSec = top[0]?.seconds || 1;

    top.forEach((d, i) => {
      const bgPct      = Math.round((d.seconds / maxSec) * 100);
      const displayName = d.siteName || d.domain;

      const cleanDomain = d.domain.replace(/^www\./, '').toLowerCase();
      const meta = siteMetadata[d.domain]
        || siteMetadata['www.' + cleanDomain]
        || siteMetadata[cleanDomain];
      const limitSecs = meta?.dailyLimitSeconds ?? 0;

      let limitBarHTML = '';
      if (limitSecs > 0) {
        const usedPct  = Math.min((d.seconds / limitSecs) * 100, 100);
        const barClass = usedPct >= 90 ? 'danger' : usedPct >= 70 ? 'warn' : 'ok';
        limitBarHTML = `
          <div class="limit-bar-wrap">
            <div class="limit-bar-track">
              <div class="limit-bar-fill ${barClass}" style="width:${usedPct.toFixed(1)}%"></div>
            </div>
            <span class="limit-bar-label">${formatSeconds(d.seconds)} / ${formatSeconds(limitSecs)}</span>
          </div>`;
      }

      const row = document.createElement('div');
      row.className = 'site-row';
      row.innerHTML = `
        <div class="site-bar-bg" style="width:${bgPct}%"></div>
        <div class="site-rank">${i + 1}</div>
        <div class="site-favicon">${domainInitial(displayName)}</div>
        <div class="site-info">
          <div class="site-domain" title="${d.domain}">${displayName}</div>
          ${limitBarHTML}
        </div>
        <div class="site-time-col">
          <span class="site-time">${formatSeconds(d.seconds)}</span>
          ${d.visits ? `<span class="site-visits">${d.visits}×</span>` : ''}
        </div>`;
      list.appendChild(row);
    });
  }

  // Section hint
  const hint = document.getElementById('sectionHint');
  hint.textContent = domains.length > 4 ? `+${domains.length - 4} more` : '';

  // ── Sync row
  const syncRow   = document.getElementById('syncRow');
  const syncDot   = document.getElementById('syncDot');
  const syncLabel = document.getElementById('syncLabel');
  const syncTime  = document.getElementById('syncTime');

  if (mode !== 'standalone') {
    syncRow.style.display = 'flex';
    const connected = state?.appConnected;
    const lastSync  = state?.lastSyncAt;

    if (connected === true) {
      syncDot.className = 'sync-dot connected';
      syncLabel.textContent = 'Connected to Scolect Desktop';
      syncTime.textContent  = lastSync ? `${timeSince(lastSync)} ago` : '';
    } else if (connected === false) {
      syncDot.className = 'sync-dot disconnected';
      syncLabel.textContent = 'Desktop not reachable';
      syncTime.textContent  = '';
    } else {
      syncDot.className = 'sync-dot unknown';
      syncLabel.textContent = mode === 'trackerOnly' ? 'Tracker Only' : 'Hybrid mode';
      syncTime.textContent  = '';
    }
  } else {
    syncRow.style.display = 'none';
  }
}

// ─── Actions ──────────────────────────────────────────────────────────────────

document.getElementById('openDashBtn').addEventListener('click', () => {
  chrome.tabs.create({ url: chrome.runtime.getURL('index.html') });
  window.close();
});

document.getElementById('settingsBtn').addEventListener('click', () => {
  chrome.tabs.create({ url: chrome.runtime.getURL('index.html?tab=settings') });
  window.close();
});

// ─── Init ─────────────────────────────────────────────────────────────────────

applyTheme().then(() => render());

// Auto-refresh every 5 seconds while popup is open
setInterval(render, 5000);
