import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const int _kMaxPath = 260;
const int _kMaxTitle = 512; // increased from 256 for longer titles
const int _kProcessQueryInformation = 0x0400;
const int _kProcessVMRead = 0x0010;
const int _kTh32csSnapProcess = 0x00000002;
const int _kInvalidHandleValue = -1;

// ─── Native type aliases ──────────────────────────────────────────────────────

typedef _GetForegroundWindowN = Pointer<Void> Function();
typedef _GetForegroundWindowD = Pointer<Void> Function();

typedef _GetWindowTextN = Int32 Function(Pointer<Void>, Pointer<Char>, Int32);
typedef _GetWindowTextD = int Function(Pointer<Void>, Pointer<Char>, int);

typedef _GetWindowThreadProcessIdN = Int32 Function(
    Pointer<Void>, Pointer<Uint32>);
typedef _GetWindowThreadProcessIdD = int Function(
    Pointer<Void>, Pointer<Uint32>);

typedef _OpenProcessN = Pointer<Void> Function(Uint32, Int32, Uint32);
typedef _OpenProcessD = Pointer<Void> Function(int, int, int);

typedef _GetModuleFileNameExAN = Int32 Function(
    Pointer<Void>, Pointer<Void>, Pointer<Char>, Uint32);
typedef _GetModuleFileNameExAD = int Function(
    Pointer<Void>, Pointer<Void>, Pointer<Char>, int);

typedef _CloseHandleN = Int32 Function(Pointer<Void>);
typedef _CloseHandleD = int Function(Pointer<Void>);

typedef _CreateToolhelp32SnapshotN = Pointer<Void> Function(Uint32, Uint32);
typedef _CreateToolhelp32SnapshotD = Pointer<Void> Function(int, int);

typedef _Process32N = Int32 Function(Pointer<Void>, Pointer<PROCESSENTRY32>);
typedef _Process32D = int Function(Pointer<Void>, Pointer<PROCESSENTRY32>);

typedef _GetFileVersionInfoSizeAN = Uint32 Function(
    Pointer<Char>, Pointer<Uint32>);
typedef _GetFileVersionInfoSizeAD = int Function(
    Pointer<Char>, Pointer<Uint32>);

typedef _GetFileVersionInfoAN = Int32 Function(
    Pointer<Char>, Uint32, Uint32, Pointer<Void>);
typedef _GetFileVersionInfoAD = int Function(
    Pointer<Char>, int, int, Pointer<Void>);

typedef _VerQueryValueAN = Int32 Function(
    Pointer<Void>, Pointer<Char>, Pointer<Pointer<Void>>, Pointer<Uint32>);
typedef _VerQueryValueAD = int Function(
    Pointer<Void>, Pointer<Char>, Pointer<Pointer<Void>>, Pointer<Uint32>);

// ─── Structs ──────────────────────────────────────────────────────────────────

base class PROCESSENTRY32 extends Struct {
  @Uint32()
  external int dwSize;
  @Uint32()
  external int cntUsage;
  @Uint32()
  external int th32ProcessID;
  @IntPtr()
  external int th32DefaultHeapID;
  @Uint32()
  external int th32ModuleID;
  @Uint32()
  external int cntThreads;
  @Uint32()
  external int th32ParentProcessID;
  @Int32()
  external int pcPriClassBase;
  @Uint32()
  external int dwFlags;
  @Array(_kMaxPath)
  external Array<Char> szExeFile;
}

base class FILETIME extends Struct {
  @Uint32()
  external int dwLowDateTime;
  @Uint32()
  external int dwHighDateTime;
}

// ─── Data classes ─────────────────────────────────────────────────────────────

class WindowInfo {
  final String windowTitle;
  final String processName;
  final String executableName;
  final String programName;
  final int processId;
  final int parentProcessId;
  final String parentProcessName;

  const WindowInfo({
    required this.windowTitle,
    required this.processName,
    required this.executableName,
    required this.programName,
    required this.processId,
    required this.parentProcessId,
    required this.parentProcessName,
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
      );

  @override
  String toString() => 'WindowInfo(title: $windowTitle, process: $processName, '
      'executable: $executableName, program: $programName, pid: $processId, '
      'parent: $parentProcessName, parentPid: $parentProcessId)';
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

  @override
  String toString() =>
      'AppLaunchInfo(pid: $processId, parentPid: $parentProcessId, '
      'parent: $parentProcessName, startedWithSystem: $wasStartedWithSystem, '
      'systemLaunched: $isSystemLaunched, autoStart: $isRegisteredAutoStart, '
      'args: $commandLineArgs, launchType: $launchType)';
}

// ─── Plugin ───────────────────────────────────────────────────────────────────

class ForegroundWindowPlugin {
  // ── DLL handles (lazy, loaded once) ──

  static final DynamicLibrary _user32 = DynamicLibrary.open('user32.dll');
  static final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');
  static final DynamicLibrary _psapi = DynamicLibrary.open('psapi.dll');
  static final DynamicLibrary _version = DynamicLibrary.open('version.dll');

  // ── Native function bindings ──

  static final _GetForegroundWindowD _getForegroundWindow =
      _user32.lookupFunction<_GetForegroundWindowN, _GetForegroundWindowD>(
          'GetForegroundWindow');

  static final _GetWindowTextD _getWindowText = _user32
      .lookupFunction<_GetWindowTextN, _GetWindowTextD>('GetWindowTextA');

  static final _GetWindowThreadProcessIdD _getWindowThreadProcessId = _user32
      .lookupFunction<_GetWindowThreadProcessIdN, _GetWindowThreadProcessIdD>(
          'GetWindowThreadProcessId');

  static final _OpenProcessD _openProcess =
      _kernel32.lookupFunction<_OpenProcessN, _OpenProcessD>('OpenProcess');

  static final _GetModuleFileNameExAD _getModuleFileNameExA =
      _psapi.lookupFunction<_GetModuleFileNameExAN, _GetModuleFileNameExAD>(
          'GetModuleFileNameExA');

  static final _CloseHandleD _closeHandle =
      _kernel32.lookupFunction<_CloseHandleN, _CloseHandleD>('CloseHandle');

  static final _CreateToolhelp32SnapshotD _createToolhelp32Snapshot = _kernel32
      .lookupFunction<_CreateToolhelp32SnapshotN, _CreateToolhelp32SnapshotD>(
          'CreateToolhelp32Snapshot');

  static final _Process32D _process32First =
      _kernel32.lookupFunction<_Process32N, _Process32D>('Process32First');

  static final _Process32D _process32Next =
      _kernel32.lookupFunction<_Process32N, _Process32D>('Process32Next');

  static final _GetFileVersionInfoSizeAD _getFileVersionInfoSizeA = _version
      .lookupFunction<_GetFileVersionInfoSizeAN, _GetFileVersionInfoSizeAD>(
          'GetFileVersionInfoSizeA');

  static final _GetFileVersionInfoAD _getFileVersionInfoA =
      _version.lookupFunction<_GetFileVersionInfoAN, _GetFileVersionInfoAD>(
          'GetFileVersionInfoA');

  static final _VerQueryValueAD _verQueryValueA = _version
      .lookupFunction<_VerQueryValueAN, _VerQueryValueAD>('VerQueryValueA');

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns foreground window info on the platform thread via [compute].
  /// Never throws; returns [WindowInfo.unknown()] on any failure.
  static Future<WindowInfo> getForegroundWindowInfo() async {
    try {
      return await compute(_getForegroundWindowInfoNative, null);
    } catch (e, st) {
      debugPrint('ForegroundWindowPlugin: unexpected error: $e\n$st');
      return WindowInfo.unknown();
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Safely converts a native [Pointer<Char>] to a Dart [String].
  /// Falls back to a lossy conversion on invalid UTF-8.
  static String _safeDartString(Pointer<Char> ptr, {int? length}) {
    if (ptr.address == 0) return '';
    try {
      return ptr.cast<Utf8>().toDartString(length: length);
    } catch (_) {
      if (length != null && length > 0) {
        final bytes = List.generate(
          length,
          (i) {
            final b = ptr[i];
            // Dart's FFI Char is signed; mask to unsigned byte.
            final unsigned = b & 0xFF;
            return unsigned == 0 ? null : unsigned; // stop at null terminator
          },
        ).whereType<int>().toList();
        return String.fromCharCodes(bytes);
      }
      return '';
    }
  }

  /// Extracts and prettifies the executable name from a full path.
  /// e.g. `C:\Program Files\My App\my_app.exe` → `My App`
  static String _extractExecutableName(String fullPath) {
    if (fullPath.isEmpty) return 'Unknown';
    final fileName = fullPath.split('\\').last;
    var name = fileName.toLowerCase().endsWith('.exe')
        ? fileName.substring(0, fileName.length - 4)
        : fileName;

    // Replace separators with spaces and title-case each word.
    name = name
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');

    return name.isNotEmpty ? name : 'Unknown';
  }

  /// Strips a trailing `.exe` (case-insensitive) from [name].
  static String _cleanProgramName(String name) {
    if (name.isEmpty) return name;
    return name.toLowerCase().endsWith('.exe')
        ? name.substring(0, name.length - 4)
        : name;
  }

  /// Tries to read `FileDescription` or `ProductName` from the PE version
  /// resource; falls back to [_extractExecutableName] on any failure.
  static String _getProgramNameFromVersionInfo(String fullPath) {
    if (fullPath.isEmpty || fullPath == 'Unknown') {
      return _extractExecutableName(fullPath);
    }

    Pointer<Char> pathPtr = nullptr;
    Pointer<Uint32> handlePtr = nullptr;
    Pointer<Uint8> versionInfoPtr = nullptr;

    try {
      pathPtr = fullPath.toNativeUtf8().cast<Char>();
      handlePtr = calloc<Uint32>();

      final versionInfoSize = _getFileVersionInfoSizeA(pathPtr, handlePtr);
      if (versionInfoSize == 0) return _extractExecutableName(fullPath);

      versionInfoPtr = calloc<Uint8>(versionInfoSize);
      if (_getFileVersionInfoA(
              pathPtr, 0, versionInfoSize, versionInfoPtr.cast()) ==
          0) {
        return _extractExecutableName(fullPath);
      }

      const languageCodes = [
        r'\StringFileInfo\040904B0', // English US (Unicode)
        r'\StringFileInfo\040904E4', // English US (Windows-1252)
        r'\StringFileInfo\080404B0', // Chinese Simplified
        r'\StringFileInfo\040704B0', // German
        r'\StringFileInfo\040C04B0', // French
        r'\StringFileInfo\041904B0', // Russian
        r'\StringFileInfo\040A04B0', // Spanish
      ];

      for (final langCode in languageCodes) {
        for (final field in ['FileDescription', 'ProductName']) {
          final subPath = '$langCode\\$field';
          final subPathPtr = subPath.toNativeUtf8().cast<Char>();
          final bufferPtr = calloc<Pointer<Void>>();
          final lengthPtr = calloc<Uint32>();
          try {
            final ok = _verQueryValueA(
                versionInfoPtr.cast(), subPathPtr, bufferPtr, lengthPtr);
            if (ok != 0 &&
                lengthPtr.value > 0 &&
                bufferPtr.value.address != 0) {
              final name = bufferPtr.value.cast<Utf8>().toDartString();
              final cleaned = _cleanProgramName(name.trim());
              if (cleaned.isNotEmpty) return cleaned;
            }
          } catch (_) {
            // ignore and try next entry
          } finally {
            calloc.free(subPathPtr);
            calloc.free(bufferPtr);
            calloc.free(lengthPtr);
          }
        }
      }

      return _extractExecutableName(fullPath);
    } catch (_) {
      return _extractExecutableName(fullPath);
    } finally {
      if (pathPtr.address != 0) calloc.free(pathPtr);
      if (handlePtr.address != 0) calloc.free(handlePtr);
      if (versionInfoPtr.address != 0) calloc.free(versionInfoPtr);
    }
  }

  // ── Core native logic (runs inside compute isolate) ───────────────────────

  static WindowInfo _getForegroundWindowInfoNative(dynamic _) {
    final hwnd = _getForegroundWindow();
    if (hwnd.address == 0) return WindowInfo.unknown();

    // ── Process ID ──
    final processIdPtr = calloc<Uint32>();
    late final int processId;
    try {
      _getWindowThreadProcessId(hwnd, processIdPtr);
      processId = processIdPtr.value;
    } finally {
      calloc.free(processIdPtr);
    }
    if (processId == 0) return WindowInfo.unknown();

    // ── Window title ──
    final titlePtr = calloc<Char>(_kMaxTitle);
    late final String windowTitle;
    try {
      final len = _getWindowText(hwnd, titlePtr, _kMaxTitle);
      windowTitle = len > 0 ? _safeDartString(titlePtr, length: len) : '';
    } finally {
      calloc.free(titlePtr);
    }

    // ── Process details ──
    String processName = 'Unknown';
    String executableName = 'Unknown';
    String programName = 'Unknown';
    int parentProcessId = 0;
    String parentProcessName = 'Unknown';

    final hProcess =
        _openProcess(_kProcessQueryInformation | _kProcessVMRead, 0, processId);

    if (hProcess.address != 0) {
      try {
        final namePtr = calloc<Char>(_kMaxPath);
        try {
          final result =
              _getModuleFileNameExA(hProcess, nullptr, namePtr, _kMaxPath);
          if (result > 0) {
            processName = _safeDartString(namePtr, length: result);
            executableName = _extractExecutableName(processName);
            programName = _getProgramNameFromVersionInfo(processName);
          }
        } finally {
          calloc.free(namePtr);
        }

        parentProcessId = _getParentProcessId(processId);
        parentProcessName = _getProcessNameById(parentProcessId);
      } finally {
        _closeHandle(hProcess);
      }
    } else {
      // Elevated or protected process – fall back to window-title heuristics.
      programName = _heuristicProgramName(windowTitle);
    }

    return WindowInfo(
      windowTitle: windowTitle,
      processName: processName,
      executableName: executableName,
      programName: programName,
      processId: processId,
      parentProcessId: parentProcessId,
      parentProcessName: parentProcessName,
    );
  }

  /// Very lightweight heuristic for protected processes we can't open.
  static String _heuristicProgramName(String windowTitle) {
    if (windowTitle.isEmpty) return 'Protected Application';
    // Strip common suffixes like " – Mozilla Firefox", " - Google Chrome"
    for (final sep in [' – ', ' - ', ' | ']) {
      final idx = windowTitle.lastIndexOf(sep);
      if (idx > 0) return windowTitle.substring(idx + sep.length).trim();
    }
    return windowTitle;
  }

  /// Returns the parent PID of [processId] using a Toolhelp32 snapshot.
  static int _getParentProcessId(int processId) {
    final hSnapshot = _createToolhelp32Snapshot(_kTh32csSnapProcess, 0);
    if (hSnapshot.address == _kInvalidHandleValue || hSnapshot.address == 0) {
      return 0;
    }

    int parentId = 0;
    final entry = calloc<PROCESSENTRY32>();
    try {
      entry.ref.dwSize = sizeOf<PROCESSENTRY32>();
      if (_process32First(hSnapshot, entry) != 0) {
        do {
          if (entry.ref.th32ProcessID == processId) {
            parentId = entry.ref.th32ParentProcessID;
            break;
          }
        } while (_process32Next(hSnapshot, entry) != 0);
      }
    } finally {
      calloc.free(entry);
      _closeHandle(hSnapshot);
    }
    return parentId;
  }

  /// Returns the full executable path of the process with [processId],
  /// or a descriptive fallback string.
  static String _getProcessNameById(int processId) {
    if (processId == 0) return 'System';
    if (processId == 4) return 'System'; // Windows kernel process

    final hProcess =
        _openProcess(_kProcessQueryInformation | _kProcessVMRead, 0, processId);
    if (hProcess.address == 0) return 'Unknown';

    final namePtr = calloc<Char>(_kMaxPath);
    try {
      final result =
          _getModuleFileNameExA(hProcess, nullptr, namePtr, _kMaxPath);
      if (result > 0) return _safeDartString(namePtr, length: result);
      return 'Unknown';
    } finally {
      calloc.free(namePtr);
      _closeHandle(hProcess);
    }
  }
}
