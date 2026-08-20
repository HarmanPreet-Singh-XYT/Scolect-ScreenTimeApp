// lib/foreground_window_info.dart

class WindowInfo {
  final String windowTitle;
  final String processName;
  final String executableName;
  final String programName;
  final int processId;
  final int parentProcessId;
  final String parentProcessName;

  /// Stable identity key for this app: bundle identifier on macOS,
  /// executable path on Windows. Unlike [programName] (a display label
  /// that can change across launches), this is meant to stay constant
  /// for the same real-world app and is used as the tracking/storage key.
  final String appId;

  const WindowInfo({
    required this.windowTitle,
    required this.processName,
    required this.executableName,
    required this.programName,
    required this.processId,
    required this.parentProcessId,
    required this.parentProcessName,
    required this.appId,
  });

  /// Returns a safe fallback WindowInfo when no window can be found.
  factory WindowInfo.unknown() => const WindowInfo(
        windowTitle: '',
        processName: 'Unknown',
        executableName: 'Unknown',
        programName: 'Unknown',
        processId: 0,
        parentProcessId: 0,
        parentProcessName: 'Unknown',
        appId: 'unknown',
      );

  @override
  String toString() => 'WindowInfo(title: $windowTitle, process: $processName, '
      'executable: $executableName, program: $programName, appId: $appId, '
      'pid: $processId, parent: $parentProcessName, parentPid: $parentProcessId)';
}

class AppLaunchInfo {
  final int processId;
  final int parentProcessId;
  final String parentProcessName;
  final bool wasStartedWithSystem;
  final bool isSystemLaunched;
  final bool isRegisteredAutoStart;
  final List<String> commandLineArgs;
  final String launchType;

  const AppLaunchInfo({
    required this.processId,
    required this.parentProcessId,
    required this.parentProcessName,
    required this.wasStartedWithSystem,
    required this.isSystemLaunched,
    required this.isRegisteredAutoStart,
    required this.commandLineArgs,
    required this.launchType,
  });
}
