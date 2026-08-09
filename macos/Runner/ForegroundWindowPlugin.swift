import Cocoa
import FlutterMacOS

public class ForegroundWindowPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "foreground_window_plugin",
            binaryMessenger: registrar.messenger
        )
        let instance = ForegroundWindowPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getForegroundWindow":
            getForegroundWindow(result: result)
        case "hideOtherApp":
            if let args = call.arguments as? [String: Any],
               let pid = args["pid"] as? Int {
                hideOtherApp(pid: pid_t(pid), result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "pid required", details: nil))
            }
        case "terminateOtherApp":
            if let args = call.arguments as? [String: Any],
               let pid = args["pid"] as? Int {
                terminateOtherApp(pid: pid_t(pid), result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "pid required", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Get Foreground Window Info
    
    private func getForegroundWindow(result: @escaping FlutterResult) {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            result(FlutterError(
                code: "NO_WINDOW",
                message: "No foreground window found",
                details: nil
            ))
            return
        }
        
        let processIdentifier = frontmostApp.processIdentifier
        let bundleIdentifier = frontmostApp.bundleIdentifier ?? "Unknown"
        
        // Get permanent program name from bundle
        let programName = getProgramName(from: frontmostApp)
        
        // Get executable name and path
        let executableName = getExecutableName(from: frontmostApp)
        let executablePath = frontmostApp.executableURL?.path ?? "Unknown"
        
        // Get parent process information
        let parentProcessId = getParentProcessId(for: processIdentifier)
        let parentProcessName = getProcessName(for: parentProcessId)
        
        let resultMap: [String: Any] = [
            "windowTitle": programName,  // Using program name as window title
            "processName": executablePath,
            "executableName": executableName,
            "programName": programName,
            "processId": Int(processIdentifier),
            "parentProcessId": parentProcessId,
            "parentProcessName": parentProcessName
        ]
        
        result(resultMap)
    }
    
    // MARK: - Helper Methods
    
    /// Get permanent program name from app bundle
    private func getProgramName(from app: NSRunningApplication) -> String {
        if let bundleURL = app.bundleURL {
            if let bundle = Bundle(url: bundleURL) {
                // Try CFBundleDisplayName first (this is the permanent display name)
                if let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String,
                   !displayName.isEmpty {
                    return displayName
                }
                
                // Fall back to CFBundleName
                if let bundleName = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String,
                   !bundleName.isEmpty {
                    return bundleName
                }
                
                // Fall back to CFBundleExecutable
                if let executableName = bundle.object(forInfoDictionaryKey: "CFBundleExecutable") as? String,
                   !executableName.isEmpty {
                    return executableName
                }
            }
        }
        
        // Final fallback to localized name
        return app.localizedName ?? "Unknown"
    }
    
    private func getExecutableName(from app: NSRunningApplication) -> String {
        if let executableURL = app.executableURL {
            return executableURL.lastPathComponent
        }
        return app.localizedName ?? "Unknown"
    }
    
    private func getParentProcessId(for pid: pid_t) -> Int {
        var kinfo = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
        
        let result = sysctl(&mib, u_int(mib.count), &kinfo, &size, nil, 0)
        
        if result == 0 {
            return Int(kinfo.kp_eproc.e_ppid)
        }
        
        return 0
    }
    
    private func getProcessName(for pid: Int) -> String {
        if pid == 0 {
            return "kernel_task"
        }
        
        // Try to get the running application by PID
        let runningApps = NSWorkspace.shared.runningApplications
        if let app = runningApps.first(where: { $0.processIdentifier == pid_t(pid) }) {
            return app.executableURL?.path ?? app.localizedName ?? "Unknown"
        }
        
        // Fallback: use ps command
        return getProcessNameViaPS(for: pid)
    }
    
    // MARK: - Hide / Terminate Other App

    private func hideOtherApp(pid: pid_t, result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            if let app = NSRunningApplication(processIdentifier: pid) {
                app.hide()
                result(true)
            } else {
                result(false)
            }
        }
    }

    private func terminateOtherApp(pid: pid_t, result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            if let app = NSRunningApplication(processIdentifier: pid) {
                app.terminate()
                result(true)
            } else {
                result(false)
            }
        }
    }

    private func getProcessNameViaPS(for pid: Int) -> String {
        let task = Process()
        task.launchPath = "/bin/ps"
        task.arguments = ["-p", "\(pid)", "-o", "comm="]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return output.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            return "Unknown"
        }
        
        return "Unknown"
    }
}