(async function () {
  // ── Helpers ────────────────────────────────────────────────────────────
  function fmtDuration(seconds) {
    if (!seconds || seconds <= 0) return '0s';
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = Math.round(seconds % 60);
    if (h > 0) return m > 0 ? `${h}h ${m}m` : `${h}h`;
    if (m > 0) return `${m}m`;
    return `${s}s`;
  }

  function getTodayKey() {
    const d = new Date();
    const y = d.getFullYear();
    const mo = String(d.getMonth() + 1).padStart(2, '0');
    const da = String(d.getDate()).padStart(2, '0');
    return `${y}-${mo}-${da}`;
  }

  function secondsUntilMidnight() {
    const now = new Date();
    const midnight = new Date(now);
    midnight.setHours(24, 0, 0, 0);
    return Math.floor((midnight - now) / 1000);
  }

  function fmtCountdown(s) {
    const h = Math.floor(s / 3600);
    const m = Math.floor((s % 3600) / 60);
    const sec = s % 60;
    if (h > 0) return `${h}h ${m}m`;
    if (m > 0) return `${m}m ${sec}s`;
    return `${sec}s`;
  }

  // ── Countdown to midnight ─────────────────────────────────────────────
  function updateCountdown() {
    const s = secondsUntilMidnight();
    const el = document.getElementById('countdown');
    if (el) el.textContent = fmtCountdown(s);
  }
  updateCountdown();
  setInterval(updateCountdown, 1000);

  // ── Parse domain from URL ─────────────────────────────────────────────
  const params = new URLSearchParams(location.search);
  const domain = params.get('domain') || '';

  const domainLabel = document.getElementById('domain-label');
  if (domain) {
    if (domainLabel) domainLabel.textContent = domain;
    document.title = domain + ' – Blocked · Scolect';
  }

  // ── Open dashboard button ─────────────────────────────────────────────
  const dashBtn = document.getElementById('btn-dash');
  if (dashBtn) {
    dashBtn.addEventListener('click', () => {
      chrome.tabs.create({ url: chrome.runtime.getURL('index.html') });
    });
  }

  // ── Unblock confirmation ───────────────────────────────────────────────
  let confirmWord = domain; // fallback to domain
  const panel = document.getElementById('unblock-panel');
  const input = document.getElementById('unblock-input');
  const confirmBtn = document.getElementById('btn-confirm-unblock');
  const confirmHint = document.getElementById('confirm-hint');
  const unblockToggle = document.getElementById('btn-unblock-toggle');

  if (unblockToggle && panel) {
    unblockToggle.addEventListener('click', () => {
      panel.classList.toggle('visible');
      if (panel.classList.contains('visible') && input) input.focus();
    });
  }

  function setConfirmWord(name) {
    confirmWord = name;
    if (confirmHint) confirmHint.textContent = name;
    if (input) input.placeholder = name;
  }

  if (input && confirmBtn) {
    input.addEventListener('input', () => {
      const match = input.value.trim().toLowerCase() === confirmWord.toLowerCase();
      confirmBtn.disabled = !match;
      input.classList.remove('error');
    });

    input.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && !confirmBtn.disabled) confirmBtn.click();
    });

    confirmBtn.addEventListener('click', async () => {
      if (typeof chrome === 'undefined' || !chrome.storage) return;

      const result = await chrome.storage.local.get(['scolect_blocked_domains']);
      const blocked = (result['scolect_blocked_domains'] || []).filter(d => d !== domain);
      await chrome.storage.local.set({ scolect_blocked_domains: blocked });

      const unblockKey = 'scolect_unblocked_today';
      const unblockResult = await chrome.storage.local.get([unblockKey]);
      const unblockedToday = unblockResult[unblockKey] || {};
      unblockedToday[domain] = new Date().toDateString();
      await chrome.storage.local.set({ [unblockKey]: unblockedToday });

      chrome.runtime.sendMessage({ type: 'UNBLOCK_DOMAIN', domain }, () => {
        window.location.href = 'https://' + domain;
      });
    });
  }

  function colorIntToHex(intVal) {
    if (intVal === undefined || intVal === null) return null;
    const r = (intVal >> 16) & 0xFF;
    const g = (intVal >> 8) & 0xFF;
    const b = intVal & 0xFF;
    return '#' + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
  }

  function colorIntToRgba(intVal, alphaOverride) {
    if (intVal === undefined || intVal === null) return null;
    const a = alphaOverride !== undefined ? alphaOverride : (((intVal >> 24) & 0xFF) / 255);
    const r = (intVal >> 16) & 0xFF;
    const g = (intVal >> 8) & 0xFF;
    const b = intVal & 0xFF;
    return `rgba(${r}, ${g}, ${b}, ${typeof a === 'number' ? a.toFixed(2) : a})`;
  }

  // ── Load theme and stats asynchronously from chrome.storage ───────────
  if (typeof chrome !== 'undefined' && chrome.storage && chrome.storage.local) {
    try {
      // Fetch ALL items in storage for 100% reliable matching
      const all = await chrome.storage.local.get(null);

      // 1. Sync Theme
      if (all?.scolect_theme_colors) {
        const tc = all.scolect_theme_colors;
        const bg = colorIntToHex(tc.darkBackground);
        const cardBg = colorIntToHex(tc.darkSurface);
        const accent = colorIntToHex(tc.primaryAccent);
        const accentGrad = colorIntToHex(tc.secondaryAccent);
        const border = colorIntToRgba(tc.darkBorder);
        const accentAlpha = colorIntToRgba(tc.primaryAccent, 0.15);

        if (bg) document.documentElement.style.setProperty('--bg', bg);
        if (cardBg) document.documentElement.style.setProperty('--card-bg', cardBg);
        if (accent) document.documentElement.style.setProperty('--accent', accent);
        if (accentGrad) document.documentElement.style.setProperty('--accent-grad', accentGrad);
        if (accentAlpha) document.documentElement.style.setProperty('--accent-alpha', accentAlpha);
        if (border) document.documentElement.style.setProperty('--accent-border', border);
        if (accentGrad || accent) document.documentElement.style.setProperty('--accent-text', accentGrad || accent);
      } else if (all?.scolect_theme_id) {
        document.body.dataset.theme = all.scolect_theme_id;
      }

      // 2. Resolve metadata (matching domain, www.domain, or domain without www.)
      const settings = all.scolect_settings || {};
      const metadata = settings.metadata || {};
      const appMeta = all.scolect_app_metadata || {};

      const cleanDomain = domain.replace(/^www\./, '').toLowerCase();
      const meta = metadata[domain] || metadata['www.' + cleanDomain] || metadata[cleanDomain];
      const siteName = meta?.siteName || appMeta[domain]?.siteName || appMeta[cleanDomain]?.siteName || domain;

      if (domainLabel) domainLabel.textContent = siteName;
      setConfirmWord(siteName);

      const limitSecs = meta?.dailyLimitSeconds || 0;

      // 3. Find stats in today's day key or most recent day key
      const todayStr = getTodayKey();
      const dayKeys = Object.keys(all).filter(k => k.startsWith('scolect_day_')).sort().reverse();

      let entry = null;
      const matchDomain = (d) => {
        if (!d) return false;
        const c = d.replace(/^www\./, '').toLowerCase();
        return c === cleanDomain;
      };

      // Check today's key first
      const todayData = all[`scolect_day_${todayStr}`];
      if (todayData?.domains) {
        entry = todayData.domains.find(d => matchDomain(d.domain));
      }

      // Fallback to recent day keys if not found in today's key
      if (!entry && dayKeys.length > 0) {
        for (const dk of dayKeys) {
          const dayObj = all[dk];
          if (dayObj?.domains) {
            entry = dayObj.domains.find(d => matchDomain(d.domain));
            if (entry) break;
          }
        }
      }

      const spentSecs = entry?.seconds || 0;
      const visitsCount = entry?.visits || 0;

      const spentEl = document.getElementById('stat-spent');
      const visitsEl = document.getElementById('stat-visits');
      const limitEl = document.getElementById('stat-limit');

      if (spentEl) spentEl.textContent = fmtDuration(spentSecs);
      if (visitsEl) visitsEl.textContent = String(visitsCount);
      if (limitEl) {
        limitEl.textContent = limitSecs > 0 ? fmtDuration(limitSecs) : (spentSecs > 0 ? fmtDuration(spentSecs) : '0s');
      }
    } catch (err) {
      console.error('Error loading blocked page storage data:', err);
    }
  }
})();
