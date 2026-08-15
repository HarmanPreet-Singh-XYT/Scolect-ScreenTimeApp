// Scolect – content script for block overlay injection
// Injected into all pages. Listens for SHOW_BLOCK_OVERLAY / HIDE_BLOCK_OVERLAY messages
// from the background service worker.

(function () {
  const OVERLAY_ID = '__scolect_block_overlay__';

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

  function fmtDuration(seconds) {
    if (!seconds || seconds <= 0) return '0s';
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = Math.round(seconds % 60);
    if (h > 0) return m > 0 ? `${h}h ${m}m` : `${h}h`;
    if (m > 0) return `${m}m`;
    return `${s}s`;
  }

  function fmtCountdown(s) {
    const h = Math.floor(s / 3600);
    const m = Math.floor((s % 3600) / 60);
    const sec = s % 60;
    if (h > 0) return `${h}h ${m}m`;
    if (m > 0) return `${m}m ${sec}s`;
    return `${sec}s`;
  }

  function secondsUntilMidnight() {
    const now = new Date();
    const midnight = new Date(now);
    midnight.setHours(24, 0, 0, 0);
    return Math.floor((midnight - now) / 1000);
  }

  function colorIntToHex(v) {
    if (v == null) return null;
    const r = (v >> 16) & 0xFF;
    const g = (v >> 8) & 0xFF;
    const b = v & 0xFF;
    return '#' + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
  }

  function colorIntToRgba(v, alpha) {
    if (v == null) return null;
    const a = alpha !== undefined ? alpha : (((v >> 24) & 0xFF) / 255);
    const r = (v >> 16) & 0xFF;
    const g = (v >> 8) & 0xFF;
    const b = v & 0xFF;
    return `rgba(${r},${g},${b},${typeof a === 'number' ? a.toFixed(2) : a})`;
  }

  // ── CSS vars from theme ────────────────────────────────────────────────────

  function buildThemeVars(themeColors, themeId) {
    const themes = {
      purple_dream: {
        accent: '#a855f7', accentGrad: '#ec4899',
        accentAlpha: 'rgba(168,85,247,0.15)', accentBorder: 'rgba(168,85,247,0.3)',
        accentText: '#c084fc',
      },
      ocean_blue: {
        accent: '#38bdf8', accentGrad: '#818cf8',
        accentAlpha: 'rgba(56,189,248,0.15)', accentBorder: 'rgba(56,189,248,0.3)',
        accentText: '#7dd3fc',
      },
      forest_green: {
        accent: '#34d399', accentGrad: '#a3e635',
        accentAlpha: 'rgba(52,211,153,0.15)', accentBorder: 'rgba(52,211,153,0.3)',
        accentText: '#6ee7b7',
      },
      sunset_orange: {
        accent: '#fb923c', accentGrad: '#f43f5e',
        accentAlpha: 'rgba(251,146,60,0.15)', accentBorder: 'rgba(251,146,60,0.3)',
        accentText: '#fdba74',
      },
      monochrome: {
        accent: '#94a3b8', accentGrad: '#cbd5e1',
        accentAlpha: 'rgba(148,163,184,0.15)', accentBorder: 'rgba(148,163,184,0.3)',
        accentText: '#cbd5e1',
      },
    };

    if (themeColors) {
      return {
        accent: colorIntToHex(themeColors.primaryAccent) || '#6B4EFF',
        accentGrad: colorIntToHex(themeColors.secondaryAccent) || '#9b7dff',
        accentAlpha: colorIntToRgba(themeColors.primaryAccent, 0.15) || 'rgba(107,78,255,0.15)',
        accentBorder: colorIntToRgba(themeColors.darkBorder) || 'rgba(107,78,255,0.22)',
        accentText: colorIntToHex(themeColors.secondaryAccent) || '#a78bff',
      };
    }
    return themes[themeId] || {
      accent: '#6B4EFF', accentGrad: '#9b7dff',
      accentAlpha: 'rgba(107,78,255,0.12)', accentBorder: 'rgba(107,78,255,0.22)',
      accentText: '#a78bff',
    };
  }

  // ── Overlay DOM ────────────────────────────────────────────────────────────

  function buildOverlay(data) {
    const { domain, siteName, spentSecs, limitSecs, visits, themeColors, themeId, strings } = data;
    const t = buildThemeVars(themeColors, themeId);
    const s = {
      badge: 'Scolect Screen Time',
      title: 'Daily Limit Reached',
      timeSpent: 'Time spent',
      dailyLimit: 'Daily limit',
      visitsToday: 'Visits today',
      resetsIn: 'Resets in',
      goBack: 'Go Back',
      openDashboard: 'Open Dashboard',
      unblockToday: 'Unblock for today',
      unblockConfirmLabel: 'Type {siteName} to unblock for the rest of today:',
      unblockButton: 'Unblock',
      footer: 'Scolect · screen time tracker',
      ...strings,
    };

    const wrapper = document.createElement('div');
    wrapper.id = OVERLAY_ID;

    const shadow = wrapper.attachShadow({ mode: 'closed' });

    const style = document.createElement('style');
    style.textContent = `
      :host {
        all: initial;
        position: fixed;
        inset: 0;
        z-index: 2147483647;
        display: flex;
        align-items: center;
        justify-content: center;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      }

      .scrim {
        position: absolute;
        inset: 0;
        background: rgba(0, 0, 0, 0.55);
        backdrop-filter: blur(18px) saturate(0.6);
        -webkit-backdrop-filter: blur(18px) saturate(0.6);
      }

      .card {
        position: relative;
        z-index: 1;
        text-align: center;
        padding: 40px 48px;
        background: #16161f;
        border-radius: 20px;
        border: 1px solid ${t.accentBorder};
        box-shadow: 0 8px 48px rgba(0,0,0,0.6), 0 0 0 1px ${t.accentAlpha};
        max-width: 440px;
        width: 90vw;
        color: #e8e8f0;
        animation: fadeUp 0.22s ease;
      }

      @keyframes fadeUp {
        from { opacity: 0; transform: translateY(12px) scale(0.97); }
        to   { opacity: 1; transform: translateY(0) scale(1); }
      }

      .header {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 14px;
        margin-bottom: 16px;
      }

      .icon-wrap {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 80px;
        height: 80px;
        border-radius: 50%;
        background: ${t.accentAlpha};
        border: 1px solid ${t.accentBorder};
      }

      .icon-wrap svg { width: 40px; height: 40px; }

      .badge {
        display: inline-block;
        font-size: 10px;
        font-weight: 700;
        letter-spacing: 0.08em;
        text-transform: uppercase;
        color: ${t.accent};
        background: ${t.accentAlpha};
        border: 1px solid ${t.accentBorder};
        border-radius: 6px;
        padding: 3px 10px;
      }

      h1 {
        font-size: 24px;
        font-weight: 700;
        letter-spacing: -0.3px;
        color: #fff;
        margin: 0 0 6px;
      }

      .domain {
        font-size: 14px;
        font-weight: 600;
        color: ${t.accent};
        margin-bottom: 18px;
        word-break: break-all;
      }

      .divider {
        width: 44px;
        height: 3px;
        background: linear-gradient(90deg, ${t.accent}, ${t.accentGrad});
        border-radius: 2px;
        margin: 0 auto 20px;
      }

      .stats {
        display: flex;
        gap: 1px;
        background: ${t.accentAlpha};
        border: 1px solid ${t.accentBorder};
        border-radius: 12px;
        overflow: hidden;
        margin-bottom: 18px;
      }

      .stat {
        flex: 1;
        padding: 12px 10px;
        background: #16161f;
      }

      .stat + .stat { border-left: 1px solid ${t.accentBorder}; }

      .stat-value {
        font-size: 17px;
        font-weight: 700;
        color: #fff;
        margin-bottom: 3px;
      }

      .stat-label {
        font-size: 10px;
        color: rgba(136,136,160,0.9);
        font-weight: 500;
        text-transform: uppercase;
        letter-spacing: 0.05em;
      }

      .reset-row {
        font-size: 12px;
        color: #8888a0;
        margin-bottom: 24px;
      }

      .reset-row strong { color: ${t.accentText}; font-weight: 600; }

      .btn-group {
        display: flex;
        gap: 8px;
        justify-content: center;
        flex-wrap: wrap;
      }

      button {
        padding: 10px 20px;
        border-radius: 10px;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        transition: opacity 0.15s, transform 0.1s;
        border: none;
        font-family: inherit;
      }

      button:active { transform: scale(0.97); }

      .btn-back {
        background: ${t.accent};
        color: #fff;
      }
      .btn-back:hover { opacity: 0.88; }

      .btn-dashboard {
        background: ${t.accentAlpha};
        color: ${t.accentText};
        border: 1px solid ${t.accentBorder};
      }
      .btn-dashboard:hover { opacity: 0.88; }

      .btn-unblock {
        background: transparent;
        color: #555568;
        border: 1px solid rgba(255,255,255,0.06);
        font-size: 12px;
        padding: 9px 16px;
      }
      .btn-unblock:hover { color: #8888a0; border-color: rgba(255,255,255,0.12); }

      .unblock-panel {
        display: none;
        margin-top: 18px;
        padding: 18px;
        background: rgba(255,80,80,0.06);
        border: 1px solid rgba(255,80,80,0.18);
        border-radius: 12px;
        text-align: left;
      }
      .unblock-panel.visible { display: block; }

      .unblock-panel label {
        display: block;
        font-size: 12px;
        color: #8888a0;
        margin-bottom: 10px;
        line-height: 1.5;
      }
      .unblock-panel label strong { color: #e8e8f0; }

      .unblock-input-row { display: flex; gap: 8px; }

      .unblock-input {
        flex: 1;
        background: #0e0e14;
        border: 1px solid rgba(255,255,255,0.1);
        border-radius: 8px;
        color: #e8e8f0;
        font-size: 12px;
        padding: 8px 10px;
        outline: none;
        transition: border-color 0.15s;
        font-family: inherit;
      }
      .unblock-input:focus { border-color: rgba(107,78,255,0.5); }
      .unblock-input.error { border-color: rgba(255,80,80,0.6); animation: shake 0.3s; }

      @keyframes shake {
        0%,100% { transform: translateX(0); }
        25%      { transform: translateX(-6px); }
        75%      { transform: translateX(6px); }
      }

      .btn-confirm-unblock {
        background: rgba(255,80,80,0.15);
        color: #ff7070;
        border: 1px solid rgba(255,80,80,0.25);
        border-radius: 8px;
        font-size: 12px;
        font-weight: 600;
        padding: 8px 14px;
        cursor: pointer;
        white-space: nowrap;
        transition: background 0.15s;
        font-family: inherit;
      }
      .btn-confirm-unblock:hover { background: rgba(255,80,80,0.25); }
      .btn-confirm-unblock:disabled { opacity: 0.4; cursor: default; }

      .footer {
        margin-top: 20px;
        font-size: 10px;
        color: rgba(136,136,160,0.5);
        letter-spacing: 0.04em;
        text-transform: uppercase;
      }
    `;

    const card = document.createElement('div');
    setCleanHTML(card, `
      <div class="scrim"></div>
      <div class="card">
        <div class="header">
          <div class="icon-wrap">
            <svg viewBox="0 0 44 44" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M22 4L6 10v10c0 9.375 6.8 18.15 16 20.25C31.2 38.15 38 29.375 38 20V10L22 4z"
                    fill="rgba(107,78,255,0.22)" stroke="${escHtml(t.accent)}" stroke-width="2" stroke-linejoin="round"/>
              <rect x="16" y="20" width="12" height="9" rx="2" fill="none" stroke="${escHtml(t.accentText)}" stroke-width="1.8"/>
              <path d="M18.5 20v-2.5a3.5 3.5 0 0 1 7 0V20" stroke="${escHtml(t.accentText)}" stroke-width="1.8" stroke-linecap="round"/>
              <circle cx="22" cy="24.5" r="1.3" fill="${escHtml(t.accentText)}"/>
            </svg>
          </div>
          <div class="badge">${escHtml(s.badge)}</div>
        </div>
        <h1>${escHtml(s.title)}</h1>
        <div class="domain">${escHtml(siteName || domain)}</div>
        <div class="divider"></div>

        <div class="stats">
          <div class="stat">
            <div class="stat-value">${escHtml(fmtDuration(spentSecs))}</div>
            <div class="stat-label">${escHtml(s.timeSpent)}</div>
          </div>
          <div class="stat">
            <div class="stat-value">${escHtml(limitSecs > 0 ? fmtDuration(limitSecs) : fmtDuration(spentSecs))}</div>
            <div class="stat-label">${escHtml(s.dailyLimit)}</div>
          </div>
          <div class="stat">
            <div class="stat-value">${escHtml(visits)}</div>
            <div class="stat-label">${escHtml(s.visitsToday)}</div>
          </div>
        </div>

        <div class="reset-row">${escHtml(s.resetsIn)} <strong id="scolect-countdown">–</strong></div>

        <div class="btn-group">
          <button class="btn-back" id="scolect-btn-back">${escHtml(s.goBack)}</button>
          <button class="btn-dashboard" id="scolect-btn-dash">${escHtml(s.openDashboard)}</button>
          <button class="btn-unblock" id="scolect-btn-unblock-toggle">${escHtml(s.unblockToday)}</button>
        </div>

        <div class="unblock-panel" id="scolect-unblock-panel">
          <label>${escHtml(s.unblockConfirmLabel).replace('{siteName}', `<strong id="scolect-confirm-hint">${escHtml(siteName || domain)}</strong>`)}</label>
          <div class="unblock-input-row">
            <input class="unblock-input" id="scolect-unblock-input" type="text"
                   placeholder="${escHtml(siteName || domain)}" autocomplete="off" spellcheck="false" />
            <button class="btn-confirm-unblock" id="scolect-btn-confirm" disabled>${escHtml(s.unblockButton)}</button>
          </div>
        </div>

        <div class="footer">${escHtml(s.footer)}</div>
      </div>
    `);

    shadow.appendChild(style);
    shadow.appendChild(card);

    // Wire up countdown
    const countdownEl = shadow.getElementById('scolect-countdown');
    function tick() {
      if (countdownEl) countdownEl.textContent = fmtCountdown(secondsUntilMidnight());
    }
    tick();
    const countdownInterval = setInterval(tick, 1000);

    // Go Back
    shadow.getElementById('scolect-btn-back').addEventListener('click', () => {
      if (history.length > 1) history.back();
      else window.close();
    });

    // Open Dashboard
    shadow.getElementById('scolect-btn-dash').addEventListener('click', () => {
      chrome.runtime.sendMessage({ type: 'OPEN_DASHBOARD' });
    });

    // Unblock toggle
    const panel = shadow.getElementById('scolect-unblock-panel');
    shadow.getElementById('scolect-btn-unblock-toggle').addEventListener('click', () => {
      panel.classList.toggle('visible');
      if (panel.classList.contains('visible')) {
        shadow.getElementById('scolect-unblock-input').focus();
      }
    });

    // Unblock confirm
    const confirmWord = (siteName || domain).toLowerCase();
    const input = shadow.getElementById('scolect-unblock-input');
    const confirmBtn = shadow.getElementById('scolect-btn-confirm');

    input.addEventListener('input', () => {
      confirmBtn.disabled = input.value.trim().toLowerCase() !== confirmWord;
      input.classList.remove('error');
    });

    input.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && !confirmBtn.disabled) confirmBtn.click();
    });

    confirmBtn.addEventListener('click', async () => {
      if (input.value.trim().toLowerCase() !== confirmWord) {
        input.classList.add('error');
        return;
      }

      // Update storage then notify background
      const result = await chrome.storage.local.get(['scolect_blocked_domains']);
      const blocked = (result['scolect_blocked_domains'] || []).filter(d => d !== domain);
      await chrome.storage.local.set({ scolect_blocked_domains: blocked });

      const unblockKey = 'scolect_unblocked_today';
      const unblockResult = await chrome.storage.local.get([unblockKey]);
      const unblockedToday = unblockResult[unblockKey] || {};
      unblockedToday[domain] = new Date().toDateString();
      await chrome.storage.local.set({ [unblockKey]: unblockedToday });

      chrome.runtime.sendMessage({ type: 'UNBLOCK_DOMAIN', domain }, () => {
        clearInterval(countdownInterval);
        removeOverlay();
      });
    });

    wrapper._cleanup = () => clearInterval(countdownInterval);
    return wrapper;
  }

  function removeOverlay() {
    const existing = document.getElementById(OVERLAY_ID);
    if (existing) {
      if (existing._cleanup) existing._cleanup();
      existing.remove();
    }
  }

  // ── Message listener ───────────────────────────────────────────────────────

  chrome.runtime.onMessage.addListener((msg, _sender, sendResponse) => {
    if (msg.type === 'SHOW_BLOCK_OVERLAY') {
      // Don't double-inject
      if (document.getElementById(OVERLAY_ID)) return;
      const overlay = buildOverlay(msg);
      document.documentElement.appendChild(overlay);
    }
    if (msg.type === 'HIDE_BLOCK_OVERLAY') {
      removeOverlay();
    }
    if (msg.type === 'CHECK_MEDIA_PLAYING') {
      const playing = [...document.querySelectorAll('video, audio')]
        .some(el => !el.paused && !el.ended && (el.readyState >= 2 || el.currentTime > 0));
      sendResponse({ playing });
      return true;
    }
  });

  // On script injection, check immediately if this tab's domain is blocked
  chrome.runtime.sendMessage({ type: 'CHECK_BLOCK_STATUS', url: location.href }, (response) => {
    if (chrome.runtime.lastError) return; // tab not ready etc.
    if (response && response.blocked && !document.getElementById(OVERLAY_ID)) {
      const overlay = buildOverlay(response);
      document.documentElement.appendChild(overlay);
    }
  });
})();
