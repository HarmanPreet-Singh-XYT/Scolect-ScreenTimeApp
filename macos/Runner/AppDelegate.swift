import Cocoa
import FlutterMacOS
import bitsdojo_window_macos

@main
class AppDelegate: FlutterAppDelegate, NSWindowDelegate {
  
  // ✅ Login item detection property
  private var launchedAsLogInItem: Bool {
    guard let event = NSAppleEventManager.shared().currentAppleEvent else { return false }
    return
      event.eventID == kAEOpenApplication &&
      event.paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue == keyAELaunchedAsLogInItem
  }
  
  // ✅ Store the result at launch (must capture immediately)
  private var wasLaunchedAsLoginItem: Bool = false
  
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ aNotification: Notification) {
    // ✅ IMPORTANT: Capture login item status IMMEDIATELY at launch
    // This must be done before any async operations as the AppleEvent is transient
    wasLaunchedAsLoginItem = launchedAsLogInItem

    setupMethodChannel()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      self.setupWindowDelegate()
    }
    guard let controller =
      mainFlutterWindow?.contentViewController as? FlutterViewController
    else {
      return
    }

    // Existing plugin registration
    let registrar = controller.registrar(forPlugin: "ForegroundWindowPlugin")
    ForegroundWindowPlugin.register(with: registrar)

    // ✅ Updated launch detection channel with proper login item detection
    let launchChannel = FlutterMethodChannel(
      name: "timemark/launch",
      binaryMessenger: controller.engine.binaryMessenger
    )

    launchChannel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "wasLaunchedAtLogin":
        // ✅ Return the properly detected login item status
        result(self?.wasLaunchedAsLoginItem ?? false)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // Block overlay channel — Dart calls Swift to show/dismiss the native panel.
    // Swift calls Dart back via the same channel for button actions.
    let overlayChannel = FlutterMethodChannel(
      name: "timemark/block_overlay",
      binaryMessenger: controller.engine.binaryMessenger
    )

    // Wire button callbacks: Swift → Dart
    BlockOverlayPanel.shared.onAction = { [weak overlayChannel] action in
      DispatchQueue.main.async {
        overlayChannel?.invokeMethod("onAction", arguments: action)
      }
    }

    overlayChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "show":
        guard let args = call.arguments as? [String: Any],
              let pid   = args["pid"]          as? Int,
              let name  = args["appName"]       as? String,
              let used  = args["usedSeconds"]   as? Int,
              let limit = args["limitSeconds"]  as? Int
        else { result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil)); return }
        BlockOverlayPanel.shared.show(pid: Int32(pid), appName: name,
                                      usedSeconds: used, limitSeconds: limit)
        result(nil)
      case "dismiss":
        BlockOverlayPanel.shared.dismiss()
        result(nil)
      case "startGrace":
        let secs = (call.arguments as? Int) ?? 300
        BlockOverlayPanel.shared.startGraceCountdown(seconds: secs)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.applicationDidFinishLaunching(aNotification)
  }
  
  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    if !flag {
      showWindow()
    }
    return true
  }
  
  private func setupWindowDelegate() {
    if let window = NSApplication.shared.windows.first {
      window.delegate = self
      window.isReleasedWhenClosed = false
    }
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    sender.orderOut(nil)
    return false
  }
  
  private func setupMethodChannel() {
    guard let window = mainFlutterWindow,
          let controller = window.contentViewController as? FlutterViewController else {
      return
    }
    
    let channel = FlutterMethodChannel(
      name: "timemark/macos_window",
      binaryMessenger: controller.engine.binaryMessenger
    )
    
    channel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "hide":
        self?.hideWindow()
        result(true)
      case "show":
        self?.showWindow()
        result(true)
      case "minimize":
        self?.minimizeWindow()
        result(true)
      case "maximize":
        self?.maximizeWindow()
        result(true)
      case "hideTrafficLights":
        self?.hideTrafficLights()
        result(true)
      case "exit":
        self?.exitApp()
        result(true)
      case "wasLaunchedAsLoginItem":
        // ✅ Also available on main window channel
        result(self?.wasLaunchedAsLoginItem ?? false)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  private func hideWindow() {
    DispatchQueue.main.async {
      NSApplication.shared.windows.first?.orderOut(nil)
      // Hide from Dock when window is hidden
      NSApp.setActivationPolicy(.accessory)
    }
  }

  private func showWindow() {
    DispatchQueue.main.async {
      // Show in Dock when window is shown
      NSApp.setActivationPolicy(.regular)
      NSApp.unhide(nil)
      if let window = NSApplication.shared.windows.first {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
      }
    }
  }
  
  private func minimizeWindow() {
    DispatchQueue.main.async {
      NSApplication.shared.windows.first?.miniaturize(nil)
    }
  }
  
  private func maximizeWindow() {
    DispatchQueue.main.async {
      NSApplication.shared.windows.first?.zoom(nil)
    }
  }
  
  private func hideTrafficLights() {
    DispatchQueue.main.async {
      if let window = NSApplication.shared.windows.first {
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
      }
    }
  }
  
  private func exitApp() {
    DispatchQueue.main.async {
      NSApplication.shared.terminate(nil)
    }
  }
}