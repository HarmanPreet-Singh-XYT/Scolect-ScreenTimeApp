// ─── Scolect Popup Script ─────────────────────────────────────────────────────

const PREFIX = 'scolect_';

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

// ─── Render ───────────────────────────────────────────────────────────────────

async function render() {
  let state = null;
  let settings = null;

  try {
    // Request state from background
    state = await new Promise((resolve) => {
      chrome.runtime.sendMessage({ type: 'GET_STATE' }, resolve);
    });
    settings = await new Promise((resolve) => {
      chrome.runtime.sendMessage({ type: 'GET_SETTINGS' }, resolve);
    });
  } catch (e) {
    console.error('Popup render error:', e);
  }

  const mode = settings?.mode ?? 'standalone';

  // ── Mode chip
  const chip = document.getElementById('modeChip');
  chip.textContent = mode === 'standalone' ? 'Standalone' : mode === 'hybrid' ? 'Hybrid' : 'Tracker Only';
  chip.className = `mode-chip ${mode === 'hybrid' ? 'hybrid' : mode === 'trackerOnly' ? 'tracker' : ''}`;

  // ── Active tracking
  const activeRow = document.getElementById('activeRow');
  const activeLabel = document.getElementById('activeLabel');
  if (state?.activeDomain) {
    activeRow.style.display = 'flex';
    activeLabel.textContent = `Tracking: ${state.activeDomain}`;
  }

  // ── Today total
  const totalSec = state?.totalSeconds ?? 0;
  document.getElementById('todayTime').textContent = formatSeconds(totalSec);

  const domains = state?.todayDomains ?? [];
  const siteCount = domains.length;
  const visitCount = domains.reduce((s, d) => s + (d.visits ?? 0), 0);
  document.getElementById('todaySub').textContent = `${siteCount} site${siteCount !== 1 ? 's' : ''} · ${visitCount} visit${visitCount !== 1 ? 's' : ''}`;

  // ── Top sites (max 5)
  const list = document.getElementById('sitesList');
  list.innerHTML = '';

  if (domains.length === 0) {
    list.innerHTML = '<div class="empty-state">Browse the web to see your stats here.</div>';
  } else {
    const top = domains.slice(0, 5);
    const maxSec = top[0]?.seconds || 1;

    top.forEach((d, i) => {
      const pct = Math.round((d.seconds / maxSec) * 100);
      const displayName = d.siteName || d.domain;
      const row = document.createElement('div');
      row.className = 'site-row';

      row.innerHTML = `
        <div class="site-bar-bg" style="width:${pct}%"></div>
        <div class="site-rank">${i + 1}</div>
        <div class="site-favicon">${domainInitial(displayName)}</div>
        <div class="site-domain" title="${d.domain}">${displayName}</div>
        <div class="site-time">${formatSeconds(d.seconds)}</div>
      `;
      list.appendChild(row);
    });
  }

  // ── Sync status (hybrid / tracker-only)
  const syncRow = document.getElementById('syncRow');
  const syncDot = document.getElementById('syncDot');
  const syncLabel = document.getElementById('syncLabel');

  if (mode !== 'standalone') {
    syncRow.style.display = 'flex';
    const connected = state?.appConnected;
    const lastSync = state?.lastSyncAt;

    if (connected === true) {
      syncDot.className = 'sync-dot connected';
      syncLabel.textContent = lastSync
        ? `Synced ${timeSince(lastSync)} ago`
        : 'Connected to Scolect Desktop';
    } else if (connected === false) {
      syncDot.className = 'sync-dot disconnected';
      syncLabel.textContent = 'Desktop app not reachable';
    } else {
      syncDot.className = 'sync-dot unknown';
      syncLabel.textContent = mode === 'trackerOnly' ? 'Tracker Only – syncing to desktop' : 'Hybrid mode';
    }
  }
}

function timeSince(epochMs) {
  const secs = Math.floor((Date.now() - epochMs) / 1000);
  if (secs < 60)  return `${secs}s`;
  if (secs < 3600) return `${Math.floor(secs / 60)}m`;
  return `${Math.floor(secs / 3600)}h`;
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

render();

// Auto-refresh every 5 seconds while popup is open
setInterval(render, 5000);
