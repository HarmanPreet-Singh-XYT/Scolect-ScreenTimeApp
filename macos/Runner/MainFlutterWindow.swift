import Cocoa
import FlutterMacOS
import bitsdojo_window_macos
import LaunchAtLogin

class MainFlutterWindow: BitsdojoWindow {
  override func bitsdojo_window_configure() -> UInt {
    return BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP
  }
  
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    FlutterMethodChannel(
      name: "launch_at_startup", binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    .setMethodCallHandler { (_ call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "launchAtStartupIsEnabled":
        result(LaunchAtLogin.isEnabled)
      case "launchAtStartupSetEnabled":
        if let arguments = call.arguments as? [String: Any] {
          LaunchAtLogin.isEnabled = arguments["setEnabledValue"] as! Bool
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    FlutterMethodChannel(
      name: "app_restart", binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    .setMethodCallHandler { (_ call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "restartApp":
        self.restartApplication()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
    
    // ✅ Add this - prevents window from being released when closed
    self.isReleasedWhenClosed = false
    
    // Hide traffic light buttons
    self.standardWindowButton(.closeButton)?.isHidden = true
    self.standardWindowButton(.miniaturizeButton)?.isHidden = true
    self.standardWindowButton(.zoomButton)?.isHidden = true
  }

  func restartApplication() {
    let task = Process()
    task.executableURL = Bundle.main.executableURL
    
    // Small delay to ensure clean shutdown
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      try? task.run()
      (NSApplication.shared.delegate as? AppDelegate)?.allowTermination = true
      NSApplication.shared.terminate(nil)
    }
  }
  
  // ✅ Optional: Override close to hide instead
  override func close() {
    self.orderOut(nil)
  }
}