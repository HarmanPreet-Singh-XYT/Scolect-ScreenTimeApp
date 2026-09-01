// ─── Scolect Popup Script ─────────────────────────────────────────────────────

const PREFIX = 'scolect_';

function setCleanHTML(targetElement, htmlString) {
  if (!targetElement) return;
  const parser = new DOMParser();
  const doc = parser.parseFromString(htmlString, 'text/html');
  targetElement.replaceChildren(...Array.from(doc.body.childNodes));
}

function escHtml(str) {
  if (str === null || str === undefined) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

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

// ─── Tab state ────────────────────────────────────────────────────────────────

let _activeTab = 'overview';
let _focusEndTimeMs = null; // kept in sync by renderFocusTab; read by 1s ticker

function switchTab(tab) {
  _activeTab = tab;

  const ids = ['Overview', 'Site', 'Focus'];
  for (const id of ids) {
    const btn   = document.getElementById(`tab${id}`);
    const panel = document.getElementById(`panel${id}`);
    const active = id.toLowerCase() === tab;
    btn?.classList.toggle('active', active);
    if (panel) panel.style.display = active ? 'flex' : 'none';
  }
}

// ─── Site tab renderer ────────────────────────────────────────────────────────

/**
 * Get a YYYY-MM-DD string for an offset from today.
 * offset 0 = today, -1 = yesterday, etc.
 */
function getDateString(offsetDays) {
  const d = new Date();
  d.setDate(d.getDate() + offsetDays);
  const y  = d.getFullYear();
  const mo = String(d.getMonth() + 1).padStart(2, '0');
  const da = String(d.getDate()).padStart(2, '0');
  return `${y}-${mo}-${da}`;
}

/** Short day label (Mon, Tue, …) for a date string "YYYY-MM-DD". */
function dayLabel(dateStr) {
  const [y, mo, da] = dateStr.split('-').map(Number);
  const d = new Date(y, mo - 1, da);
  return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][d.getDay()];
}

async function renderSiteTab(state, storageData) {
  const panel = document.getElementById('panelSite');
  const domain = state?.activeDomain ?? null;

  if (!domain) {
    setCleanHTML(panel, `
      <div class="site-empty">
        <div class="site-empty-favicon">?</div>
        <div class="site-empty-title">No active site</div>
        <div class="site-empty-sub">Start browsing to see<br>site details here.</div>
      </div>`);
    return;
  }

  // ── Resolve today's data for this domain
  const domains      = state?.todayDomains ?? [];
  const domainEntry  = domains.find(d => d.domain === domain) ?? {};
  const todaySecs    = domainEntry.seconds  ?? 0;
  const todayVisits  = domainEntry.visits   ?? 0;
  const siteName     = domainEntry.siteName ?? null;
  const lastSeenMs   = domainEntry.lastSeen ?? null;

  // ── Resolve metadata (limit, isProductive, isPrivate)
  const siteMetadata = storageData?.scolect_settings?.metadata ?? {};
  const cleanDomain  = domain.replace(/^www\./, '').toLowerCase();
  const meta = siteMetadata[domain]
    || siteMetadata['www.' + cleanDomain]
    || siteMetadata[cleanDomain]
    || {};
  const limitSecs    = meta.dailyLimitSeconds ?? 0;
  const isProductive = meta.isProductive;   // true | false | undefined

  // Private sites are never rendered by name/identity in the popup — there's
  // no unlock UI here, so treat this the same as the locked/default state
  // everywhere else in the app.
  if (meta.isPrivate) {
    setCleanHTML(panel, `
      <div class="site-empty">
        <div class="site-empty-favicon">?</div>
        <div class="site-empty-title">No active site</div>
        <div class="site-empty-sub">Start browsing to see<br>site details here.</div>
      </div>`);
    return;
  }

  // ── Fetch 7 days of history from storage
  const todayStr = getTodayDateString();
  const weekDates = [];
  for (let i = -6; i <= 0; i++) {
    weekDates.push(getDateString(i));
  }
  const weekKeys  = weekDates.map(d => `scolect_day_${d}`);
  let weekStorage = {};
  try {
    weekStorage = await chrome.storage.local.get(weekKeys);
  } catch (e) {
    console.warn('Popup: could not read week history', e);
  }

  // Build array of { dateStr, secs } for the 7 days
  const weekData = weekDates.map(dateStr => {
    const key      = `scolect_day_${dateStr}`;
    const dayData  = weekStorage[key];
    // dayData is expected to be an array or object of domain entries
    let secs = 0;
    if (Array.isArray(dayData)) {
      const entry = dayData.find(e => e.domain === domain);
      secs = entry?.seconds ?? 0;
    } else if (dayData && typeof dayData === 'object') {
      // handle object keyed by domain or with a domains array
      if (Array.isArray(dayData.domains)) {
        const entry = dayData.domains.find(e => e.domain === domain);
        secs = entry?.seconds ?? 0;
      } else if (dayData[domain] !== undefined) {
        secs = dayData[domain]?.seconds ?? 0;
      }
    }
    return { dateStr, secs };
  });

  const maxSecs = Math.max(...weekData.map(d => d.secs), 1);

  // ── Build hero limit bar HTML
  let heroLimitHTML = '';
  if (limitSecs > 0) {
    const usedPct  = Math.min((todaySecs / limitSecs) * 100, 100);
    const barClass = usedPct >= 90 ? 'danger' : usedPct >= 70 ? 'warn' : 'ok';
    heroLimitHTML = `
      <div class="site-hero-limit">
        <div class="limit-bar-wrap">
          <div class="limit-bar-track">
            <div class="limit-bar-fill ${barClass}" style="width:${usedPct.toFixed(1)}%"></div>
          </div>
          <span class="limit-bar-label">${formatSeconds(todaySecs)} / ${formatSeconds(limitSecs)}</span>
        </div>
      </div>`;
  }

  // ── Build productive/non-productive badge HTML
  let badgeHTML = '';
  if (isProductive === true) {
    badgeHTML = `<span class="site-badge productive">Productive</span>`;
  } else if (isProductive === false) {
    badgeHTML = `<span class="site-badge non-productive">Non-Productive</span>`;
  }

  // ── Build weekly bar chart rows
  const weekRowsHTML = weekData.map(({ dateStr, secs }) => {
    const isToday  = dateStr === todayStr;
    const barPct   = maxSecs > 0 ? Math.round((secs / maxSecs) * 100) : 0;
    const fillClass = isToday ? 'today' : 'other';
    const dayClass  = isToday ? ' today' : '';
    return `
      <div class="week-row">
        <div class="week-day${dayClass}">${dayLabel(dateStr)}</div>
        <div class="week-bar-track">
          <div class="week-bar-fill ${fillClass}" style="width:${barPct}%"></div>
        </div>
        <div class="week-time${dayClass}">${secs > 0 ? formatSeconds(secs) : '—'}</div>
      </div>`;
  }).join('');

  // ── Inject final HTML
  const displayDomain = domain.replace(/^www\./, '');
  const faviconLetter = domainInitial(displayDomain);

  setCleanHTML(panel, `
    <div class="site-hero">
      <div class="site-hero-favicon">${escHtml(faviconLetter)}</div>
      ${siteName ? `<div class="site-hero-name">${escHtml(siteName)}</div>` : ''}
      <div class="site-hero-domain" title="${escHtml(domain)}">${escHtml(displayDomain)}</div>
      <div class="site-hero-time">${escHtml(formatSeconds(todaySecs))}</div>
      <div class="site-hero-chips">
        <span class="stat-chip">${escHtml(todayVisits)} visit${todayVisits !== 1 ? 's' : ''}</span>
        ${lastSeenMs ? `<span class="stat-chip">${escHtml(timeSince(lastSeenMs))} ago</span>` : ''}
        ${badgeHTML}
      </div>
      ${heroLimitHTML}
    </div>
    <div class="week-chart-card">
      <div class="week-chart-title">Past 7 Days</div>
      <div class="week-chart">
        ${weekRowsHTML}
      </div>
    </div>`);
}

// ─── Render ───────────────────────────────────────────────────────────────────

async function render() {
  let state    = null;
  let settings = null;
  let storageData = {};

  try {
    // Read everything directly from storage — always works even if the
    // service worker was sleeping and hasn't restarted yet.
    const raw = await chrome.storage.local.get([
      'scolect_app_state',
      'scolect_settings',
      'scolect_focus_sessions',
      'scolect_blocked_domains',
      'scolect_local_focus',
    ]);
    state    = raw['scolect_app_state'] ?? null;
    settings = raw['scolect_settings']  ?? null;
    storageData = {
      scolect_focus_sessions: raw['scolect_focus_sessions'],
      scolect_blocked_domains: raw['scolect_blocked_domains'],
      scolect_settings: raw['scolect_settings'],
      scolect_local_focus: raw['scolect_local_focus'],
    };

    // For standalone mode, derive live focus state directly from scolect_local_focus
    // so we never depend on the SW having run refreshAppState() first.
    const lf = raw['scolect_local_focus'];
    const swMode = settings?.mode ?? state?.mode ?? 'standalone';
    if (swMode === 'standalone' && lf) {
      const now = Date.now();
      const isRunning = lf.running && lf.endMs != null && lf.endMs > now;
      state = {
        ...(state ?? {}),
        focusActive:    isRunning,
        sessionLabel:   isRunning
          ? ({ work: 'Work Session', shortBreak: 'Short Break', longBreak: 'Long Break' }[lf.phase] ?? null)
          : null,
        endTimeEpochMs: isRunning ? lf.endMs : null,
        // Carry the phase so renderFocusTab knows which pill to mark active even when idle.
        _localFocusPhase: lf.phase,
      };
    }

    // Wake the service worker so it processes any pending ticks.
    chrome.runtime.sendMessage({ type: 'FLUSH' }).catch(() => {});
  } catch (e) {
    console.error('Popup render error:', e);
  }

  const mode    = settings?.mode ?? state?.mode ?? 'standalone';
  const siteMetadata = storageData?.scolect_settings?.metadata ?? {};
  const includePrivateInTotals = storageData?.scolect_settings?.privacyIncludeInTotals ?? true;

  function isDomainPrivate(domain) {
    const cleanDomain = domain.replace(/^www\./, '').toLowerCase();
    const meta = siteMetadata[domain]
      || siteMetadata['www.' + cleanDomain]
      || siteMetadata[cleanDomain];
    return meta?.isPrivate ?? false;
  }

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
  if (state?.activeDomain && !isDomainPrivate(state.activeDomain)) {
    activeRow.style.display = 'flex';
    activeLabel.textContent = state.activeDomain;
    const activeSite = domains.find(d => d.domain === state.activeDomain);
    activeDuration.textContent = activeSite ? formatSeconds(activeSite.seconds) : '';
  } else {
    activeRow.style.display = 'none';
  }

  // ── Hero stat — private sites are excluded from totals when the user has
  // turned off "Include Private Items in Totals" (default: included).
  const privateDomains = domains.filter(d => isDomainPrivate(d.domain));
  const privateSecs = privateDomains.reduce((s, d) => s + (d.seconds ?? 0), 0);
  const privateVisits = privateDomains.reduce((s, d) => s + (d.visits ?? 0), 0);

  const rawTotalSec   = state?.totalSeconds ?? 0;
  const rawVisitCount = domains.reduce((s, d) => s + (d.visits ?? 0), 0);
  const totalSec   = includePrivateInTotals ? rawTotalSec : rawTotalSec - privateSecs;
  const siteCount  = includePrivateInTotals ? domains.length : domains.length - privateDomains.length;
  const visitCount = includePrivateInTotals ? rawVisitCount : rawVisitCount - privateVisits;

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

  // ── Top sites (max 4) — private domains are never shown by name in the
  // list; whether they count toward totalSec/visitCount/siteCount above
  // depends on the "Include Private Items in Totals" setting.
  const list = document.getElementById('sitesList');
  list.replaceChildren();

  const visibleDomains = domains.filter(d => !isDomainPrivate(d.domain));

  if (visibleDomains.length === 0) {
    setCleanHTML(list, `
      <div class="empty-state">
        <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="var(--text-muted)" stroke-width="1.5" stroke-linecap="round">
          <path d="M3 12a9 9 0 1 0 18 0 9 9 0 0 0-18 0"/>
          <path d="M3.6 9h16.8M3.6 15h16.8"/>
          <path d="M11.5 3a17 17 0 0 0 0 18"/>
          <path d="M12.5 3a17 17 0 0 1 0 18"/>
        </svg>
        <p>Start browsing to see<br>your top sites here.</p>
      </div>`);
  } else {
    const top    = visibleDomains.slice(0, 4);
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
      let timeColorStyle = '';
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
        // Color the time value to signal limit proximity
        if (usedPct >= 100) timeColorStyle = 'color:#ef4444';
        else if (usedPct >= 90) timeColorStyle = 'color:#f97316';
        else if (usedPct >= 70) timeColorStyle = 'color:#f59e0b';
      }

      const row = document.createElement('div');
      row.className = 'site-row';
      setCleanHTML(row, `
        <div class="site-bar-bg" style="width:${bgPct}%"></div>
        <div class="site-rank">${i + 1}</div>
        <div class="site-favicon">${escHtml(domainInitial(displayName))}</div>
        <div class="site-info">
          <div class="site-domain" title="${escHtml(d.domain)}">${escHtml(displayName)}</div>
          ${limitBarHTML}
        </div>
        <div class="site-time-col">
          <span class="site-time" style="${timeColorStyle}">${escHtml(formatSeconds(d.seconds))}</span>
          ${d.visits ? `<span class="site-visits">${escHtml(d.visits)}×</span>` : ''}
        </div>`);
      list.appendChild(row);
    });
  }

  // Section hint
  const hint = document.getElementById('sectionHint');
  hint.textContent = visibleDomains.length > 4 ? `+${visibleDomains.length - 4} more` : '';

  // ── Site + Focus tabs (rendered every cycle regardless of active tab)
  await renderSiteTab(state, storageData);
  renderFocusTab(state, settings, storageData);

  // ── Browser Identity & Sync card
  const identityCard   = document.getElementById('browserIdentityCard');
  const profileNameEl  = document.getElementById('browserProfileName');
  const profileIconEl  = document.getElementById('browserProfileIcon');
  const syncDot        = document.getElementById('syncDot');
  const syncLabel      = document.getElementById('syncLabel');
  const syncTime       = document.getElementById('syncTime');

  if (identityCard && mode !== 'standalone') {
    identityCard.style.display = 'flex';
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

    chrome.runtime.sendMessage({ type: 'GET_BROWSER_IDENTITY' }, (identity) => {
      if (chrome.runtime.lastError || !identity) return;
      if (profileIconEl) profileIconEl.textContent = getBrowserIconEmoji(identity.detectedBrowser);
      if (profileNameEl && document.getElementById('browserNameEdit')?.style.display === 'none') {
        profileNameEl.textContent = identity.effectiveName || `${identity.detectedBrowser}`;
      }
    });
  } else if (identityCard) {
    identityCard.style.display = 'none';
  }
}

function getBrowserIconEmoji(browserName) {
  switch (browserName) {
    case 'Chrome': return '🌐';
    case 'Firefox': return '🦊';
    case 'Edge': return '🌊';
    case 'Brave': return '🦁';
    case 'Opera': return '🔴';
    case 'Safari': return '🧭';
    default: return '🌐';
  }
}

// ─── Focus tab renderer ───────────────────────────────────────────────────────

// Total seconds for each phase (mirrors desktop defaults; updated from state)
const PHASE_DURATIONS = { work: 25 * 60, shortBreak: 5 * 60, longBreak: 15 * 60 };

// Phase durations mirrored from background.js
const LOCAL_FOCUS_DURATIONS_POPUP = { work: 25 * 60, shortBreak: 5 * 60, longBreak: 15 * 60 };

/** Apply a focus control action directly to scolect_local_focus in storage (standalone). */
async function applyLocalFocusControl(action) {
  const r = await chrome.storage.local.get('scolect_local_focus');
  const f = r['scolect_local_focus'] ?? { phase: 'work', running: false, pausedSecsLeft: null, startMs: null, endMs: null };
  const now = Date.now();
  let next = { ...f };

  if (action === 'start') {
    const total = LOCAL_FOCUS_DURATIONS_POPUP[f.phase] * 1000;
    next = { ...f, running: true, startMs: now, endMs: now + total, pausedSecsLeft: null };
  } else if (action === 'pause') {
    const secsLeft = f.endMs ? Math.max(0, Math.round((f.endMs - now) / 1000)) : 0;
    next = { ...f, running: false, pausedSecsLeft: secsLeft, endMs: null };
  } else if (action === 'resume') {
    const secsLeft = f.pausedSecsLeft ?? LOCAL_FOCUS_DURATIONS_POPUP[f.phase];
    next = { ...f, running: true, endMs: now + secsLeft * 1000, pausedSecsLeft: null };
  } else if (action === 'reset') {
    next = { phase: f.phase, running: false, pausedSecsLeft: null, startMs: null, endMs: null };
  } else if (action === 'skip_forward') {
    const nextPhase = f.phase === 'work' ? 'shortBreak' : 'work';
    const total = LOCAL_FOCUS_DURATIONS_POPUP[nextPhase] * 1000;
    next = { phase: nextPhase, running: true, startMs: now, endMs: now + total, pausedSecsLeft: null };
  } else if (action === 'skip_backward') {
    const total = LOCAL_FOCUS_DURATIONS_POPUP[f.phase] * 1000;
    next = { ...f, running: true, startMs: now, endMs: now + total, pausedSecsLeft: null };
  } else if (action.startsWith('phase_')) {
    const phase = action.replace('phase_', '');
    const total = LOCAL_FOCUS_DURATIONS_POPUP[phase] * 1000;
    next = { phase, running: true, startMs: now, endMs: now + total, pausedSecsLeft: null };
  }

  await chrome.storage.local.set({ 'scolect_local_focus': next });
}

/** Send a focus control action to the background service worker. */
async function sendFocusControl(action) {
  const raw = await chrome.storage.local.get('scolect_settings');
  const mode = raw['scolect_settings']?.mode ?? 'standalone';

  if (mode === 'standalone') {
    // Write directly to storage — don't depend on the SW being awake.
    await applyLocalFocusControl(action);
    // Also tell the SW to sync state (best-effort, may fail if still sleeping).
    chrome.runtime.sendMessage({ type: 'FOCUS_CONTROL', action }).catch(() => {});
  } else {
    chrome.runtime.sendMessage({ type: 'FOCUS_CONTROL', action }).catch(() => {});
  }

  // Re-render so the UI reflects the new state immediately.
  setTimeout(render, 150);
}

function renderFocusTab(state, settings, storageData) {
  const panel = document.getElementById('panelFocus');
  if (!panel) return;
  const mode  = settings?.mode ?? state?.mode ?? 'standalone';

  // ── Parse today's completed focus sessions from storage
  const todayStr    = getTodayDateString();
  const allSessions = storageData?.scolect_focus_sessions ?? [];
  const todaySessions = allSessions.filter(s => {
    if (!s.startTime) return false;
    const d   = new Date(s.startTime);
    const key = `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
    return key === todayStr;
  });

  // ── Live session state (from desktop WS push in hybrid/trackerOnly, or local timer in standalone)
  const focusActive    = state?.focusActive    ?? false;
  const sessionLabel   = state?.sessionLabel   ?? null;
  const endTimeEpochMs = state?.endTimeEpochMs ?? null;
  const isRunning      = focusActive && endTimeEpochMs !== null;
  // isPaused: local timer only — timer was started but is now paused (not idle)
  const localFocus  = storageData?.scolect_local_focus ?? null;
  const isPaused    = mode === 'standalone' && localFocus != null
    && !localFocus.running && localFocus.pausedSecsLeft != null;

  // Store endTime globally so the 1s ticker can update the ring + timer without
  // re-rendering the whole tab.
  _focusEndTimeMs = isRunning ? endTimeEpochMs : null;

  // ── Determine active phase from sessionLabel (or local focus phase when idle)
  const activePhase = sessionLabel === 'Short Break' ? 'shortBreak'
    : sessionLabel === 'Long Break'  ? 'longBreak'
    : (state?._localFocusPhase ?? 'work');

  // ── Today stats
  const totalFocusSecs = todaySessions.reduce((s, f) => s + (f.duration ?? 0), 0);
  const completedCount = todaySessions.filter(f => f.completed !== false).length;

  // ── Build control UI
  let controlHTML = '';

  {
    // Phase pills
    const phases = [
      { key: 'work',       label: 'Focus'       },
      { key: 'shortBreak', label: 'Short Break' },
      { key: 'longBreak',  label: 'Long Break'  },
    ];
    const pillsHTML = phases.map(p => `
      <button class="focus-phase-pill${p.key === activePhase ? ' active' : ''}"
              data-action="phase_${p.key}">${p.label}</button>`
    ).join('');

    // Circular ring
    const RING_R   = 52;
    const RING_C   = 2 * Math.PI * RING_R; // ≈ 326.7
    let secsLeft   = 0;
    let totalSecs  = PHASE_DURATIONS[activePhase];
    if (isRunning) {
      secsLeft = Math.max(0, Math.round((endTimeEpochMs - Date.now()) / 1000));
    } else if (isPaused) {
      secsLeft = localFocus.pausedSecsLeft ?? 0;
    }
    const elapsed  = Math.max(0, totalSecs - secsLeft);
    const progress = totalSecs > 0 ? Math.min(elapsed / totalSecs, 1) : 0;
    const ringOffset = (RING_C * (1 - progress)).toFixed(2);

    const mm = String(Math.floor(secsLeft / 60)).padStart(2, '0');
    const ss = String(secsLeft % 60).padStart(2, '0');

    const phaseLabel = sessionLabel
      ?? (isPaused ? ({ work: 'Work Session', shortBreak: 'Short Break', longBreak: 'Long Break' }[localFocus?.phase] ?? 'Paused') : 'Ready');
    const sessionDotHTML = isRunning
      ? `<div class="focus-ring-status-dot"></div>`
      : '';

    const ringHTML = `
      <div class="focus-ring-wrap">
        <svg class="focus-ring-svg" width="132" height="132" viewBox="0 0 132 132">
          <circle class="focus-ring-track" cx="66" cy="66" r="${RING_R}" fill="none" stroke-width="7"/>
          <circle class="focus-ring-fill" id="focusRingFill" cx="66" cy="66" r="${RING_R}" fill="none" stroke-width="7"
            stroke-dasharray="${RING_C.toFixed(2)}" stroke-dashoffset="${ringOffset}"
            stroke-linecap="round" transform="rotate(-90 66 66)"/>
        </svg>
        <div class="focus-ring-center">
          ${sessionDotHTML}
          <div class="focus-ring-timer" id="focusLiveTimer">${mm}:${ss}</div>
          <div class="focus-ring-label">${phaseLabel}</div>
        </div>
      </div>`;

    // Control buttons
    const playIcon = isRunning
      ? `<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><rect x="6" y="4" width="4" height="16" rx="1"/><rect x="14" y="4" width="4" height="16" rx="1"/></svg>`
      : `<svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M5 3l14 9-14 9V3z"/></svg>`;
    const playAction = isRunning ? 'pause' : (isPaused ? 'resume' : 'start');

    const ctrlHTML = `
      <div class="focus-controls">
        <div class="focus-controls-main">
          <button class="focus-ctrl-btn" id="fcSkipBack" title="Skip back">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polygon points="19 20 9 12 19 4 19 20"/><line x1="5" y1="19" x2="5" y2="5"/>
            </svg>
          </button>
          <button class="focus-ctrl-btn primary" id="fcPlayPause" title="${isRunning ? 'Pause' : 'Play'}">
            ${playIcon}
          </button>
          <button class="focus-ctrl-btn" id="fcSkipFwd" title="Skip forward">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polygon points="5 4 15 12 5 20 5 4"/><line x1="19" y1="5" x2="19" y2="19"/>
            </svg>
          </button>
        </div>
        <button class="focus-ctrl-btn reset" id="fcReset" title="Reset">
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/>
            <path d="M3 3v5h5"/>
          </svg>
        </button>
      </div>`;

    controlHTML = `
      <div class="focus-control-card">
        <div class="focus-phase-pills">${pillsHTML}</div>
        ${ringHTML}
        ${ctrlHTML}
      </div>`;
  }

  const statsHTML = `
    <div class="focus-stats-row">
      <div class="focus-stat-card">
        <div class="focus-stat-value">${todaySessions.length}</div>
        <div class="focus-stat-label">Sessions today</div>
      </div>
      <div class="focus-stat-card">
        <div class="focus-stat-value">${formatSeconds(totalFocusSecs)}</div>
        <div class="focus-stat-label">Focus time</div>
      </div>
      <div class="focus-stat-card">
        <div class="focus-stat-value">${completedCount}</div>
        <div class="focus-stat-label">Completed</div>
      </div>
    </div>`;

  // ── Session history (most recent first, max 5)
  let historyHTML = '';
  if (todaySessions.length > 0) {
    const recent = [...todaySessions].reverse().slice(0, 5);
    const rows = recent.map(s => {
      const start = s.startTime ? new Date(s.startTime) : null;
      const timeStr = start
        ? start.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
        : '—';
      const durStr = formatSeconds(s.duration ?? 0);
      const dotClass = s.completed !== false ? 'completed' : 'incomplete';
      const tag = (s.appsBlocked ?? [])[0] ?? '';
      const typeLabel = tag.includes('WORK') ? 'Work'
        : tag.includes('SHORT') ? 'Short Break'
        : tag.includes('LONG')  ? 'Long Break'
        : 'Focus';
      return `
        <div class="focus-session-row">
          <div class="focus-session-dot ${dotClass}"></div>
          <div class="focus-session-info">
            <div class="focus-session-type">${typeLabel}</div>
            <div class="focus-session-time">${timeStr}</div>
          </div>
          <div class="focus-session-dur">${durStr}</div>
        </div>`;
    }).join('');

    historyHTML = `
      <div class="focus-history-header">Today's Sessions</div>
      <div class="focus-session-list">${rows}</div>`;
  }

  setCleanHTML(panel, controlHTML + statsHTML + historyHTML);

  // ── Wire up control buttons
  document.getElementById('fcPlayPause')?.addEventListener('click', () => {
    sendFocusControl(isRunning ? 'pause' : (isPaused ? 'resume' : 'start'));
  });
  document.getElementById('fcSkipBack')?.addEventListener('click', () => sendFocusControl('skip_backward'));
  document.getElementById('fcSkipFwd')?.addEventListener('click',  () => sendFocusControl('skip_forward'));
  document.getElementById('fcReset')?.addEventListener('click',    () => sendFocusControl('reset'));

  // Phase pills — clicking navigates to that phase
  document.querySelectorAll('.focus-phase-pill').forEach(btn => {
    btn.addEventListener('click', () => {
      const action = btn.dataset.action; // e.g. "phase_work"
      sendFocusControl(action);
    });
  });
}

// ─── Actions ──────────────────────────────────────────────────────────────────

document.getElementById('tabOverview').addEventListener('click', () => switchTab('overview'));
document.getElementById('tabSite').addEventListener('click', () => switchTab('site'));
// document.getElementById('tabFocus').addEventListener('click', () => switchTab('focus'));

document.getElementById('openDashBtn').addEventListener('click', () => {
  chrome.tabs.create({ url: chrome.runtime.getURL('index.html') });
  window.close();
});

document.getElementById('settingsBtn').addEventListener('click', () => {
  chrome.tabs.create({ url: chrome.runtime.getURL('index.html?tab=settings') });
  window.close();
});

// ─── Browser profile rename handlers ──────────────────────────────────────────
const renameBtn = document.getElementById('browserRenameBtn');
const nameDisplay = document.getElementById('browserNameDisplay');
const nameEdit = document.getElementById('browserNameEdit');
const nameInput = document.getElementById('browserNameInput');
const nameSave = document.getElementById('browserNameSave');
const nameCancel = document.getElementById('browserNameCancel');

if (renameBtn && nameDisplay && nameEdit && nameInput && nameSave && nameCancel) {
  renameBtn.addEventListener('click', () => {
    chrome.runtime.sendMessage({ type: 'GET_BROWSER_IDENTITY' }, (identity) => {
      nameInput.value = identity?.customName || identity?.assignedLabel || '';
      nameDisplay.style.display = 'none';
      nameEdit.style.display = 'flex';
      nameInput.focus();
      nameInput.select();
    });
  });

  const saveName = () => {
    const val = nameInput.value.trim();
    chrome.runtime.sendMessage({ type: 'SET_BROWSER_NAME', name: val }, () => {
      nameDisplay.style.display = 'flex';
      nameEdit.style.display = 'none';
      render();
    });
  };

  nameSave.addEventListener('click', saveName);
  nameInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') saveName();
    if (e.key === 'Escape') {
      nameDisplay.style.display = 'flex';
      nameEdit.style.display = 'none';
    }
  });
  nameCancel.addEventListener('click', () => {
    nameDisplay.style.display = 'flex';
    nameEdit.style.display = 'none';
  });
}

// ─── Init ─────────────────────────────────────────────────────────────────────

applyTheme().then(() => render());

// Auto-refresh every 5 seconds while popup is open
setInterval(render, 5000);

// 1-second ticker for the live focus countdown — patches timer text and ring
// fill without re-rendering the entire Focus tab.
setInterval(() => {
  if (_focusEndTimeMs === null) return;
  const timerEl = document.getElementById('focusLiveTimer');
  if (!timerEl) return;

  const secsLeft = Math.max(0, Math.round((_focusEndTimeMs - Date.now()) / 1000));
  const mm = String(Math.floor(secsLeft / 60)).padStart(2, '0');
  const ss = String(secsLeft % 60).padStart(2, '0');
  timerEl.textContent = `${mm}:${ss}`;

  // Also update the ring progress
  const ringEl = document.getElementById('focusRingFill');
  if (ringEl) {
    const RING_R = 52;
    const RING_C = 2 * Math.PI * RING_R;
    // Determine total phase duration from the ring's current dash-array
    const dashArray = parseFloat(ringEl.getAttribute('stroke-dasharray') || String(RING_C));
    // We don't have totalSecs here, so derive from PHASE_DURATIONS using the label
    const labelEl = timerEl.nextElementSibling; // .focus-ring-label
    const label   = labelEl?.textContent ?? '';
    const totalSecs = label === 'Short Break' ? PHASE_DURATIONS.shortBreak
      : label === 'Long Break' ? PHASE_DURATIONS.longBreak
      : PHASE_DURATIONS.work;
    const elapsed  = Math.max(0, totalSecs - secsLeft);
    const progress = totalSecs > 0 ? Math.min(elapsed / totalSecs, 1) : 0;
    ringEl.setAttribute('stroke-dashoffset', (RING_C * (1 - progress)).toFixed(2));
  }
}, 1000);
