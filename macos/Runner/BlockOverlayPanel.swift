import Cocoa

// MARK: - BlockOverlayPanel
//
// Soft block — two-panel design (original):
//   scrimPanel  — full-size borderless panel at normalWindow level, semi-transparent dark fill
//   cardPanel   — small borderless panel at floatingWindow level, hosts the NSVisualEffectView card
//   Clicking the scrim activates the blocked app so it comes back to front.
//
// Hard block — single-panel design:
//   scrimPanel  — full-screen panel at screenSaverWindow level
//   Card embedded as a subview inside the scrim (avoids z-order conflict on click)
//   Blocked app is hidden after 0.3s; observer watches for intentional app switch to dismiss.

private class ScrimView: NSView {
    var onTap: (() -> Void)?
    weak var cardPanel: NSPanel?   // soft block only — re-raised on every click

    override func mouseDown(with event: NSEvent) {
        if let cp = cardPanel, let sp = self.window {
            cp.order(.above, relativeTo: sp.windowNumber)
        }
        onTap?()
    }
    override func rightMouseDown(with event: NSEvent) {
        if let cp = cardPanel, let sp = self.window {
            cp.order(.above, relativeTo: sp.windowNumber)
        }
        onTap?()
    }
    override var acceptsFirstResponder: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        let path = NSBezierPath(roundedRect: bounds, xRadius: 20, yRadius: 20)
        NSColor.black.withAlphaComponent(0.52).setFill()
        path.fill()
    }
}

final class BlockOverlayPanel {

    static let shared = BlockOverlayPanel()
    private init() {}

    // ── State ─────────────────────────────────────────────────────────────

    private var scrimPanel: NSPanel?
    private var cardPanel: NSPanel?        // nil in hard block (card is a subview)
    private var trackingTimer: Timer?      // soft block only
    private var targetPid: pid_t = 0
    private var graceTimer: Timer?
    private var graceSecondsLeft: Int = 0
    private var hideWorkItem: DispatchWorkItem?   // hard block only
    private var appSwitchObserver: Any?           // hard block only

    private var graceBadge: NSTextField?
    private var graceRow: NSView?
    private var graceButton: NSButton?
    private var reorderPausedUntil: Date = .distantPast   // soft block only
    private var isHardBlock: Bool = false

    var onAction: ((_ action: String) -> Void)?

    // ── Public API ────────────────────────────────────────────────────────

    func show(pid: Int32, appName: String, usedSeconds: Int, limitSeconds: Int, hardBlock: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            // Don't re-trigger if already showing for this same app
            if self.scrimPanel != nil && self.targetPid == pid_t(pid) { return }
            self.dismiss(animated: false)
            self.targetPid = pid_t(pid)
            self.isHardBlock = hardBlock

            if hardBlock {
                self.showHardBlock(pid: pid, appName: appName,
                                   usedSeconds: usedSeconds, limitSeconds: limitSeconds)
            } else {
                self.showSoftBlock(pid: pid, appName: appName,
                                   usedSeconds: usedSeconds, limitSeconds: limitSeconds)
            }
        }
    }

    func dismiss(animated: Bool = true) {
        trackingTimer?.invalidate(); trackingTimer = nil
        graceTimer?.invalidate(); graceTimer = nil
        hideWorkItem?.cancel(); hideWorkItem = nil
        if let obs = appSwitchObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(obs)
            appSwitchObserver = nil
        }

        let sp = scrimPanel
        let cp = cardPanel
        scrimPanel = nil; cardPanel = nil
        graceBadge = nil; graceRow = nil; graceButton = nil
        targetPid = 0; isHardBlock = false

        if animated {
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.18
                sp?.animator().alphaValue = 0
                cp?.animator().alphaValue = 0
            }, completionHandler: {
                sp?.orderOut(nil)
                cp?.orderOut(nil)
            })
        } else {
            sp?.orderOut(nil)
            cp?.orderOut(nil)
        }
    }

    func startGraceCountdown(seconds: Int) {
        graceSecondsLeft = seconds
        graceTimer?.invalidate()
        updateGraceUI()
        graceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self else { t.invalidate(); return }
            self.graceSecondsLeft -= 1
            self.updateGraceUI()
            if self.graceSecondsLeft <= 0 { t.invalidate(); self.graceTimer = nil }
        }
    }

    // ── Soft block ────────────────────────────────────────────────────────
    // Original two-panel design: scrim tracks the blocked app window,
    // card floats above. Clicking scrim brings the blocked app to front.

    private func showSoftBlock(pid: Int32, appName: String, usedSeconds: Int, limitSeconds: Int) {
        // Bring the limited app to front so our overlay appears over it
        if let app = NSRunningApplication(processIdentifier: pid_t(pid)) {
            app.activate(options: [.activateIgnoringOtherApps])
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self else { return }
            let frame = self.targetWindowFrame(forPid: pid_t(pid))
                ?? NSScreen.main?.visibleFrame
                ?? CGRect(x: 0, y: 0, width: 1280, height: 800)
            self.buildSoftBlock(targetFrame: frame, appName: appName,
                                usedSeconds: usedSeconds, limitSeconds: limitSeconds)
            self.startTracking()
        }
    }

    private func buildSoftBlock(targetFrame: CGRect, appName: String,
                                 usedSeconds: Int, limitSeconds: Int) {
        let normalLevel = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.normalWindow)))
        let isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua

        // ── 1. Scrim panel ────────────────────────────────────────────────
        let sp = NSPanel(
            contentRect: targetFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered, defer: false
        )
        sp.isOpaque = false
        sp.backgroundColor = .clear
        sp.hasShadow = false
        sp.level = normalLevel
        sp.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        sp.alphaValue = 0
        sp.isMovable = false

        let scrimView = ScrimView(frame: CGRect(origin: .zero, size: targetFrame.size))
        scrimView.wantsLayer = true
        scrimView.layer?.cornerRadius = 20
        scrimView.layer?.masksToBounds = true
        scrimView.onTap = { [weak self] in
            guard let self, self.targetPid != 0 else { return }
            self.reorderPausedUntil = Date().addingTimeInterval(1.0)
            NSRunningApplication(processIdentifier: self.targetPid)?
                .activate(options: [.activateIgnoringOtherApps])
        }
        sp.contentView = scrimView

        // ── 2. Card panel ─────────────────────────────────────────────────
        let cardW: CGFloat = 400
        let cardH: CGFloat = 390
        let cardX = targetFrame.midX - cardW / 2
        let cardY = targetFrame.midY - cardH / 2

        let cp = NSPanel(
            contentRect: CGRect(x: cardX, y: cardY, width: cardW, height: cardH),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered, defer: false
        )
        cp.isOpaque = false
        cp.backgroundColor = .clear
        cp.hasShadow = true
        cp.level = normalLevel
        cp.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        cp.alphaValue = 0
        cp.isMovable = false

        let ve = makeCardView(width: cardW, height: cardH, isDark: isDark)
        buildCard(in: ve, appName: appName,
                  usedSeconds: usedSeconds, limitSeconds: limitSeconds, isDark: isDark)
        cp.contentView = ve

        // Wire scrim → re-raises card on click
        scrimView.cardPanel = cp

        // Stack card above scrim. Both start hidden (alpha 0).
        // repositionIfNeeded() reveals them only when the blocked app is frontmost.
        cp.order(.above, relativeTo: sp.windowNumber)

        scrimPanel = sp
        cardPanel  = cp
    }

    // ── Hard block ────────────────────────────────────────────────────────
    // Full-screen single panel at screenSaverWindow level, anchored to Scolect.
    // Card is embedded as a subview to avoid z-order conflicts on click.
    // Blocked app hidden after 0.3s; observer dismisses on intentional app switch.

    private func showHardBlock(pid: Int32, appName: String, usedSeconds: Int, limitSeconds: Int) {
        let screen = NSScreen.main?.frame ?? CGRect(x: 0, y: 0, width: 1280, height: 800)
        buildHardBlock(targetFrame: screen, appName: appName,
                       usedSeconds: usedSeconds, limitSeconds: limitSeconds)

        // Hide blocked app after overlay is visible.
        // Register the app-switch observer AFTER hide settles (0.7s total) so
        // the focus shift caused by app.hide() doesn't trigger premature dismissal.
        let scolectPid = NSRunningApplication.current.processIdentifier
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            if let app = NSRunningApplication(processIdentifier: pid_t(pid)),
               !app.isHidden {
                app.hide()
            }
            // Wait for hide-induced focus-shift noise to settle, then watch for
            // intentional switches to other regular user-facing apps.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                guard let self, self.scrimPanel != nil else { return }
                self.appSwitchObserver = NSWorkspace.shared.notificationCenter.addObserver(
                    forName: NSWorkspace.didActivateApplicationNotification,
                    object: nil, queue: .main) { [weak self] note in
                        guard let self else { return }
                        guard let activeApp = note.userInfo?[NSWorkspace.applicationUserInfoKey]
                            as? NSRunningApplication else { return }
                        let activePid = activeApp.processIdentifier
                        // Only dismiss for regular user-facing apps, not Dock / app-switcher UI.
                        guard activeApp.activationPolicy == .regular else { return }
                        if activePid != self.targetPid && activePid != scolectPid {
                            self.onAction?("dismiss")
                            self.dismiss()
                        }
                }
            }
        }
        hideWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: work)
    }

    private func buildHardBlock(targetFrame: CGRect, appName: String,
                                 usedSeconds: Int, limitSeconds: Int) {
        let ssLevel = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.screenSaverWindow)))
        let isDark  = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua

        // ── Scrim panel (full screen) ─────────────────────────────────────
        let sp = NSPanel(
            contentRect: targetFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered, defer: false
        )
        sp.isOpaque = false
        sp.backgroundColor = .clear
        sp.hasShadow = false
        sp.level = ssLevel
        sp.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        sp.alphaValue = 0
        sp.isMovable = false

        let scrimView = ScrimView(frame: CGRect(origin: .zero, size: targetFrame.size))
        scrimView.wantsLayer = true
        // Hard block scrim: no rounded corners, no tap handler
        sp.contentView = scrimView

        // ── Card embedded as subview ──────────────────────────────────────
        let cardW: CGFloat = 400
        let cardH: CGFloat = 390
        let cardX = targetFrame.midX - cardW / 2 - targetFrame.minX
        let cardY = targetFrame.midY - cardH / 2 - targetFrame.minY

        let ve = makeCardView(width: cardW, height: cardH, isDark: isDark)
        ve.frame = CGRect(x: cardX, y: cardY, width: cardW, height: cardH)
        buildCard(in: ve, appName: appName,
                  usedSeconds: usedSeconds, limitSeconds: limitSeconds, isDark: isDark)
        scrimView.addSubview(ve)

        // ── Show ──────────────────────────────────────────────────────────
        sp.orderFront(nil)
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.22
            sp.animator().alphaValue = 1
        }

        scrimPanel = sp
        cardPanel  = nil   // card is a subview, not a separate panel
    }

    // ── Shared card helpers ───────────────────────────────────────────────

    private func makeCardView(width: CGFloat, height: CGFloat, isDark: Bool) -> NSVisualEffectView {
        let ve = NSVisualEffectView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        ve.blendingMode = .behindWindow
        ve.material = isDark ? .hudWindow : .sidebar
        ve.state = .active
        ve.wantsLayer = true
        ve.layer?.cornerRadius = 16
        ve.layer?.masksToBounds = true
        ve.layer?.borderWidth = 0.75
        ve.layer?.borderColor = (isDark
            ? NSColor.white.withAlphaComponent(0.14)
            : NSColor.black.withAlphaComponent(0.1)
        ).cgColor
        return ve
    }

    // MARK: - Card UI

    private func buildCard(in card: NSView, appName: String,
                            usedSeconds: Int, limitSeconds: Int, isDark: Bool) {
        let W      = card.bounds.width
        let H      = card.bounds.height
        let pad: CGFloat = 20
        let innerW = W - pad * 2

        // ── Header band ───────────────────────────────────────────────────
        let headerH: CGFloat = 88
        let header = NSView(frame: CGRect(x: 0, y: H - headerH, width: W, height: headerH))
        header.wantsLayer = true
        header.layer?.backgroundColor = NSColor.systemRed.withAlphaComponent(isDark ? 0.18 : 0.1).cgColor
        card.addSubview(header)

        let iconSize: CGFloat = 32
        let iconImg = NSImage(systemSymbolName: "hourglass.tophalf.filled",
                               accessibilityDescription: nil)?
            .withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: iconSize, weight: .medium))
        let iconView = NSImageView(frame: CGRect(
            x: (W - iconSize) / 2, y: H - headerH + (headerH - iconSize) / 2,
            width: iconSize, height: iconSize))
        iconView.image = iconImg
        iconView.contentTintColor = .systemRed
        card.addSubview(iconView)

        // ── Title + subtitle ──────────────────────────────────────────────
        let titleY = H - headerH - 14 - 20
        let titleLbl = labelView("Time limit reached",
                                  font: .systemFont(ofSize: 15, weight: .semibold), align: .center)
        titleLbl.frame = CGRect(x: pad, y: titleY, width: innerW, height: 20)
        card.addSubview(titleLbl)

        let displayName = appName.replacingOccurrences(of: ".app", with: "")
        let subtitleY = titleY - 3 - 15
        let subtitleLbl = labelView(displayName,
                                     font: .systemFont(ofSize: 12, weight: .regular),
                                     color: .secondaryLabelColor, align: .center)
        subtitleLbl.frame = CGRect(x: pad, y: subtitleY, width: innerW, height: 15)
        card.addSubview(subtitleLbl)

        // ── Usage stats ───────────────────────────────────────────────────
        let statsY = subtitleY - 14 - 44
        let halfW  = (innerW - 8) / 2

        card.addSubview(statBox(
            value: formatDuration(usedSeconds), label: "Used today",
            color: .systemRed, frame: CGRect(x: pad, y: statsY, width: halfW, height: 44),
            isDark: isDark))
        card.addSubview(statBox(
            value: formatDuration(limitSeconds), label: "Daily limit",
            color: .secondaryLabelColor, frame: CGRect(x: pad + halfW + 8, y: statsY, width: halfW, height: 44),
            isDark: isDark))

        // ── Divider ───────────────────────────────────────────────────────
        let divY = statsY - 14
        let div  = NSBox(); div.boxType = .separator
        div.frame = CGRect(x: pad, y: divY, width: innerW, height: 1)
        card.addSubview(div)

        // ── Grace badge (hidden until started) ───────────────────────────
        let graceH: CGFloat = 30
        let graceY = divY - 10 - graceH
        let graceBox = roundedView(
            frame: CGRect(x: pad, y: graceY, width: innerW, height: graceH),
            color: NSColor.systemOrange.withAlphaComponent(0.12), radius: 8)
        let accentBar = NSView(frame: CGRect(x: 0, y: 0, width: 3, height: graceH))
        accentBar.wantsLayer = true
        accentBar.layer?.backgroundColor = NSColor.systemOrange.cgColor
        accentBar.layer?.cornerRadius = 1.5
        graceBox.addSubview(accentBar)
        let graceLbl = labelView("Grace period: 05:00 remaining",
                                  font: .monospacedDigitSystemFont(ofSize: 11, weight: .medium),
                                  color: .systemOrange, align: .left)
        graceLbl.frame = CGRect(x: 10, y: 7, width: innerW - 16, height: 16)
        graceBox.addSubview(graceLbl)
        graceBox.isHidden = true
        card.addSubview(graceBox)
        graceRow   = graceBox
        graceBadge = graceLbl

        // ── Primary buttons (2-col) ───────────────────────────────────────
        let btnH: CGFloat = 42
        let halfBtnW = (innerW - 8) / 2
        let primaryBtnY = divY - 10 - btnH

        card.addSubview(primaryButton(
            title: "Minimize", sfIcon: "arrow.down.to.line", action: "minimize",
            color: isDark ? .white.withAlphaComponent(0.08) : .black.withAlphaComponent(0.05),
            frame: CGRect(x: pad, y: primaryBtnY, width: halfBtnW, height: btnH),
            isDark: isDark))
        card.addSubview(primaryButton(
            title: "Quit", sfIcon: "xmark.circle.fill", action: "quit",
            color: NSColor.systemRed.withAlphaComponent(isDark ? 0.2 : 0.1),
            frame: CGRect(x: pad + halfBtnW + 8, y: primaryBtnY, width: halfBtnW, height: btnH),
            isDark: isDark, textColor: .systemRed))

        // ── Secondary buttons (full-width) ────────────────────────────────
        let secBtnH: CGFloat = 36
        let gap: CGFloat = 7
        var secY = primaryBtnY - gap - secBtnH

        let graceBtn = fullWidthButton(
            title: "+5 min grace — save and close",
            sfIcon: "clock.badge.plus", action: "grace",
            frame: CGRect(x: pad, y: secY, width: innerW, height: secBtnH),
            accent: .systemOrange, isDark: isDark)
        card.addSubview(graceBtn)
        graceButton = graceBtn
        secY -= secBtnH + gap

        card.addSubview(fullWidthButton(
            title: "Unblock for today",
            sfIcon: "lock.open.fill", action: "unblock",
            frame: CGRect(x: pad, y: secY, width: innerW, height: secBtnH),
            accent: .systemGreen, isDark: isDark))

        // ── Branding footer ───────────────────────────────────────────────
        let brandLbl = labelView("Scolect", font: .systemFont(ofSize: 10, weight: .medium),
                                  color: .quaternaryLabelColor, align: .center)
        brandLbl.frame = CGRect(x: pad, y: 10, width: innerW, height: 14)
        card.addSubview(brandLbl)
    }

    // MARK: - UI helpers

    private func statBox(value: String, label: String, color: NSColor,
                          frame: CGRect, isDark: Bool) -> NSView {
        let box = NSView(frame: frame)
        box.wantsLayer = true
        box.layer?.backgroundColor = (isDark
            ? NSColor.white.withAlphaComponent(0.06)
            : NSColor.black.withAlphaComponent(0.04)
        ).cgColor
        box.layer?.cornerRadius = 8
        let valLbl = labelView(value,
                                font: .monospacedDigitSystemFont(ofSize: 17, weight: .semibold),
                                color: color, align: .center)
        valLbl.frame = CGRect(x: 4, y: 20, width: frame.width - 8, height: 20)
        box.addSubview(valLbl)
        let capLbl = labelView(label,
                                font: .systemFont(ofSize: 10, weight: .regular),
                                color: .tertiaryLabelColor, align: .center)
        capLbl.frame = CGRect(x: 4, y: 4, width: frame.width - 8, height: 13)
        box.addSubview(capLbl)
        return box
    }

    private func primaryButton(title: String, sfIcon: String, action: String,
                                color: NSColor, frame: CGRect, isDark: Bool,
                                textColor: NSColor? = nil) -> NSView {
        let fgColor = textColor ?? (isDark ? NSColor.white.withAlphaComponent(0.85) : NSColor.labelColor)
        let tile = NSView(frame: frame)
        tile.wantsLayer = true
        tile.layer?.backgroundColor = color.cgColor
        tile.layer?.cornerRadius = 10

        let iconPt: CGFloat = 13
        let gap: CGFloat = 5
        let attrs: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 12, weight: .medium)]
        let textW = (title as NSString).size(withAttributes: attrs).width
        let totalW = iconPt + gap + textW
        let startX = (frame.width - totalW) / 2
        let midY   = frame.height / 2

        let iconView = NSImageView(frame: CGRect(x: startX, y: midY - iconPt / 2, width: iconPt, height: iconPt))
        if let img = NSImage(systemSymbolName: sfIcon, accessibilityDescription: nil) {
            iconView.image = img.withSymbolConfiguration(
                NSImage.SymbolConfiguration(pointSize: iconPt, weight: .medium))
        }
        iconView.contentTintColor = fgColor
        tile.addSubview(iconView)

        let lbl = labelView(title, font: .systemFont(ofSize: 12, weight: .medium),
                             color: fgColor, align: .left)
        lbl.frame = CGRect(x: startX + iconPt + gap, y: midY - 8, width: textW + 4, height: 16)
        tile.addSubview(lbl)

        let btn = NSButton(frame: CGRect(origin: .zero, size: frame.size))
        btn.title = ""; btn.bezelStyle = .rounded
        btn.isBordered = false; btn.isTransparent = true
        objc_setAssociatedObject(btn, &ActionKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        btn.target = self; btn.action = #selector(buttonTapped(_:))
        tile.addSubview(btn)
        return tile
    }

    private func fullWidthButton(title: String, sfIcon: String, action: String,
                                  frame: CGRect, accent: NSColor, isDark: Bool) -> NSButton {
        let btn = NSButton(frame: frame)
        btn.title = title
        btn.bezelStyle = .rounded
        btn.isBordered = true
        btn.contentTintColor = accent
        btn.imagePosition = .imageLeft
        btn.font = .systemFont(ofSize: 12, weight: .medium)
        if let img = NSImage(systemSymbolName: sfIcon, accessibilityDescription: nil) {
            btn.image = img.withSymbolConfiguration(
                NSImage.SymbolConfiguration(pointSize: 12, weight: .medium))
        }
        objc_setAssociatedObject(btn, &ActionKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        btn.target = self
        btn.action = #selector(buttonTapped(_:))
        return btn
    }

    private func labelView(_ text: String, font: NSFont,
                            color: NSColor = .labelColor,
                            align: NSTextAlignment = .left) -> NSTextField {
        let tf = NSTextField(labelWithString: text)
        tf.font = font; tf.textColor = color; tf.alignment = align
        tf.lineBreakMode = .byTruncatingTail
        tf.drawsBackground = false
        return tf
    }

    private func roundedView(frame: CGRect, color: NSColor, radius: CGFloat) -> NSView {
        let v = NSView(frame: frame)
        v.wantsLayer = true
        v.layer?.backgroundColor = color.cgColor
        v.layer?.cornerRadius = radius
        return v
    }

    @objc private func buttonTapped(_ sender: NSButton) {
        handleAction(objc_getAssociatedObject(sender, &ActionKey) as? String ?? "")
    }

    private func handleAction(_ action: String) {
        switch action {
        case "grace":
            onAction?("grace")
            graceButton?.isEnabled = false
            graceButton?.title = "Grace period active"
        default:
            onAction?(action)
            dismiss()
        }
    }

    private func updateGraceUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let m = self.graceSecondsLeft / 60
            let s = self.graceSecondsLeft % 60
            self.graceBadge?.stringValue = String(format: "Grace period: %02d:%02d remaining", m, s)
            self.graceRow?.isHidden = self.graceSecondsLeft <= 0
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600; let m = (seconds % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m" }
        return "\(seconds)s"
    }

    // MARK: - Soft block window tracking

    private func startTracking() {
        trackingTimer?.invalidate()
        trackingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.repositionIfNeeded()
        }
    }

    private func repositionIfNeeded() {
        guard let sp = scrimPanel, let cp = cardPanel, targetPid != 0 else { return }
        guard let frame = targetWindowFrame(forPid: targetPid) else { return }

        let changed = abs(sp.frame.origin.x - frame.origin.x) > 1
                   || abs(sp.frame.origin.y - frame.origin.y) > 1
                   || abs(sp.frame.size.width  - frame.size.width)  > 1
                   || abs(sp.frame.size.height - frame.size.height) > 1

        if changed {
            sp.setFrame(frame, display: true)
            sp.contentView?.frame = CGRect(origin: .zero, size: frame.size)
            let cw = cp.frame.width; let ch = cp.frame.height
            cp.setFrameOrigin(CGPoint(x: frame.midX - cw / 2, y: frame.midY - ch / 2))
        }

        let frontmostPid = NSWorkspace.shared.frontmostApplication?.processIdentifier

        if frontmostPid == targetPid && Date() >= reorderPausedUntil {
            // Blocked app is frontmost — assert overlay above it
            if let targetNum = targetWindowNumber(forPid: targetPid) {
                sp.order(.above, relativeTo: targetNum)
            }
            cp.order(.above, relativeTo: sp.windowNumber)
            if sp.alphaValue == 0 {
                sp.alphaValue = 1
                cp.alphaValue = 1
            }
        } else if frontmostPid != targetPid {
            // Another app is frontmost — pull overlay behind everything so it's not visible
            sp.order(.below, relativeTo: 0)
            cp.order(.below, relativeTo: 0)
        }
    }

    // MARK: - CGWindow helpers

    private func targetWindowFrame(forPid pid: pid_t) -> CGRect? {
        guard let list = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID
        ) as? [[String: Any]] else { return nil }

        let screenH = NSScreen.main?.frame.height ?? 0
        for info in list {
            guard let ownerPID = info[kCGWindowOwnerPID as String] as? Int, ownerPID == Int(pid),
                  let layer = info[kCGWindowLayer as String] as? Int, layer == 0,
                  let b = info[kCGWindowBounds as String] as? [String: CGFloat]
            else { continue }
            return CGRect(x: b["X"] ?? 0,
                          y: screenH - (b["Y"] ?? 0) - (b["Height"] ?? 0),
                          width: b["Width"] ?? 0, height: b["Height"] ?? 0)
        }
        return nil
    }

    private func targetWindowNumber(forPid pid: pid_t) -> Int? {
        guard let list = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID
        ) as? [[String: Any]] else { return nil }

        for info in list {
            guard let ownerPID = info[kCGWindowOwnerPID as String] as? Int, ownerPID == Int(pid),
                  let layer = info[kCGWindowLayer as String] as? Int, layer == 0,
                  let num = info[kCGWindowNumber as String] as? Int
            else { continue }
            return num
        }
        return nil
    }
}

private var ActionKey: UInt8 = 0
