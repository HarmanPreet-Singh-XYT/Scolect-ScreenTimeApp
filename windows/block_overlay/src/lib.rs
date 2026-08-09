//! block_overlay — Win32 overlay panel for Scolect Windows block mode.
//!
//! Exposes three C-ABI functions used by flutter_window.cpp:
//!   block_overlay_show(pid, app_name, used_seconds, limit_seconds, hard_block, callback)
//!   block_overlay_dismiss()
//!   block_overlay_start_grace(seconds)
//!
//! Architecture
//! ────────────
//! A dedicated Win32 thread owns the HWND and message loop so that blocking
//! Win32 calls (GetMessage, SendMessage) don't stall Flutter's UI thread.
//! Commands from the C-API thread are sent via a global Mutex<Command> plus a
//! PostThreadMessage(WM_APP) wake-up.  The callback fires directly from the
//! Win32 thread (safe: it just does PostMessage back to the Flutter main hwnd).
//!
//! Rendering uses GDI+ (anti-aliased fills/paths/text) composited into a GDI
//! back-buffer, matching the Fluent-ish look of the rest of the app instead of
//! raw un-antialiased GDI primitives.

#![allow(non_snake_case, non_camel_case_types, dead_code)]

use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::sync::{Mutex, Once, OnceLock};
use std::thread;

use windows::core::{PCSTR, PCWSTR};
use windows::Win32::Foundation::{COLORREF, HINSTANCE, HWND, LPARAM, LRESULT, POINT, RECT, WPARAM};
use windows::Win32::Graphics::Dwm::{DwmEnableBlurBehindWindow, DWM_BB_ENABLE, DWM_BLURBEHIND};
use windows::Win32::Graphics::Gdi::{
    BeginPaint, BitBlt, CreateCompatibleBitmap, CreateCompatibleDC, DeleteDC, DeleteObject,
    EndPaint, SelectObject, HBITMAP, HDC, HRGN, PAINTSTRUCT, SRCCOPY,
};
use windows::Win32::Graphics::GdiPlus::{
    GdipAddPathArcI, GdipClosePathFigure, GdipCreateFont, GdipCreateFontFamilyFromName,
    GdipCreateFromHDC, GdipCreatePath, GdipCreatePen1, GdipCreateSolidFill,
    GdipCreateStringFormat, GdipDeleteBrush, GdipDeleteFont, GdipDeleteFontFamily,
    GdipDeleteGraphics, GdipDeletePath, GdipDeletePen, GdipDeleteStringFormat, GdipDrawLineI,
    GdipDrawPath, GdipDrawString, GdipFillEllipseI, GdipFillPath, GdipScaleWorldTransform,
    GdipSetSmoothingMode, GdipSetStringFormatAlign, GdipSetStringFormatLineAlign,
    GdipSetTextRenderingHint, GdiplusStartup, FillModeAlternate, FontStyleBold,
    FontStyleRegular, GdiplusStartupInput, GdiplusStartupOutput, GpBrush, GpFont, GpFontFamily,
    GpGraphics, GpPath, GpPen, GpSolidFill, GpStringFormat, MatrixOrderPrepend, RectF,
    SmoothingModeAntiAlias, StringAlignmentCenter, StringAlignmentNear,
    TextRenderingHintAntiAliasGridFit, UnitPixel,
};
use windows::Win32::System::LibraryLoader::GetModuleHandleA;
use windows::Win32::System::Registry::{
    RegOpenKeyExA, RegQueryValueExA, HKEY_CURRENT_USER, KEY_READ, REG_VALUE_TYPE,
};
use windows::Win32::UI::HiDpi::GetDpiForWindow;
use windows::Win32::UI::WindowsAndMessaging::{
    CreateWindowExA, DefWindowProcA, DestroyWindow, DispatchMessageA, EnumWindows,
    GetClientRect, GetForegroundWindow, GetMessageA, GetSystemMetrics, GetWindowRect,
    GetWindowThreadProcessId, LoadCursorW, PostThreadMessageA, RegisterClassExA,
    SetLayeredWindowAttributes, SetTimer, SetWindowPos, ShowWindow, TranslateMessage,
    CS_HREDRAW, CS_VREDRAW, GWLP_USERDATA, HWND_TOPMOST, IDC_ARROW, LWA_ALPHA, MSG,
    SM_CXSCREEN, SM_CYSCREEN, SWP_NOMOVE, SWP_NOSIZE, SWP_NOACTIVATE, WM_APP, WM_DESTROY,
    WM_LBUTTONDOWN, WM_PAINT, WM_TIMER, WNDCLASSEXA, WS_EX_LAYERED, WS_EX_NOACTIVATE,
    WS_EX_TOPMOST, WS_POPUP, SW_HIDE, SW_SHOWNOACTIVATE, SetWindowLongPtrA, GetWindowLongPtrA,
};

// ─── Constants ────────────────────────────────────────────────────────────────

const WM_CMD_SHOW: u32 = WM_APP + 2;
const WM_CMD_DISMISS: u32 = WM_APP + 3;
const WM_CMD_GRACE: u32 = WM_APP + 4;

const TIMER_REPOSITION: usize = 1;
const TIMER_GRACE: usize = 2;
const TIMER_HIDE_APP: usize = 3;

const CARD_W: i32 = 408;
const CARD_H: i32 = 460;

// ─── Color helpers ────────────────────────────────────────────────────────────

fn rgb(r: u8, g: u8, b: u8) -> COLORREF {
    COLORREF(r as u32 | ((g as u32) << 8) | ((b as u32) << 16))
}

/// Packs an ARGB color the way GDI+ expects it (0xAARRGGBB).
fn argb(a: u8, r: u8, g: u8, b: u8) -> u32 {
    ((a as u32) << 24) | ((r as u32) << 16) | ((g as u32) << 8) | (b as u32)
}

/// UTF-16, null-terminated — GDI+ string APIs take PCWSTR.
fn wide(s: &str) -> Vec<u16> {
    s.encode_utf16().chain(std::iter::once(0)).collect()
}

// ─── Dark-mode detection ──────────────────────────────────────────────────────

fn is_dark_mode() -> bool {
    unsafe {
        let mut hkey = windows::Win32::System::Registry::HKEY::default();
        let subkey =
            b"Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize\0";
        let r = RegOpenKeyExA(
            HKEY_CURRENT_USER,
            PCSTR(subkey.as_ptr()),
            Some(0),
            KEY_READ,
            &mut hkey,
        );
        if r.is_err() {
            return false;
        }
        let value_name = b"AppsUseLightTheme\0";
        let mut data: u32 = 1;
        let mut data_size: u32 = 4;
        let mut vtype = REG_VALUE_TYPE::default();
        let _ = RegQueryValueExA(
            hkey,
            PCSTR(value_name.as_ptr()),
            None,
            Some(&mut vtype),
            Some(&mut data as *mut u32 as *mut u8),
            Some(&mut data_size),
        );
        let _ = windows::Win32::System::Registry::RegCloseKey(hkey);
        data == 0
    }
}

// ─── GDI+ lifecycle ───────────────────────────────────────────────────────────
// GDI+ must be started once before any Gdip* call. We never shut it down —
// this DLL lives for the whole process lifetime and calling GdiplusShutdown
// from an arbitrary thread late in shutdown is more risk than it's worth.

static GDIPLUS_INIT: Once = Once::new();

fn ensure_gdiplus() {
    GDIPLUS_INIT.call_once(|| unsafe {
        let input = GdiplusStartupInput {
            GdiplusVersion: 1,
            ..Default::default()
        };
        let mut output = GdiplusStartupOutput::default();
        let mut token: usize = 0;
        let _ = GdiplusStartup(&mut token, &input, &mut output);
    });
}

// ─── Global state ─────────────────────────────────────────────────────────────

#[derive(Clone)]
struct ShowArgs {
    pid: u32,
    app_name: String,
    used_seconds: i32,
    limit_seconds: i32,
    hard_block: bool,
}

// Queued command sent to the Win32 thread via PostThreadMessage(WM_APP+N).
enum Command {
    Show(ShowArgs),
    Dismiss,
    Grace(i32),
}

struct GlobalState {
    // Win32 thread ID, needed for PostThreadMessage
    thread_id: u32,
    // The HWND of the scrim window (set by the Win32 thread)
    hwnd: HWND,
    // Callback function pointer
    callback: Option<extern "C" fn(*const c_char)>,
    // Pending command (replaced atomically by the C-API thread)
    pending_command: Option<Command>,
}

unsafe impl Send for GlobalState {}
unsafe impl Sync for GlobalState {}

static GLOBAL: OnceLock<Mutex<GlobalState>> = OnceLock::new();

fn global() -> &'static Mutex<GlobalState> {
    GLOBAL.get_or_init(|| {
        Mutex::new(GlobalState {
            thread_id: 0,
            hwnd: HWND(std::ptr::null_mut()),
            callback: None,
            pending_command: None,
        })
    })
}

// ─── Per-window state (stored in GWLP_USERDATA) ───────────────────────────────

struct WindowState {
    args: ShowArgs,
    dark: bool,
    // Rects for hit-testing (in client coords)
    btn_minimize: RECT,
    btn_quit: RECT,
    btn_grace: RECT,
    btn_unblock: RECT,
    // Grace countdown
    grace_active: bool,
    grace_seconds_left: i32,
    grace_used: bool, // greyed-out once clicked
    // HWND of the blocked app (found by PID)
    blocked_hwnd: HWND,
}

// ─── C-ABI exports ─────────────────────────────────────────────────────────────

/// Show the overlay. `hard_block = true` → full-screen TOPMOST.
/// `callback` fires from the Win32 thread with one of: "minimize", "quit",
/// "grace", "unblock", "dismiss".
#[no_mangle]
pub extern "C" fn block_overlay_show(
    pid: u32,
    app_name: *const c_char,
    used_seconds: i32,
    limit_seconds: i32,
    hard_block: bool,
    callback: extern "C" fn(*const c_char),
) {
    let name = if app_name.is_null() {
        String::from("Unknown")
    } else {
        unsafe { CStr::from_ptr(app_name) }
            .to_string_lossy()
            .into_owned()
    };

    let args = ShowArgs {
        pid,
        app_name: name,
        used_seconds,
        limit_seconds,
        hard_block,
    };

    {
        let mut g = global().lock().unwrap();
        g.callback = Some(callback);
        g.pending_command = Some(Command::Show(args));
    }

    ensure_thread_running();
    post_to_thread(WM_CMD_SHOW);
}

/// Dismiss the overlay.
#[no_mangle]
pub extern "C" fn block_overlay_dismiss() {
    {
        let mut g = global().lock().unwrap();
        g.pending_command = Some(Command::Dismiss);
    }
    ensure_thread_running();
    post_to_thread(WM_CMD_DISMISS);
}

/// Start/update the grace countdown badge (seconds).
#[no_mangle]
pub extern "C" fn block_overlay_start_grace(seconds: i32) {
    {
        let mut g = global().lock().unwrap();
        g.pending_command = Some(Command::Grace(seconds));
    }
    ensure_thread_running();
    post_to_thread(WM_CMD_GRACE);
}

// ─── Thread management ────────────────────────────────────────────────────────

fn ensure_thread_running() {
    let tid = global().lock().unwrap().thread_id;
    if tid == 0 {
        // Spawn the Win32 message-loop thread once.
        thread::Builder::new()
            .name("block_overlay_win32".into())
            .spawn(win32_thread)
            .expect("Failed to spawn overlay thread");
        // Give it a moment to register its thread ID.
        // (The thread sets thread_id before pumping messages.)
        std::thread::sleep(std::time::Duration::from_millis(20));
    }
}

fn post_to_thread(msg: u32) {
    let tid = global().lock().unwrap().thread_id;
    if tid != 0 {
        unsafe {
            let _ = PostThreadMessageA(tid, msg, WPARAM(0), LPARAM(0));
        }
    }
}

fn fire_callback(action: &str) {
    let cb = global().lock().unwrap().callback;
    if let Some(cb) = cb {
        let cs = CString::new(action).unwrap_or_default();
        cb(cs.as_ptr());
    }
}

// ─── Win32 thread ─────────────────────────────────────────────────────────────

fn win32_thread() {
    unsafe {
        // Register our thread ID so C-API callers can PostThreadMessage.
        let tid = windows::Win32::System::Threading::GetCurrentThreadId();
        global().lock().unwrap().thread_id = tid;

        ensure_gdiplus();

        // Register window class once per process.
        let hinstance = GetModuleHandleA(None).unwrap_or_default();
        let class_name = b"ScolectBlockOverlay\0";
        let wc = WNDCLASSEXA {
            cbSize: std::mem::size_of::<WNDCLASSEXA>() as u32,
            style: CS_HREDRAW | CS_VREDRAW,
            lpfnWndProc: Some(wndproc),
            hInstance: hinstance.into(),
            hCursor: LoadCursorW(None, IDC_ARROW).unwrap_or_default(),
            hbrBackground: windows::Win32::Graphics::Gdi::HBRUSH(std::ptr::null_mut()),
            lpszClassName: PCSTR(class_name.as_ptr()),
            ..Default::default()
        };
        // Ignore error if already registered (happens if DLL is re-used).
        let _ = RegisterClassExA(&wc);

        // Pump messages until WM_QUIT.
        let mut msg = MSG::default();
        loop {
            let ret = GetMessageA(&mut msg, None, 0, 0);
            if ret.0 <= 0 {
                break;
            }
            // Handle thread messages (no HWND).
            if msg.hwnd.0.is_null() {
                match msg.message {
                    WM_CMD_SHOW => handle_cmd_show(),
                    WM_CMD_DISMISS => handle_cmd_dismiss(),
                    WM_CMD_GRACE => handle_cmd_grace(),
                    _ => {}
                }
                continue;
            }
            let _ = TranslateMessage(&msg);
            DispatchMessageA(&msg);
        }

        // Thread exiting — clear our thread ID.
        global().lock().unwrap().thread_id = 0;
    }
}

// ─── Command handlers (run on Win32 thread) ───────────────────────────────────

unsafe fn handle_cmd_show() {
    // Consume pending command.
    let args = {
        let mut g = global().lock().unwrap();
        match g.pending_command.take() {
            Some(Command::Show(a)) => a,
            _ => return,
        }
    };

    // Dismiss any existing overlay first.
    destroy_overlay_window();

    let dark = is_dark_mode();
    let blocked_hwnd = find_hwnd_for_pid(args.pid).unwrap_or(HWND(std::ptr::null_mut()));

    // Determine window rect.
    let (wx, wy, ww, wh) = if args.hard_block {
        // Full primary monitor.
        let sw = GetSystemMetrics(SM_CXSCREEN);
        let sh = GetSystemMetrics(SM_CYSCREEN);
        (0i32, 0i32, sw, sh)
    } else {
        // Cover the blocked app's window.
        if blocked_hwnd.0.is_null() {
            let sw = GetSystemMetrics(SM_CXSCREEN);
            let sh = GetSystemMetrics(SM_CYSCREEN);
            (0i32, 0i32, sw, sh)
        } else {
            let mut r = RECT::default();
            let _ = GetWindowRect(blocked_hwnd, &mut r);
            (r.left, r.top, r.right - r.left, r.bottom - r.top)
        }
    };

    let hinstance = GetModuleHandleA(None).unwrap_or_default();
    let class_name = b"ScolectBlockOverlay\0";
    let title = b"ScolectBlockOverlay\0";

    // WS_EX_LAYERED for alpha, WS_EX_NOACTIVATE to avoid stealing focus.
    let ex_style = WS_EX_LAYERED | WS_EX_NOACTIVATE | WS_EX_TOPMOST;

    let hwnd = CreateWindowExA(
        ex_style,
        PCSTR(class_name.as_ptr()),
        PCSTR(title.as_ptr()),
        WS_POPUP,
        wx,
        wy,
        ww,
        wh,
        None,
        None,
        Some(HINSTANCE(hinstance.0)),
        None,
    )
    .unwrap_or_default();

    if hwnd.0.is_null() {
        return;
    }

    // Ask DWM to blur whatever's behind the window (best-effort — this is
    // silently ignored on Windows versions/configs that don't support it, in
    // which case the translucent scrim fill below is the fallback).
    let blur = DWM_BLURBEHIND {
        dwFlags: DWM_BB_ENABLE,
        fEnable: true.into(),
        hRgnBlur: HRGN(std::ptr::null_mut()),
        fTransitionOnMaximized: false.into(),
    };
    let _ = DwmEnableBlurBehindWindow(hwnd, &blur);

    // Visibly translucent so the blurred backdrop/blocked app reads through.
    let _ = SetLayeredWindowAttributes(hwnd, COLORREF(0), 210, LWA_ALPHA);

    // Allocate per-window state on the heap, store ptr in GWLP_USERDATA.
    let ws = Box::new(WindowState {
        args: args.clone(),
        dark,
        btn_minimize: RECT::default(),
        btn_quit: RECT::default(),
        btn_grace: RECT::default(),
        btn_unblock: RECT::default(),
        grace_active: false,
        grace_seconds_left: 0,
        grace_used: false,
        blocked_hwnd,
    });
    let ws_ptr = Box::into_raw(ws);
    SetWindowLongPtrA(hwnd, GWLP_USERDATA, ws_ptr as isize);

    // Store HWND globally.
    global().lock().unwrap().hwnd = hwnd;

    // Show without activating.
    ShowWindow(hwnd, SW_SHOWNOACTIVATE);

    // Bring to absolute top.
    let _ = SetWindowPos(
        hwnd,
        Some(HWND_TOPMOST),
        0,
        0,
        0,
        0,
        SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE,
    );

    if args.hard_block {
        // Hide blocked app after 300ms.
        let _ = SetTimer(Some(hwnd), TIMER_HIDE_APP, 300, None);
    } else {
        // Reposition scrim over blocked app every 100ms.
        let _ = SetTimer(Some(hwnd), TIMER_REPOSITION, 100, None);
    }
}

unsafe fn handle_cmd_dismiss() {
    {
        let mut g = global().lock().unwrap();
        g.pending_command = None;
    }
    destroy_overlay_window();
}

unsafe fn handle_cmd_grace() {
    let seconds = {
        let mut g = global().lock().unwrap();
        match g.pending_command.take() {
            Some(Command::Grace(s)) => s,
            _ => return,
        }
    };

    let hwnd = global().lock().unwrap().hwnd;
    if hwnd.0.is_null() {
        return;
    }

    let ws_ptr = GetWindowLongPtrA(hwnd, GWLP_USERDATA) as *mut WindowState;
    if ws_ptr.is_null() {
        return;
    }
    let ws = &mut *ws_ptr;
    ws.grace_active = true;
    ws.grace_seconds_left = seconds;

    // Tick every second.
    let _ = SetTimer(Some(hwnd), TIMER_GRACE, 1000, None);

    // Force repaint to show grace badge.
    let _ = windows::Win32::Graphics::Gdi::InvalidateRect(Some(hwnd), None, false);
}

unsafe fn destroy_overlay_window() {
    let hwnd = {
        let mut g = global().lock().unwrap();
        let h = g.hwnd;
        g.hwnd = HWND(std::ptr::null_mut());
        h
    };
    if !hwnd.0.is_null() {
        // Free per-window state.
        let ws_ptr = GetWindowLongPtrA(hwnd, GWLP_USERDATA) as *mut WindowState;
        if !ws_ptr.is_null() {
            SetWindowLongPtrA(hwnd, GWLP_USERDATA, 0);
            drop(Box::from_raw(ws_ptr));
        }
        let _ = DestroyWindow(hwnd);
    }
}

// ─── Find HWND by PID ─────────────────────────────────────────────────────────

struct FindByPid {
    pid: u32,
    result: HWND,
}

unsafe extern "system" fn enum_windows_find_pid(hwnd: HWND, lparam: LPARAM) -> windows::core::BOOL {
    let ctx = &mut *(lparam.0 as *mut FindByPid);
    let mut win_pid: u32 = 0;
    GetWindowThreadProcessId(hwnd, Some(&mut win_pid));
    if win_pid == ctx.pid {
        // Only pick a visible window with a non-empty title.
        let visible = windows::Win32::UI::WindowsAndMessaging::IsWindowVisible(hwnd);
        if visible.as_bool() {
            ctx.result = hwnd;
            return false.into(); // stop enumeration
        }
    }
    true.into()
}

fn find_hwnd_for_pid(pid: u32) -> Option<HWND> {
    let mut ctx = FindByPid {
        pid,
        result: HWND(std::ptr::null_mut()),
    };
    unsafe {
        let _ = EnumWindows(
            Some(enum_windows_find_pid),
            LPARAM(&mut ctx as *mut _ as isize),
        );
    }
    if ctx.result.0.is_null() {
        None
    } else {
        Some(ctx.result)
    }
}

// ─── Window Procedure ─────────────────────────────────────────────────────────

unsafe extern "system" fn wndproc(
    hwnd: HWND,
    msg: u32,
    wparam: WPARAM,
    lparam: LPARAM,
) -> LRESULT {
    match msg {
        WM_PAINT => {
            on_paint(hwnd);
            LRESULT(0)
        }
        WM_LBUTTONDOWN => {
            on_click(hwnd, lparam);
            LRESULT(0)
        }
        WM_TIMER => {
            on_timer(hwnd, wparam.0);
            LRESULT(0)
        }
        WM_DESTROY => {
            // Do NOT call PostQuitMessage here — the Win32 thread must stay alive
            // for subsequent show() calls. PostQuitMessage would exit the message
            // loop and prevent re-use. The thread is intentionally long-lived.
            LRESULT(0)
        }
        _ => DefWindowProcA(hwnd, msg, wparam, lparam),
    }
}

// ─── GDI+ drawing helpers ───────────────────────────────────────────────────────
// Small wrappers around the flat GDI+ C API so on_paint reads like a UI layout
// instead of a wall of raw FFI. Everything here draws anti-aliased, unlike the
// raw GDI RoundRect/DrawTextA calls this replaced.

unsafe fn round_rect_path(x: i32, y: i32, w: i32, h: i32, d: i32) -> *mut GpPath {
    let d = d.min(w).min(h);
    let mut path: *mut GpPath = std::ptr::null_mut();
    let _ = GdipCreatePath(FillModeAlternate, &mut path);
    let _ = GdipAddPathArcI(path, x, y, d, d, 180.0, 90.0);
    let _ = GdipAddPathArcI(path, x + w - d, y, d, d, 270.0, 90.0);
    let _ = GdipAddPathArcI(path, x + w - d, y + h - d, d, d, 0.0, 90.0);
    let _ = GdipAddPathArcI(path, x, y + h - d, d, d, 90.0, 90.0);
    let _ = GdipClosePathFigure(path);
    path
}

unsafe fn fill_round_rect(g: *mut GpGraphics, x: i32, y: i32, w: i32, h: i32, d: i32, color: u32) {
    let path = round_rect_path(x, y, w, h, d);
    let mut brush: *mut GpSolidFill = std::ptr::null_mut();
    let _ = GdipCreateSolidFill(color, &mut brush);
    let _ = GdipFillPath(g, brush as *mut GpBrush, path);
    let _ = GdipDeleteBrush(brush as *mut GpBrush);
    let _ = GdipDeletePath(path);
}

unsafe fn stroke_round_rect(g: *mut GpGraphics, x: i32, y: i32, w: i32, h: i32, d: i32, color: u32, width: f32) {
    let path = round_rect_path(x, y, w, h, d);
    let mut pen: *mut GpPen = std::ptr::null_mut();
    let _ = GdipCreatePen1(color, width, UnitPixel, &mut pen);
    let _ = GdipDrawPath(g, pen, path);
    let _ = GdipDeletePen(pen);
    let _ = GdipDeletePath(path);
}

unsafe fn fill_ellipse(g: *mut GpGraphics, x: i32, y: i32, d: i32, color: u32) {
    let mut brush: *mut GpSolidFill = std::ptr::null_mut();
    let _ = GdipCreateSolidFill(color, &mut brush);
    let _ = GdipFillEllipseI(g, brush as *mut GpBrush, x, y, d, d);
    let _ = GdipDeleteBrush(brush as *mut GpBrush);
}

unsafe fn draw_line(g: *mut GpGraphics, x1: i32, y1: i32, x2: i32, y2: i32, color: u32, width: f32) {
    let mut pen: *mut GpPen = std::ptr::null_mut();
    let _ = GdipCreatePen1(color, width, UnitPixel, &mut pen);
    let _ = GdipDrawLineI(g, pen, x1, y1, x2, y2);
    let _ = GdipDeletePen(pen);
}

/// Draws `text` centered (or left-aligned) inside `rect`, vertically centered.
unsafe fn draw_text(
    g: *mut GpGraphics,
    text: &str,
    rect: RECT,
    size: f32,
    bold: bool,
    color: u32,
    centered: bool,
) {
    let family_name = wide("Segoe UI");
    let mut family: *mut GpFontFamily = std::ptr::null_mut();
    let status = GdipCreateFontFamilyFromName(PCWSTR(family_name.as_ptr()), std::ptr::null_mut(), &mut family);
    if status.0 != 0 || family.is_null() {
        return;
    }

    let style = if bold { FontStyleBold.0 } else { FontStyleRegular.0 };
    let mut font: *mut GpFont = std::ptr::null_mut();
    let _ = GdipCreateFont(family, size, style, UnitPixel, &mut font);

    let mut format: *mut GpStringFormat = std::ptr::null_mut();
    let _ = GdipCreateStringFormat(0, 0, &mut format);
    let align = if centered { StringAlignmentCenter } else { StringAlignmentNear };
    let _ = GdipSetStringFormatAlign(format, align);
    let _ = GdipSetStringFormatLineAlign(format, StringAlignmentCenter);

    let mut brush: *mut GpSolidFill = std::ptr::null_mut();
    let _ = GdipCreateSolidFill(color, &mut brush);

    let layout = RectF {
        X: rect.left as f32,
        Y: rect.top as f32,
        Width: (rect.right - rect.left) as f32,
        Height: (rect.bottom - rect.top) as f32,
    };

    let wtext = wide(text);
    let _ = GdipDrawString(
        g,
        PCWSTR(wtext.as_ptr()),
        -1,
        font,
        &layout,
        format,
        brush as *mut GpBrush,
    );

    let _ = GdipDeleteBrush(brush as *mut GpBrush);
    let _ = GdipDeleteStringFormat(format);
    let _ = GdipDeleteFont(font);
    let _ = GdipDeleteFontFamily(family);
}

/// Soft, faux-blurred drop shadow: several translucent rounded rects, growing
/// and fading outward, instead of a single hard-edged offset silhouette.
unsafe fn draw_soft_shadow(g: *mut GpGraphics, rect: RECT, radius: i32) {
    let layers = 8;
    for i in (1..=layers).rev() {
        let grow = i * 2;
        let alpha = (3 + (layers - i) * 2) as u8;
        fill_round_rect(
            g,
            rect.left - grow,
            rect.top - grow + 6,
            (rect.right - rect.left) + grow * 2,
            (rect.bottom - rect.top) + grow * 2,
            radius + grow,
            argb(alpha, 0, 0, 0),
        );
    }
}

// ─── Paint ────────────────────────────────────────────────────────────────────

unsafe fn on_paint(hwnd: HWND) {
    let ws_ptr = GetWindowLongPtrA(hwnd, GWLP_USERDATA) as *mut WindowState;
    if ws_ptr.is_null() {
        let mut ps = PAINTSTRUCT::default();
        let _ = BeginPaint(hwnd, &mut ps);
        EndPaint(hwnd, &ps);
        return;
    }
    let ws = &mut *ws_ptr;

    let mut client = RECT::default();
    GetClientRect(hwnd, &mut client);
    let cw = client.right;
    let ch = client.bottom;

    let mut ps = PAINTSTRUCT::default();
    let hdc = BeginPaint(hwnd, &mut ps);

    // Use a back-buffer to avoid flicker.
    let mem_dc: HDC = CreateCompatibleDC(Some(hdc));
    let bmp: HBITMAP = CreateCompatibleBitmap(hdc, cw, ch);
    let old_bmp = SelectObject(mem_dc, bmp.into());

    let mut g: *mut GpGraphics = std::ptr::null_mut();
    let _ = GdipCreateFromHDC(mem_dc, &mut g);
    let _ = GdipSetSmoothingMode(g, SmoothingModeAntiAlias);
    // AntiAliasGridFit (grayscale AA) rather than ClearType — this bitmap gets
    // uniformly alpha-blended against whatever's behind the window afterwards,
    // and subpixel ClearType fringing looks wrong once that blend happens.
    let _ = GdipSetTextRenderingHint(g, TextRenderingHintAntiAliasGridFit);

    // The window's client rect (cw/ch) is in real device pixels for whatever
    // monitor it's on. Everything below is laid out in fixed "96 DPI" design
    // pixels (CARD_W, font sizes, etc.), so scale the GDI+ world transform up
    // to the monitor's actual DPI — otherwise on a >100% scaled display the
    // whole card (including text) renders at 96-DPI size, i.e. visibly small.
    let dpi = GetDpiForWindow(hwnd).max(1);
    let scale = dpi as f32 / 96.0;
    let _ = GdipScaleWorldTransform(g, scale, scale, MatrixOrderPrepend);
    let dw = (cw as f32 / scale).round() as i32;
    let dh = (ch as f32 / scale).round() as i32;

    // ── Scolect brand palette (mirrors lib/app_design.dart) ───────────────────
    let (bg_card, text_primary, text_secondary, border_color, surface_secondary) = if ws.dark {
        (
            argb(255, 20, 29, 45),   // darkSurface
            argb(255, 224, 229, 235), // darkTextPrimary
            argb(255, 122, 139, 155), // darkTextSecondary
            argb(255, 31, 42, 59),    // darkBorder
            argb(255, 18, 24, 34),    // darkSurfaceSecondary
        )
    } else {
        (
            argb(255, 255, 255, 255), // lightSurface
            argb(255, 15, 23, 42),    // lightTextPrimary
            argb(255, 71, 85, 105),   // lightTextSecondary
            argb(255, 203, 213, 225), // lightBorder
            argb(255, 230, 237, 247), // lightSurfaceSecondary
        )
    };
    let color_error = argb(255, 239, 68, 68); // errorColor
    let color_error_tint = argb(38, 239, 68, 68); // errorColor @ ~15%
    let color_accent = argb(255, 99, 102, 241); // primaryAccent (indigo)
    let color_warning = argb(255, 245, 158, 11); // warningColor
    let color_white = argb(255, 255, 255, 255);

    // ── Scrim background ───────────────────────────────────────────────────────
    fill_round_rect(g, 0, 0, dw, dh, 0, argb(255, 8, 10, 16));

    // ── Card ────────────────────────────────────────────────────────────────────
    let cx = (dw - CARD_W) / 2;
    let cy = (dh - CARD_H) / 2;
    let card_rect = RECT {
        left: cx,
        top: cy,
        right: cx + CARD_W,
        bottom: cy + CARD_H,
    };

    let card_radius = 32;
    draw_soft_shadow(g, card_rect, card_radius);
    fill_round_rect(g, card_rect.left, card_rect.top, CARD_W, CARD_H, card_radius, bg_card);
    stroke_round_rect(g, card_rect.left, card_rect.top, CARD_W, CARD_H, card_radius, border_color, 1.0);

    // ── Icon badge (tinted circle + "!" glyph, centered at the top) ───────────
    let icon_d = 60;
    let icon_x = card_rect.left + (CARD_W - icon_d) / 2;
    let icon_y = card_rect.top + 26;
    fill_ellipse(g, icon_x, icon_y, icon_d, color_error_tint);
    draw_text(
        g,
        "!",
        RECT { left: icon_x, top: icon_y - 2, right: icon_x + icon_d, bottom: icon_y + icon_d - 2 },
        28.0,
        true,
        color_error,
        true,
    );

    // ── Title + subtitle ───────────────────────────────────────────────────────
    let title_rect = RECT {
        left: card_rect.left + 20,
        top: icon_y + icon_d + 14,
        right: card_rect.right - 20,
        bottom: icon_y + icon_d + 42,
    };
    draw_text(g, "Time limit reached", title_rect, 17.0, true, text_primary, true);

    let sub_rect = RECT {
        left: card_rect.left + 20,
        top: title_rect.bottom,
        right: card_rect.right - 20,
        bottom: title_rect.bottom + 22,
    };
    draw_text(g, &ws.args.app_name, sub_rect, 12.5, false, text_secondary, true);

    // ── Stat pills ──────────────────────────────────────────────────────────────
    let stat_top = sub_rect.bottom + 18;
    let stat_h = 46;
    let box_margin = 16;
    let box_gap = 10;
    let half_w = (CARD_W - box_margin * 2 - box_gap) / 2;

    let used_box = RECT {
        left: card_rect.left + box_margin,
        top: stat_top,
        right: card_rect.left + box_margin + half_w,
        bottom: stat_top + stat_h,
    };
    let limit_box = RECT {
        left: used_box.right + box_gap,
        top: stat_top,
        right: used_box.right + box_gap + half_w,
        bottom: stat_top + stat_h,
    };

    for (pill, label, value, value_color) in [
        (used_box, "USED TODAY", format_duration(ws.args.used_seconds), color_error),
        (limit_box, "DAILY LIMIT", format_duration(ws.args.limit_seconds), text_primary),
    ] {
        fill_round_rect(g, pill.left, pill.top, pill.right - pill.left, pill.bottom - pill.top, 10, surface_secondary);
        draw_text(
            g,
            label,
            RECT { left: pill.left, top: pill.top + 6, right: pill.right, bottom: pill.top + 20 },
            9.5,
            true,
            text_secondary,
            true,
        );
        draw_text(
            g,
            &value,
            RECT { left: pill.left, top: pill.top + 20, right: pill.right, bottom: pill.bottom - 4 },
            13.0,
            true,
            value_color,
            true,
        );
    }

    // ── Separator ───────────────────────────────────────────────────────────────
    let sep_y = used_box.bottom + 18;
    draw_line(g, card_rect.left + 20, sep_y, card_rect.right - 20, sep_y, border_color, 1.0);

    // ── Grace badge (visible only when grace_active) ──────────────────────────
    let mut content_top = sep_y + 16;
    if ws.grace_active {
        let badge_rect = RECT {
            left: card_rect.left + 20,
            top: sep_y + 10,
            right: card_rect.right - 20,
            bottom: sep_y + 42,
        };
        fill_round_rect(g, badge_rect.left, badge_rect.top, badge_rect.right - badge_rect.left, badge_rect.bottom - badge_rect.top, 10, color_warning);
        let mins = ws.grace_seconds_left / 60;
        let secs = ws.grace_seconds_left % 60;
        let badge_txt = format!("Grace period: {:02}:{:02} remaining", mins, secs);
        draw_text(g, &badge_txt, badge_rect, 11.0, true, color_white, true);
        content_top = badge_rect.bottom + 14;
    }

    // ── Buttons ───────────────────────────────────────────────────────────────
    // Layout (top to bottom):
    //   Row 1: [Minimize]  [Quit]     — primary (brand accent), half width each
    //   Row 2: [+5 min grace...]       — secondary, full width
    //   Row 3: [Unblock for today]     — tertiary, full width
    let btn_h = 40;
    let btn_gap = 8;
    let btn_margin = 20;
    let btn_full_w = CARD_W - btn_margin * 2;
    let btn_half_w = (btn_full_w - btn_gap) / 2;

    let r1_top = content_top;
    let minimize_rect = RECT {
        left: card_rect.left + btn_margin,
        top: r1_top,
        right: card_rect.left + btn_margin + btn_half_w,
        bottom: r1_top + btn_h,
    };
    let quit_rect = RECT {
        left: minimize_rect.right + btn_gap,
        top: r1_top,
        right: minimize_rect.right + btn_gap + btn_half_w,
        bottom: r1_top + btn_h,
    };

    let r2_top = r1_top + btn_h + btn_gap;
    let grace_rect = RECT {
        left: card_rect.left + btn_margin,
        top: r2_top,
        right: card_rect.left + btn_margin + btn_full_w,
        bottom: r2_top + btn_h,
    };

    let r3_top = r2_top + btn_h + btn_gap;
    let unblock_rect = RECT {
        left: card_rect.left + btn_margin,
        top: r3_top,
        right: card_rect.left + btn_margin + btn_full_w,
        bottom: r3_top + btn_h,
    };

    // Store rects for click-testing (client coords).
    ws.btn_minimize = minimize_rect;
    ws.btn_quit = quit_rect;
    ws.btn_grace = grace_rect;
    ws.btn_unblock = unblock_rect;

    // Primary buttons: solid brand-accent fill, no border.
    draw_button(g, minimize_rect, "Minimize", color_accent, color_white, None, 11.5, true);
    draw_button(g, quit_rect, "Quit", color_accent, color_white, None, 11.5, true);

    // Secondary buttons: tinted surface with a hairline border.
    let grace_grayed = ws.grace_used;
    let grace_bg = if grace_grayed { border_color } else { surface_secondary };
    let grace_txt = if grace_grayed { text_secondary } else { text_primary };
    draw_button(g, grace_rect, "+5 min grace — save and close", grace_bg, grace_txt, Some(border_color), 11.0, false);
    draw_button(g, unblock_rect, "Unblock for today", surface_secondary, text_secondary, Some(border_color), 11.0, false);

    // ── Footer ────────────────────────────────────────────────────────────────
    let footer_rect = RECT {
        left: card_rect.left,
        top: card_rect.bottom - 30,
        right: card_rect.right,
        bottom: card_rect.bottom - 12,
    };
    draw_text(g, "Scolect", footer_rect, 9.0, false, text_secondary, true);

    let _ = GdipDeleteGraphics(g);

    // ── Blit back-buffer to screen ────────────────────────────────────────────
    let _ = BitBlt(hdc, 0, 0, cw, ch, Some(mem_dc), 0, 0, SRCCOPY);

    SelectObject(mem_dc, old_bmp);
    let _ = DeleteObject(bmp.into());
    let _ = DeleteDC(mem_dc);

    let _ = EndPaint(hwnd, &ps);
}

unsafe fn draw_button(
    g: *mut GpGraphics,
    rect: RECT,
    label: &str,
    bg: u32,
    fg: u32,
    border: Option<u32>,
    font_size: f32,
    bold: bool,
) {
    fill_round_rect(g, rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top, 10, bg);
    if let Some(border_color) = border {
        stroke_round_rect(g, rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top, 10, border_color, 1.0);
    }
    draw_text(g, label, rect, font_size, bold, fg, true);
}

fn format_duration(seconds: i32) -> String {
    let h = seconds / 3600;
    let m = (seconds % 3600) / 60;
    let s = seconds % 60;
    if h > 0 {
        format!("{:02}h {:02}m", h, m)
    } else {
        format!("{:02}m {:02}s", m, s)
    }
}

// ─── Click handling ───────────────────────────────────────────────────────────

unsafe fn on_click(hwnd: HWND, lparam: LPARAM) {
    let ws_ptr = GetWindowLongPtrA(hwnd, GWLP_USERDATA) as *mut WindowState;
    if ws_ptr.is_null() {
        return;
    }
    let ws = &mut *ws_ptr;

    // WM_LBUTTONDOWN's lparam is in real screen/client pixels, but on_paint
    // lays out (and stores) button rects in fixed 96-DPI design pixels scaled
    // up only for drawing via the GDI+ world transform. Undo that scale here
    // so hit-testing lines up with what's on screen on displays that aren't
    // running at 100% Windows scaling.
    let x = (lparam.0 & 0xFFFF) as i16 as i32;
    let y = ((lparam.0 >> 16) & 0xFFFF) as i16 as i32;
    let dpi = GetDpiForWindow(hwnd).max(1);
    let scale = dpi as f32 / 96.0;
    let pt = POINT {
        x: (x as f32 / scale).round() as i32,
        y: (y as f32 / scale).round() as i32,
    };

    eprintln!(
        "🚫[rust] on_click raw=({x},{y}) scale={scale} pt=({},{}) btn_minimize={:?} btn_quit={:?} btn_grace={:?} btn_unblock={:?}",
        pt.x, pt.y, ws.btn_minimize, ws.btn_quit, ws.btn_grace, ws.btn_unblock
    );

    if point_in_rect(pt, ws.btn_minimize) {
        eprintln!("🚫[rust] on_click matched MINIMIZE");
        fire_callback("minimize");
        destroy_overlay_window();
    } else if point_in_rect(pt, ws.btn_quit) {
        eprintln!("🚫[rust] on_click matched QUIT");
        fire_callback("quit");
        destroy_overlay_window();
    } else if point_in_rect(pt, ws.btn_grace) && !ws.grace_used {
        eprintln!("🚫[rust] on_click matched GRACE");
        ws.grace_used = true;
        fire_callback("grace");
        // Grace means "let the user actually use the app for 5 minutes to
        // save/close" — so it must get out of the way like Minimize/Quit do,
        // not stay open with a countdown badge on top of the app (which
        // previously left the app fully blocked for the entire grace period,
        // defeating the point of granting it). Restore visibility for hard
        // block (its windows were SW_HIDE'd by TIMER_HIDE_APP) before tearing
        // the overlay down.
        show_hide_process_windows(ws.args.pid, true);
        destroy_overlay_window();
    } else if point_in_rect(pt, ws.btn_unblock) {
        eprintln!("🚫[rust] on_click matched UNBLOCK");
        fire_callback("unblock");
        // Same as grace: restore hard-block-hidden windows since the app is
        // no longer blocked for the rest of the day.
        show_hide_process_windows(ws.args.pid, true);
        destroy_overlay_window();
    } else {
        eprintln!("🚫[rust] on_click matched NOTHING (click missed all buttons)");
    }
}

fn point_in_rect(pt: POINT, r: RECT) -> bool {
    pt.x >= r.left && pt.x < r.right && pt.y >= r.top && pt.y < r.bottom
}

// ─── Timer handling ───────────────────────────────────────────────────────────

unsafe fn on_timer(hwnd: HWND, timer_id: usize) {
    match timer_id {
        TIMER_REPOSITION => {
            let ws_ptr = GetWindowLongPtrA(hwnd, GWLP_USERDATA) as *mut WindowState;
            if ws_ptr.is_null() {
                return;
            }
            let ws = &*ws_ptr;

            if ws.args.hard_block {
                // Hard block: if a non-overlay, non-Scolect app comes to the
                // foreground, dismiss the overlay.
                let fg = GetForegroundWindow();
                if fg == hwnd || fg.0.is_null() {
                    return;
                }
                let mut fg_pid: u32 = 0;
                GetWindowThreadProcessId(fg, Some(&mut fg_pid));
                let our_pid = windows::Win32::System::Threading::GetCurrentProcessId();
                if fg_pid == our_pid {
                    return; // Scolect itself — fine.
                }
                // Any other real app came to the front — dismiss.
                fire_callback("dismiss");
                destroy_overlay_window();
            } else {
                // Soft block: track blocked app window position and visibility.
                if ws.blocked_hwnd.0.is_null() {
                    return;
                }

                let fg = GetForegroundWindow();
                let mut fg_pid: u32 = 0;
                GetWindowThreadProcessId(fg, Some(&mut fg_pid));

                if fg_pid == ws.args.pid {
                    // Blocked app is in foreground — re-show and track position.
                    let mut r = RECT::default();
                    let _ = GetWindowRect(ws.blocked_hwnd, &mut r);
                    let _ = SetWindowPos(
                        hwnd,
                        Some(HWND_TOPMOST),
                        r.left,
                        r.top,
                        r.right - r.left,
                        r.bottom - r.top,
                        SWP_NOACTIVATE,
                    );
                    ShowWindow(hwnd, SW_SHOWNOACTIVATE);
                } else if fg != hwnd {
                    // Another app is foreground and it's not our overlay — hide scrim.
                    ShowWindow(hwnd, SW_HIDE);
                }
            }
        }
        TIMER_GRACE => {
            let ws_ptr = GetWindowLongPtrA(hwnd, GWLP_USERDATA) as *mut WindowState;
            if ws_ptr.is_null() {
                return;
            }
            let ws = &mut *ws_ptr;
            if !ws.grace_active {
                return;
            }
            ws.grace_seconds_left -= 1;
            if ws.grace_seconds_left <= 0 {
                ws.grace_active = false;
                ws.grace_seconds_left = 0;
                windows::Win32::UI::WindowsAndMessaging::KillTimer(Some(hwnd), TIMER_GRACE);
                // Grace expired — dismiss the overlay.
                fire_callback("dismiss");
                destroy_overlay_window();
            } else {
                let _ = windows::Win32::Graphics::Gdi::InvalidateRect(Some(hwnd), None, false);
            }
        }
        TIMER_HIDE_APP => {
            // Hard block: hide all of the blocked app's windows.
            windows::Win32::UI::WindowsAndMessaging::KillTimer(Some(hwnd), TIMER_HIDE_APP);
            let ws_ptr = GetWindowLongPtrA(hwnd, GWLP_USERDATA) as *mut WindowState;
            if ws_ptr.is_null() {
                return;
            }
            let ws = &*ws_ptr;
            show_hide_process_windows(ws.args.pid, false);
            // Start polling for foreground changes (100ms) to detect when another
            // app sneaks through, at which point we dismiss the hard block.
            let _ = SetTimer(Some(hwnd), TIMER_REPOSITION, 100, None);
        }
        _ => {}
    }
}

// ─── Process window helpers ───────────────────────────────────────────────────

struct ShowHideCtx {
    pid: u32,
    show: bool,
}

unsafe extern "system" fn enum_windows_show_hide(hwnd: HWND, lparam: LPARAM) -> windows::core::BOOL {
    let ctx = &*(lparam.0 as *const ShowHideCtx);
    let mut win_pid: u32 = 0;
    GetWindowThreadProcessId(hwnd, Some(&mut win_pid));
    if win_pid == ctx.pid {
        if ctx.show {
            ShowWindow(hwnd, SW_SHOWNOACTIVATE);
        } else {
            ShowWindow(hwnd, SW_HIDE);
        }
    }
    true.into()
}

fn show_hide_process_windows(pid: u32, show: bool) {
    let ctx = ShowHideCtx { pid, show };
    unsafe {
        let _ = EnumWindows(
            Some(enum_windows_show_hide),
            LPARAM(&ctx as *const _ as isize),
        );
    }
}
