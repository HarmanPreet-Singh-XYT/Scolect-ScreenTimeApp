import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const int _kMaxPath = 260;
const int _kMaxTitle = 512; // increased from 256 for longer titles
const int _kProcessQueryLimitedInformation = 0x1000;
const int _kProcessTerminate = 0x0001;
const int _kSwMinimize = 6;
const int _kTh32csSnapProcess = 0x00000002;
const int _kInvalidHandleValue = -1;

// ─── Native type aliases ──────────────────────────────────────────────────────

typedef _GetForegroundWindowN = Pointer<Void> Function();
typedef _GetForegroundWindowD = Pointer<Void> Function();

typedef _GetWindowTextWN = Int32 Function(
    Pointer<Void>, Pointer<Utf16>, Int32);
typedef _GetWindowTextWD = int Function(
    Pointer<Void>, Pointer<Utf16>, int);

typedef _GetClassNameWN = Int32 Function(
    Pointer<Void>, Pointer<Utf16>, Int32);
typedef _GetClassNameWD = int Function(
    Pointer<Void>, Pointer<Utf16>, int);

typedef _FindWindowExWN = Pointer<Void> Function(
    Pointer<Void>, Pointer<Void>, Pointer<Utf16>, Pointer<Utf16>);
typedef _FindWindowExWD = Pointer<Void> Function(
    Pointer<Void>, Pointer<Void>, Pointer<Utf16>, Pointer<Utf16>);

typedef _QueryFullProcessImageNameWN = Int32 Function(
    Pointer<Void>, Uint32, Pointer<Utf16>, Pointer<Uint32>);
typedef _QueryFullProcessImageNameWD = int Function(
    Pointer<Void>, int, Pointer<Utf16>, Pointer<Uint32>);

typedef _GetWindowThreadProcessIdN = Int32 Function(
    Pointer<Void>, Pointer<Uint32>);
typedef _GetWindowThreadProcessIdD = int Function(
    Pointer<Void>, Pointer<Uint32>);

typedef _OpenProcessN = Pointer<Void> Function(Uint32, Int32, Uint32);
typedef _OpenProcessD = Pointer<Void> Function(int, int, int);

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

// ── COM / AUMID lookup (for UWP-hosted windows, e.g. ApplicationFrameHost) ──

typedef _CoInitializeExN = Int32 Function(Pointer<Void>, Uint32);
typedef _CoInitializeExD = int Function(Pointer<Void>, int);

typedef _CoUninitializeN = Void Function();
typedef _CoUninitializeD = void Function();

typedef _CoTaskMemFreeN = Void Function(Pointer<Void>);
typedef _CoTaskMemFreeD = void Function(Pointer<Void>);

// HRESULT SHGetPropertyStoreForWindow(HWND hwnd, REFIID riid, void **ppv);
typedef _SHGetPropertyStoreForWindowN = Int32 Function(
    Pointer<Void>, Pointer<GUID>, Pointer<Pointer<Void>>);
typedef _SHGetPropertyStoreForWindowD = int Function(
    Pointer<Void>, Pointer<GUID>, Pointer<Pointer<Void>>);

// LONG GetApplicationUserModelId(HANDLE hProcess, UINT32 *len, PWSTR buf);
// kernel32.dll — simpler, non-COM alternative to the property-store route.
// Returns ERROR_SUCCESS (0) with the AUMID written to buf, or a non-zero
// win32 error (e.g. APPMODEL_ERROR_NO_APPLICATION = 15703 for non-packaged
// processes) if the process has no AUMID.
typedef _GetApplicationUserModelIdN = Uint32 Function(
    Pointer<Void>, Pointer<Uint32>, Pointer<Utf16>);
typedef _GetApplicationUserModelIdD = int Function(
    Pointer<Void>, Pointer<Uint32>, Pointer<Utf16>);

// ─── Structs ──────────────────────────────────────────────────────────────────

base class GUID extends Struct {
  @Uint32()
  external int data1;
  @Uint16()
  external int data2;
  @Uint16()
  external int data3;
  @Array(8)
  external Array<Uint8> data4;

  static Pointer<GUID> allocate(
      int d1, int d2, int d3, List<int> d4) {
    final ptr = calloc<GUID>();
    final g = ptr.ref;
    g.data1 = d1;
    g.data2 = d2;
    g.data3 = d3;
    for (int i = 0; i < 8; i++) {
      g.data4[i] = d4[i];
    }
    return ptr;
  }
}

// PROPERTYKEY: a GUID (fmtid) + a DWORD (pid). PKEY_AppUserModel_ID =
// {9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}, pid 5.
base class PROPERTYKEY extends Struct {
  @Uint32()
  external int fmtidData1;
  @Uint16()
  external int fmtidData2;
  @Uint16()
  external int fmtidData3;
  @Array(8)
  external Array<Uint8> fmtidData4;
  @Uint32()
  external int pid;
}

// Minimal PROPVARIANT: only the fields needed to read a VT_LPWSTR value.
// Real PROPVARIANT is a tagged union; we only ever expect VT_LPWSTR (31)
// back for PKEY_AppUserModel_ID, and treat anything else as "not present".
base class PROPVARIANT extends Struct {
  @Uint16()
  external int vt;
  @Uint16()
  external int wReserved1;
  @Uint16()
  external int wReserved2;
  @Uint16()
  external int wReserved3;
  external Pointer<Utf16> pwszVal; // valid only when vt == VT_LPWSTR
  @IntPtr()
  external int padding; // pad union to a safe size for PropVariantClear
}

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

  /// Stable identity key for this app (the executable path on Windows).
  /// Unlike [programName], which can vary across launches (version-resource
  /// reads or window-title heuristics for elevated processes), this stays
  /// constant for the same installed executable and is used as the
  /// tracking/storage key.
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

  @override
  String toString() =>
      'AppLaunchInfo(pid: $processId, parentPid: $parentProcessId, '
      'parent: $parentProcessName, startedWithSystem: $wasStartedWithSystem, '
      'systemLaunched: $isSystemLaunched, autoStart: $isRegisteredAutoStart, '
      'args: $commandLineArgs, launchType: $launchType)';
}

// ─── Plugin ───────────────────────────────────────────────────────────────────

class ForegroundWindowPlugin {
  // ── Main-isolate caches (persist across compute() calls) ──

  /// Maps exe full path → human-readable program name.
  /// Populated on first encounter; exe version resources don't change at runtime.
  static final Map<String, String> _programNameCache = {};

  /// Maps process ID → parent process ID.
  /// Avoids CreateToolhelp32Snapshot (full process snapshot) on repeated lookups.
  /// Keyed by OS-recycled PIDs, so entries are never removed individually —
  /// see [_maxPidCacheSize] for the bound on unbounded growth over long uptimes.
  static final Map<int, int> _parentPidCache = {};

  /// Maps parent process ID → parent process name.
  /// PIDs are reused by Windows but infrequently; good enough as a soft cache.
  static final Map<int, String> _parentNameCache = {};

  /// Above this many entries, [_parentPidCache]/[_parentNameCache] are wiped
  /// wholesale rather than evicted individually — they're soft/best-effort
  /// caches keyed by transient PIDs, so occasional cache misses are cheap and
  /// harmless, but leaving them unbounded means one new entry per distinct
  /// process ever seen in the foreground, for the app's entire uptime.
  static const int _maxPidCacheSize = 2000;

  // ── DLL handles (lazy, loaded once) ──

  static final DynamicLibrary _user32 = DynamicLibrary.open('user32.dll');
  static final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');
  static final DynamicLibrary _version = DynamicLibrary.open('version.dll');
  static final DynamicLibrary _ole32 = DynamicLibrary.open('ole32.dll');
  static final DynamicLibrary _shell32 = DynamicLibrary.open('shell32.dll');

  // ── Native function bindings ──

  static final _GetForegroundWindowD _getForegroundWindow =
      _user32.lookupFunction<_GetForegroundWindowN, _GetForegroundWindowD>(
          'GetForegroundWindow');

  static final _GetWindowTextWD _getWindowTextW = _user32
      .lookupFunction<_GetWindowTextWN, _GetWindowTextWD>('GetWindowTextW');

  static final _GetClassNameWD _getClassNameW = _user32
      .lookupFunction<_GetClassNameWN, _GetClassNameWD>('GetClassNameW');

  static final _FindWindowExWD _findWindowExW = _user32
      .lookupFunction<_FindWindowExWN, _FindWindowExWD>('FindWindowExW');

  static final _GetWindowThreadProcessIdD _getWindowThreadProcessId = _user32
      .lookupFunction<_GetWindowThreadProcessIdN, _GetWindowThreadProcessIdD>(
          'GetWindowThreadProcessId');

  static final _OpenProcessD _openProcess =
      _kernel32.lookupFunction<_OpenProcessN, _OpenProcessD>('OpenProcess');

  static final _QueryFullProcessImageNameWD _queryFullProcessImageNameW =
      _kernel32.lookupFunction<_QueryFullProcessImageNameWN,
          _QueryFullProcessImageNameWD>('QueryFullProcessImageNameW');

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

  static final _CoInitializeExD _coInitializeEx = _ole32
      .lookupFunction<_CoInitializeExN, _CoInitializeExD>('CoInitializeEx');

  static final _CoUninitializeD _coUninitialize = _ole32
      .lookupFunction<_CoUninitializeN, _CoUninitializeD>('CoUninitialize');

  static final _CoTaskMemFreeD _coTaskMemFree = _ole32
      .lookupFunction<_CoTaskMemFreeN, _CoTaskMemFreeD>('CoTaskMemFree');

  static final _SHGetPropertyStoreForWindowD _shGetPropertyStoreForWindow =
      _shell32.lookupFunction<_SHGetPropertyStoreForWindowN,
          _SHGetPropertyStoreForWindowD>('SHGetPropertyStoreForWindow');

  static final _GetApplicationUserModelIdD _getApplicationUserModelId =
      _kernel32.lookupFunction<_GetApplicationUserModelIdN,
          _GetApplicationUserModelIdD>('GetApplicationUserModelId');

  // ── Public API ────────────────────────────────────────────────────────────

  /// Minimizes all visible windows belonging to [pid].
  /// Used by [AppBlockingService.hideOtherApp] on Windows.
  static Future<void> hideOtherApp(int pid) async {
    try {
      await compute(_minimizeProcessWindows, pid);
    } catch (e) {
      debugPrint('ForegroundWindowPlugin.hideOtherApp: $e');
    }
  }

  /// Forcibly terminates the process with [pid].
  /// Used by [AppBlockingService.terminateOtherApp] on Windows.
  static Future<void> terminateOtherApp(int pid) async {
    try {
      await compute(_killProcess, pid);
    } catch (e) {
      debugPrint('ForegroundWindowPlugin.terminateOtherApp: $e');
    }
  }

  /// Returns foreground window info. Uses a two-step strategy to avoid
  /// repeated disk I/O (version resource reads) and expensive process snapshots
  /// (CreateToolhelp32Snapshot) on every focus-change event:
  ///
  /// Step 1 — cheap compute: get HWND, process ID, window title, exe path.
  /// Step 2 — main-isolate cache lookup for programName & parentProcessName.
  ///           Only dispatches a second compute for cache misses.
  ///
  /// [targetHwnd], if provided, resolves info for that exact window instead
  /// of querying "whatever is foreground right now" — pass this whenever the
  /// caller already knows which window it cares about (see
  /// _getRawWindowInfo's doc comment for why this matters).
  ///
  /// Never throws; returns [WindowInfo.unknown()] on any failure.
  static Future<WindowInfo> getForegroundWindowInfo({int? targetHwnd}) async {
    try {
      // Step 1: lightweight — no disk I/O, no process snapshot.
      final raw = await compute(_getRawWindowInfo, targetHwnd);
      if (raw == null) return WindowInfo.unknown();

      final String processPath = raw['processPath'] as String;
      final String windowTitle = raw['windowTitle'] as String;
      final String executableName = raw['executableName'] as String;
      final int processId = raw['processId'] as int;
      final bool elevated = raw['elevated'] as bool;
      final String aumid = raw['aumid'] as String? ?? '';

      // Step 2: resolve human-readable names using main-isolate caches.
      String programName;
      if (elevated) {
        programName = _heuristicProgramName(windowTitle);
      } else if (processPath.isEmpty) {
        programName = 'Unknown';
      } else if (_programNameCache.containsKey(processPath)) {
        programName = _programNameCache[processPath]!;
      } else {
        // Cache miss — read version resource once, then cache it.
        programName = await compute(_resolveVersionInfo, processPath);
        _programNameCache[processPath] = programName;
      }

      // Resolve parent PID (CreateToolhelp32Snapshot) with caching.
      int parentProcessId;
      if (_parentPidCache.containsKey(processId)) {
        parentProcessId = _parentPidCache[processId]!;
      } else {
        parentProcessId = await compute(_resolveParentPid, processId);
        if (_parentPidCache.length >= _maxPidCacheSize) _parentPidCache.clear();
        _parentPidCache[processId] = parentProcessId;
      }

      String parentProcessName;
      if (_parentNameCache.containsKey(parentProcessId)) {
        parentProcessName = _parentNameCache[parentProcessId]!;
      } else {
        parentProcessName =
            await compute(_resolveParentProcessName, parentProcessId);
        if (_parentNameCache.length >= _maxPidCacheSize) {
          _parentNameCache.clear();
        }
        _parentNameCache[parentProcessId] = parentProcessName;
      }

      // AUMID is per-window and identifies the actual packaged app (e.g.
      // "36186RyanBevan.Screenbox_...") rather than the shared
      // ApplicationFrameHost.exe process — prefer it whenever available.
      //
      // Fall back to the executable's basename (e.g. "app.exe") rather than
      // its full path: the full path is not a stable identity for a Win32
      // app — it changes across reinstalls to a different drive/folder,
      // portable-app locations, and (during development) different build
      // output directories for the very same binary, each of which would
      // otherwise fragment one app's tracked history into multiple entries.
      // A basename collision between two unrelated apps sharing a generic
      // exe name is possible but far rarer than that path churn.
      final String appId = aumid.isNotEmpty
          ? aumid
          : (executableName.isEmpty || executableName == 'Unknown'
              ? (processPath.isEmpty ? 'unknown' : processPath)
              : executableName);

      return WindowInfo(
        windowTitle: windowTitle,
        processName: processPath,
        executableName: executableName,
        programName: programName,
        processId: processId,
        parentProcessId: parentProcessId,
        parentProcessName: parentProcessName,
        appId: appId,
      );
    } catch (e, st) {
      debugPrint('ForegroundWindowPlugin: unexpected error: $e\n$st');
      return WindowInfo.unknown();
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

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

  // ── Compute targets ───────────────────────────────────────────────────────

  /// Minimizes all visible top-level windows owned by [pid].
  /// Runs in a compute isolate; uses static FFI bindings loaded fresh there.
  static void _minimizeProcessWindows(int pid) {
    // We need our own DLL reference inside the isolate.
    final user32 = DynamicLibrary.open('user32.dll');

    final getWindowThreadProcessId = user32.lookupFunction<
        Int32 Function(Pointer<Void>, Pointer<Uint32>),
        int Function(Pointer<Void>, Pointer<Uint32>)>('GetWindowThreadProcessId');

    final showWindow = user32.lookupFunction<
        Int32 Function(Pointer<Void>, Int32),
        int Function(Pointer<Void>, int)>('ShowWindow');

    // Dart FFI closures can't be passed as EnumWindows callbacks portably in a
    // compute isolate, so we walk the window chain via GetTopWindow/GetWindow
    // instead and match each window's owning PID.
    final pidBox = calloc<Uint32>();

    // Walk visible windows: we use GetTopWindow / GetNextWindow (GetWindow).
    final getTopWindow = user32.lookupFunction<
        Pointer<Void> Function(Pointer<Void>),
        Pointer<Void> Function(Pointer<Void>)>('GetTopWindow');

    final getNextWindow = user32.lookupFunction<
        Pointer<Void> Function(Pointer<Void>, Uint32),
        Pointer<Void> Function(Pointer<Void>, int)>('GetWindow');

    const gwHwndNext = 2; // GW_HWNDNEXT

    try {
      var hwnd = getTopWindow(nullptr);
      while (hwnd.address != 0) {
        pidBox.value = 0;
        getWindowThreadProcessId(hwnd, pidBox);
        // Don't gate on isWindowVisible: under hard block the blocked app's
        // windows have already been SW_HIDE'd (see TIMER_HIDE_APP in
        // block_overlay/src/lib.rs), so requiring visibility here meant
        // Minimize silently did nothing — the window stayed hidden instead
        // of being restored and minimized to the taskbar.
        if (pidBox.value == pid) {
          showWindow(hwnd, _kSwMinimize);
        }
        hwnd = getNextWindow(hwnd, gwHwndNext);
      }
    } finally {
      calloc.free(pidBox);
    }
  }

  /// Opens [pid] and calls TerminateProcess on it.
  static void _killProcess(int pid) {
    final kernel32 = DynamicLibrary.open('kernel32.dll');

    final openProcess = kernel32.lookupFunction<
        Pointer<Void> Function(Uint32, Int32, Uint32),
        Pointer<Void> Function(int, int, int)>('OpenProcess');

    final terminateProcess = kernel32.lookupFunction<
        Int32 Function(Pointer<Void>, Uint32),
        int Function(Pointer<Void>, int)>('TerminateProcess');

    final closeHandle = kernel32.lookupFunction<
        Int32 Function(Pointer<Void>),
        int Function(Pointer<Void>)>('CloseHandle');

    final hProcess = openProcess(_kProcessTerminate, 0, pid);
    if (hProcess.address == 0) return;
    try {
      terminateProcess(hProcess, 1);
    } finally {
      closeHandle(hProcess);
    }
  }

  /// Queries the full executable image path for [processId] using
  /// QueryFullProcessImageNameW opened with PROCESS_QUERY_LIMITED_INFORMATION.
  /// Works reliably for standard, sandboxed (UWP/AppContainer), and elevated processes.
  static String _queryProcessPath(int processId) {
    if (processId == 0 || processId == 4) return 'System';
    final hProcess =
        _openProcess(_kProcessQueryLimitedInformation, 0, processId);
    if (hProcess.address == 0) return '';
    try {
      final buf = calloc<Uint16>(1024).cast<Utf16>();
      final sizePtr = calloc<Uint32>();
      sizePtr.value = 1024;
      try {
        final result =
            _queryFullProcessImageNameW(hProcess, 0, buf, sizePtr);
        if (result != 0) {
          return buf.toDartString();
        }
        return '';
      } finally {
        calloc.free(buf);
        calloc.free(sizePtr);
      }
    } finally {
      _closeHandle(hProcess);
    }
  }

  /// Step 1 (cheap): returns raw window/process info with NO disk I/O.
  /// Only calls Win32 APIs that are in-memory (no version resource reads,
  /// no CreateToolhelp32Snapshot).
  ///
  /// [targetHwndAddress], if provided, resolves info for that EXACT window
  /// handle instead of querying GetForegroundWindow() fresh — used when the
  /// caller already observed a specific window (e.g. the hwnd carried on a
  /// window_focus onFocusChange event) and needs to avoid a second,
  /// independent "what's foreground right now" query that could race with
  /// focus changing again in between.
  ///
  /// Returns null if no foreground window is found (target mode) or the
  /// target window no longer exists / has address 0.
  static Map<String, dynamic>? _getRawWindowInfo(int? targetHwndAddress) {
    final hwnd = (targetHwndAddress != null && targetHwndAddress != 0)
        ? Pointer<Void>.fromAddress(targetHwndAddress)
        : _getForegroundWindow();
    if (hwnd.address == 0) return null;

    // ── Process ID of top-level window ──
    final processIdPtr = calloc<Uint32>();
    late final int rawPid;
    try {
      _getWindowThreadProcessId(hwnd, processIdPtr);
      rawPid = processIdPtr.value;
    } finally {
      calloc.free(processIdPtr);
    }
    if (rawPid == 0) return null;

    // ── Window title (Unicode) ──
    final titlePtr = calloc<Uint16>(_kMaxTitle).cast<Utf16>();
    late final String windowTitle;
    try {
      final len = _getWindowTextW(hwnd, titlePtr, _kMaxTitle);
      windowTitle = len > 0 ? titlePtr.toDartString() : '';
    } finally {
      calloc.free(titlePtr);
    }

    // ── Window class name (Unicode) ──
    final classPtr = calloc<Uint16>(256).cast<Utf16>();
    late final String windowClass;
    try {
      final len = _getClassNameW(hwnd, classPtr, 256);
      windowClass = len > 0 ? classPtr.toDartString() : '';
    } finally {
      calloc.free(classPtr);
    }

    int targetPid = rawPid;
    Pointer<Void> targetHwnd = hwnd;

    // ── Check for ApplicationFrameWindow (UWP host) ──
    // In Windows 10/11, ApplicationFrameHost.exe hosts classic UWP / XAML apps.
    // The top-level window is class "ApplicationFrameWindow" (owned by ApplicationFrameHost.exe).
    // The actual UWP app lives in a child window ("Windows.UI.Core.CoreWindow")
    // owned by the real app process (e.g. Screenbox.exe, CalculatorApp.exe, etc.).
    if (windowClass.toLowerCase() == 'applicationframewindow') {
      final coreClassPtr = 'Windows.UI.Core.CoreWindow'.toNativeUtf16();
      try {
        final childHwnd = _findWindowExW(hwnd, nullptr, coreClassPtr, nullptr);
        if (childHwnd.address != 0) {
          final childPidPtr = calloc<Uint32>();
          try {
            _getWindowThreadProcessId(childHwnd, childPidPtr);
            if (childPidPtr.value != 0 && childPidPtr.value != rawPid) {
              targetPid = childPidPtr.value;
              targetHwnd = childHwnd;
            }
          } finally {
            calloc.free(childPidPtr);
          }
        }
      } finally {
        calloc.free(coreClassPtr);
      }
    }

    // ── Exe path via QueryFullProcessImageNameW (Unicode, works with limited query) ──
    String processPath = _queryProcessPath(targetPid);
    String executableName = 'Unknown';
    bool elevated = false;

    if (processPath.isNotEmpty) {
      executableName = _extractExecutableName(processPath);
    } else {
      // Fallback: try rawPid if targetPid had no path
      if (targetPid != rawPid) {
        processPath = _queryProcessPath(rawPid);
        if (processPath.isNotEmpty) {
          executableName = _extractExecutableName(processPath);
        }
      }
      if (processPath.isEmpty) {
        elevated = true;
      }
    }

    // If still ApplicationFrameHost after child search, check if child can be found again
    if (processPath.toLowerCase().endsWith('applicationframehost.exe') &&
        targetPid == rawPid) {
      final coreClassPtr = 'Windows.UI.Core.CoreWindow'.toNativeUtf16();
      try {
        final childHwnd = _findWindowExW(hwnd, nullptr, coreClassPtr, nullptr);
        if (childHwnd.address != 0) {
          final childPidPtr = calloc<Uint32>();
          try {
            _getWindowThreadProcessId(childHwnd, childPidPtr);
            if (childPidPtr.value != 0 && childPidPtr.value != rawPid) {
              targetPid = childPidPtr.value;
              targetHwnd = childHwnd;
              final childPath = _queryProcessPath(targetPid);
              if (childPath.isNotEmpty) {
                processPath = childPath;
                executableName = _extractExecutableName(processPath);
              }
            }
          } finally {
            calloc.free(childPidPtr);
          }
        }
      } finally {
        calloc.free(coreClassPtr);
      }
    }

    // ── AUMID lookup ──
    final lowerExe = executableName.toLowerCase();
    final lowerPath = processPath.toLowerCase();
    final isPackagedOrBroker = processPath.isEmpty ||
        targetPid != rawPid ||
        lowerExe == 'applicationframehost' ||
        lowerExe == 'runtimebroker' ||
        lowerExe == 'searchhost' ||
        lowerPath.endsWith('applicationframehost.exe') ||
        lowerPath.endsWith('runtimebroker.exe') ||
        lowerPath.endsWith('searchhost.exe') ||
        lowerPath.contains(r'\windowsapps\') ||
        lowerPath.contains(r'\systemapps\');

    String aumid = '';
    if (isPackagedOrBroker) {
      // 1. Try querying the target PID
      aumid = _getAumidForProcess(targetPid);
      // 2. If targetPid != rawPid and empty, try rawPid
      if (aumid.isEmpty && targetPid != rawPid) {
        aumid = _getAumidForProcess(rawPid);
      }
      // 3. Fallback to COM SHGetPropertyStoreForWindow on target HWND
      if (aumid.isEmpty && targetHwnd.address != 0) {
        aumid = _getAumidForWindow(targetHwnd);
      }
      // 4. Fallback to top-level HWND
      if (aumid.isEmpty && targetHwnd != hwnd) {
        aumid = _getAumidForWindow(hwnd);
      }
    }

    return {
      'processPath': processPath,
      'windowTitle': windowTitle,
      'executableName': executableName,
      'processId': targetPid,
      'elevated': elevated,
      'aumid': aumid,
    };
  }

  /// Step 2a (on cache miss): reads the PE version resource from disk to get
  /// the human-readable program name. Only called once per unique exe path.
  static String _resolveVersionInfo(String fullPath) {
    return _getProgramNameFromVersionInfo(fullPath);
  }

  /// Step 2b (on cache miss): runs CreateToolhelp32Snapshot to find the
  /// parent PID for the given process ID. Only called once per unique PID.
  static int _resolveParentPid(int processId) {
    return _getParentProcessId(processId);
  }

  /// Step 2c (on cache miss): opens the parent process to get its exe name.
  /// Only called once per unique parent PID.
  static String _resolveParentProcessName(int processId) {
    return _getProcessNameById(processId);
  }

  /// Reads the Application User Model ID (AUMID) for the window with process
  /// ID [processId] via GetApplicationUserModelId (kernel32.dll) — a direct,
  /// non-COM lookup on a process handle opened with
  /// PROCESS_QUERY_LIMITED_INFORMATION, which succeeds even on protected
  /// processes (like RuntimeBroker.exe) that PROCESS_QUERY_INFORMATION
  /// cannot open. This is the simpler, preferred path — the COM-based
  /// _getAumidForWindow is a fallback for cases this doesn't cover.
  ///
  /// Returns '' if the process isn't a packaged/UWP app (most commonly
  /// error 15703, APPMODEL_ERROR_NO_APPLICATION) or the handle can't be
  /// opened at all.
  static String _getAumidForProcess(int processId) {
    final hProcess = _openProcess(
        _kProcessQueryLimitedInformation, 0, processId);
    if (hProcess.address == 0) {
      debugPrint('AUMID: OpenProcess(QUERY_LIMITED_INFORMATION) failed for '
          'pid=$processId');
      return '';
    }

    try {
      // First call with a generous buffer — GetApplicationUserModelId wants
      // the buffer length in WCHARs (not bytes) both in and out.
      const bufferChars = 130; // AUMIDs are capped at 128 chars + null
      final lenPtr = calloc<Uint32>();
      final bufPtr = calloc<Uint16>(bufferChars).cast<Utf16>();
      try {
        lenPtr.value = bufferChars;
        final result =
            _getApplicationUserModelId(hProcess, lenPtr, bufPtr);
        if (result != 0) {
          // Not an error we need to surface loudly — this is the expected,
          // common outcome for every non-packaged Win32 process.
          if (result != 15703 /* APPMODEL_ERROR_NO_APPLICATION */) {
            debugPrint('AUMID: GetApplicationUserModelId failed for '
                'pid=$processId, error=$result');
          }
          return '';
        }
        return bufPtr.toDartString();
      } finally {
        calloc.free(lenPtr);
        calloc.free(bufPtr);
      }
    } finally {
      _closeHandle(hProcess);
    }
  }

  /// Reads the Application User Model ID (AUMID) for [hwnd] via
  /// SHGetPropertyStoreForWindow + IPropertyStore::GetValue(PKEY_AppUserModel_ID).
  /// This is the stable identity Windows itself uses for UWP/packaged apps,
  /// which is otherwise unreachable — apps hosted under
  /// ApplicationFrameHost.exe all share that host's exe path, so the only
  /// way to distinguish "Screenbox" from "Photos" from "Calculator" is the
  /// per-window AUMID, not the process.
  ///
  /// Fallback only — tried when [_getAumidForProcess] doesn't return a
  /// value, e.g. if the window's owning process differs from the one the
  /// AUMID needs to be queried against.
  ///
  /// Returns '' if the window has no AUMID (i.e. it's a normal Win32 app —
  /// callers should only invoke this for ApplicationFrameHost-hosted windows)
  /// or if anything in the COM call chain fails.
  ///
  /// NOT part of the "cheap, no I/O" Step 1 path in the general case — only
  /// called for the ApplicationFrameHost special case, gated by the caller.
  static String _getAumidForWindow(Pointer<Void> hwnd) {
    // COM requires per-thread initialization; this runs inside a compute()
    // isolate, so there is no ambient apartment to rely on — init/uninit on
    // every call.
    final hr = _coInitializeEx(nullptr, 0 /* COINIT_MULTITHREADED */);
    // S_OK = 0, S_FALSE = 1 (already initialized) are both fine; anything
    // else means COM isn't usable here.
    final comInitialized = hr == 0 || hr == 1;
    if (!comInitialized) {
      debugPrint('AUMID: CoInitializeEx failed, hr=0x${hr.toRadixString(16)}');
      return '';
    }

    Pointer<GUID>? iidPropertyStorePtr;
    Pointer<Pointer<Void>>? propertyStorePtrPtr;
    Pointer<PROPERTYKEY>? pkeyPtr;
    Pointer<PROPVARIANT>? propvarPtr;

    try {
      // IID_IPropertyStore = {886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99}
      iidPropertyStorePtr = GUID.allocate(
        0x886D8EEB,
        0x8CF2,
        0x4446,
        [0x8D, 0x02, 0xCD, 0xBA, 0x1D, 0xBD, 0xCF, 0x99],
      );

      propertyStorePtrPtr = calloc<Pointer<Void>>();
      final hrStore = _shGetPropertyStoreForWindow(
          hwnd, iidPropertyStorePtr, propertyStorePtrPtr);
      if (hrStore != 0 || propertyStorePtrPtr.value.address == 0) {
        debugPrint('AUMID: SHGetPropertyStoreForWindow failed, '
            'hr=0x${(hrStore & 0xFFFFFFFF).toRadixString(16)}, '
            'ptr=${propertyStorePtrPtr.value.address}');
        return '';
      }

      final propertyStore = propertyStorePtrPtr.value;
      // IUnknown/IPropertyStore vtable layout:
      // 0 QueryInterface, 1 AddRef, 2 Release,
      // 3 GetCount, 4 GetAt, 5 GetValue, 6 SetValue, 7 Commit
      final vtable = propertyStore.cast<Pointer<NativeFunction>>().value;
      final vtablePtrs = vtable.cast<Pointer<NativeFunction>>();

      try {
        final getValue = (vtablePtrs + 5)
            .value
            .cast<
                NativeFunction<
                    Int32 Function(Pointer<Void>, Pointer<PROPERTYKEY>,
                        Pointer<PROPVARIANT>)>>()
            .asFunction<
                int Function(
                    Pointer<Void>, Pointer<PROPERTYKEY>, Pointer<PROPVARIANT>)>();

        // PKEY_AppUserModel_ID = {9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}, pid 5
        pkeyPtr = calloc<PROPERTYKEY>();
        final pkey = pkeyPtr.ref;
        pkey.fmtidData1 = 0x9F4C2855;
        pkey.fmtidData2 = 0x9F79;
        pkey.fmtidData3 = 0x4B39;
        const fmtidTail = [0xA8, 0xD0, 0xE1, 0xD4, 0x2D, 0xE1, 0xD5, 0xF3];
        for (int i = 0; i < 8; i++) {
          pkey.fmtidData4[i] = fmtidTail[i];
        }
        pkey.pid = 5;

        propvarPtr = calloc<PROPVARIANT>();
        final hrValue = getValue(propertyStore, pkeyPtr, propvarPtr);

        String aumid = '';
        if (hrValue == 0) {
          const vtLpwstr = 31;
          final propvar = propvarPtr.ref;
          if (propvar.vt == vtLpwstr && propvar.pwszVal.address != 0) {
            aumid = propvar.pwszVal.toDartString();
          } else {
            debugPrint('AUMID: GetValue returned S_OK but vt=${propvar.vt} '
                '(expected $vtLpwstr), ptr=${propvar.pwszVal.address} '
                '— property not present on this window');
          }
        } else {
          debugPrint('AUMID: IPropertyStore::GetValue failed, '
              'hr=0x${(hrValue & 0xFFFFFFFF).toRadixString(16)}');
        }
        return aumid;
      } finally {
        // Release the IPropertyStore (vtable index 2).
        final release = (vtablePtrs + 2)
            .value
            .cast<NativeFunction<Int32 Function(Pointer<Void>)>>()
            .asFunction<int Function(Pointer<Void>)>();
        release(propertyStore);
      }
    } catch (e) {
      debugPrint('ForegroundWindowPlugin: AUMID lookup failed: $e');
      return '';
    } finally {
      if (iidPropertyStorePtr != null) calloc.free(iidPropertyStorePtr);
      if (propertyStorePtrPtr != null) calloc.free(propertyStorePtrPtr);
      if (pkeyPtr != null) calloc.free(pkeyPtr);
      if (propvarPtr != null) {
        // pwszVal inside the PROPVARIANT was allocated by the shell via
        // CoTaskMemAlloc; PropVariantClear is the "correct" API to free the
        // whole variant, but ole32 exports it too — free just the string
        // pointer directly via CoTaskMemFree to keep this self-contained.
        if (propvarPtr.ref.vt == 31 && propvarPtr.ref.pwszVal.address != 0) {
          _coTaskMemFree(propvarPtr.ref.pwszVal.cast<Void>());
        }
        calloc.free(propvarPtr);
      }
      if (comInitialized) _coUninitialize();
    }
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
    if (processId == 0 || processId == 4) return 'System';
    final path = _queryProcessPath(processId);
    if (path.isNotEmpty) return path;
    return 'Unknown';
  }
}
