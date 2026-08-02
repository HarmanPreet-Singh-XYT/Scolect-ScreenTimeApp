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

#![allow(non_snake_case, non_camel_case_types, dead_code)]

use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::sync::{Mutex, OnceLock};
use std::thread;

use windows::core::PCSTR;
use windows::Win32::Foundation::{COLORREF, HWND, LPARAM, LRESULT, POINT, RECT, WPARAM};
use windows::Win32::Graphics::Gdi::{
    BeginPaint, BitBlt, CreateCompatibleBitmap, CreateCompatibleDC, CreateFontA, CreatePen,
    CreateSolidBrush, DeleteDC, DeleteObject, DrawTextA, EndPaint, FillRect,
    GetStockObject, LineTo, MoveToEx, RoundRect, SelectObject, SetBkMode,
    SetTextColor, HBITMAP, HDC, HPEN, PAINTSTRUCT, PS_SOLID, SRCCOPY,
    TRANSPARENT, DT_CENTER, DT_SINGLELINE, DT_VCENTER,
};
use windows::Win32::System::LibraryLoader::GetModuleHandleA;
use windows::Win32::System::Registry::{
    RegOpenKeyExA, RegQueryValueExA, HKEY_CURRENT_USER, KEY_READ, REG_VALUE_TYPE,
};
use windows::Win32::UI::WindowsAndMessaging::{
    CreateWindowExA, DefWindowProcA, DestroyWindow, DispatchMessageA, EnumWindows,
    GetClientRect, GetForegroundWindow, GetMessageA, GetSystemMetrics, GetWindowRect,
    GetWindowThreadProcessId, LoadCursorW, PostThreadMessage,
    RegisterClassExA, SetLayeredWindowAttributes, SetTimer, SetWindowPos, ShowWindow,
    TranslateMessage, CS_HREDRAW, CS_VREDRAW, GWLP_USERDATA,
    HWND_TOPMOST, IDC_ARROW, LWA_ALPHA, MSG, SM_CXSCREEN, SM_CYSCREEN, SWP_NOMOVE,
    SWP_NOSIZE, SWP_NOACTIVATE, WM_APP, WM_DESTROY, WM_LBUTTONDOWN, WM_PAINT,
    WM_TIMER, WNDCLASSEXA, WS_EX_LAYERED, WS_EX_NOACTIVATE, WS_EX_TOPMOST,
    WS_POPUP, SW_HIDE, SW_SHOWNOACTIVATE, SetWindowLongPtrA,
    GetWindowLongPtrA,
};

// ─── Constants ────────────────────────────────────────────────────────────────

const WM_CMD_SHOW: u32 = WM_APP + 2;
const WM_CMD_DISMISS: u32 = WM_APP + 3;
const WM_CMD_GRACE: u32 = WM_APP + 4;

const TIMER_REPOSITION: usize = 1;
const TIMER_GRACE: usize = 2;
const TIMER_HIDE_APP: usize = 3;

const CARD_W: i32 = 400;
const CARD_H: i32 = 390;

// ─── Color helpers ────────────────────────────────────────────────────────────

fn rgb(r: u8, g: u8, b: u8) -> COLORREF {
    COLORREF(r as u32 | ((g as u32) << 8) | ((b as u32) << 16))
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
            0,
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
            let _ = PostThreadMessage(tid, msg, WPARAM(0), LPARAM(0));
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
        hinstance,
        None,
    )
    .unwrap_or_default();

    if hwnd.0.is_null() {
        return;
    }

    // 52% opacity (133/255).
    let _ = SetLayeredWindowAttributes(hwnd, COLORREF(0), 133, LWA_ALPHA);

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
        HWND_TOPMOST,
        0,
        0,
        0,
        0,
        SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE,
    );

    if args.hard_block {
        // Hide blocked app after 300ms.
        let _ = SetTimer(hwnd, TIMER_HIDE_APP, 300, None);
    } else {
        // Reposition scrim over blocked app every 100ms.
        let _ = SetTimer(hwnd, TIMER_REPOSITION, 100, None);
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
    let _ = SetTimer(hwnd, TIMER_GRACE, 1000, None);

    // Force repaint to show grace badge.
    let _ = windows::Win32::Graphics::Gdi::InvalidateRect(hwnd, None, false);
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

unsafe extern "system" fn enum_windows_find_pid(hwnd: HWND, lparam: LPARAM) -> windows::Win32::Foundation::BOOL {
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
    let mem_dc: HDC = CreateCompatibleDC(hdc);
    let bmp: HBITMAP = CreateCompatibleBitmap(hdc, cw, ch);
    let old_bmp = SelectObject(mem_dc, bmp);

    // ── Colors ────────────────────────────────────────────────────────────────
    let (bg_card, text_primary, text_secondary, separator_color, btn_secondary_bg, btn_secondary_txt) =
        if ws.dark {
            (
                rgb(30, 30, 35),
                rgb(240, 240, 240),
                rgb(170, 170, 180),
                rgb(60, 60, 70),
                rgb(50, 50, 58),
                rgb(200, 200, 210),
            )
        } else {
            (
                rgb(255, 255, 255),
                rgb(20, 20, 20),
                rgb(120, 120, 130),
                rgb(220, 220, 228),
                rgb(245, 245, 250),
                rgb(60, 60, 70),
            )
        };

    let color_red = rgb(220, 53, 69);
    let color_orange = rgb(255, 140, 0);
    let color_white = rgb(255, 255, 255);

    // ── Scrim background (semi-transparent dark) ──────────────────────────────
    let scrim_brush = CreateSolidBrush(rgb(0, 0, 0));
    FillRect(mem_dc, &client, scrim_brush);
    DeleteObject(scrim_brush);

    // ── Card rect ─────────────────────────────────────────────────────────────
    let cx = (cw - CARD_W) / 2;
    let cy = (ch - CARD_H) / 2;

    let card_rect = RECT {
        left: cx,
        top: cy,
        right: cx + CARD_W,
        bottom: cy + CARD_H,
    };

    // Card shadow (slightly larger, semi-dark).
    let shadow_rect = RECT {
        left: card_rect.left + 4,
        top: card_rect.top + 6,
        right: card_rect.right + 4,
        bottom: card_rect.bottom + 6,
    };
    let shadow_brush = CreateSolidBrush(rgb(0, 0, 0));
    let old_pen_null = SelectObject(
        mem_dc,
        GetStockObject(windows::Win32::Graphics::Gdi::NULL_PEN),
    );
    SelectObject(mem_dc, shadow_brush);
    RoundRect(
        mem_dc,
        shadow_rect.left,
        shadow_rect.top,
        shadow_rect.right,
        shadow_rect.bottom,
        16,
        16,
    );
    SelectObject(mem_dc, old_pen_null);
    DeleteObject(shadow_brush);

    // Card background.
    let card_brush = CreateSolidBrush(bg_card);
    let null_pen = GetStockObject(windows::Win32::Graphics::Gdi::NULL_PEN);
    let old_pen = SelectObject(mem_dc, null_pen);
    SelectObject(mem_dc, card_brush);
    RoundRect(
        mem_dc,
        card_rect.left,
        card_rect.top,
        card_rect.right,
        card_rect.bottom,
        16,
        16,
    );
    SelectObject(mem_dc, old_pen);
    DeleteObject(card_brush);

    // ── Red header band (88px) ────────────────────────────────────────────────
    let header_rect = RECT {
        left: card_rect.left,
        top: card_rect.top,
        right: card_rect.right,
        bottom: card_rect.top + 88,
    };
    // Clip corners for top of card with a red RoundRect.
    let red_brush = CreateSolidBrush(color_red);
    let null_pen2 = GetStockObject(windows::Win32::Graphics::Gdi::NULL_PEN);
    let op2 = SelectObject(mem_dc, null_pen2);
    SelectObject(mem_dc, red_brush);
    // Draw slightly taller rounded rect so bottom corners of header are square.
    RoundRect(
        mem_dc,
        header_rect.left,
        header_rect.top,
        header_rect.right,
        header_rect.bottom + 16,
        16,
        16,
    );
    SelectObject(mem_dc, op2);
    DeleteObject(red_brush);

    // Icon in header — GDI doesn't render emoji glyphs reliably so use an
    // ASCII stand-in that is universally legible.
    let hg_fallback = b"[ ! ]\0";
    let hg_rect = RECT {
        left: header_rect.left,
        top: header_rect.top,
        right: header_rect.right,
        bottom: header_rect.bottom,
    };
    SetBkMode(mem_dc, TRANSPARENT);
    SetTextColor(mem_dc, color_white);
    let icon_font = make_font(mem_dc, 22, true);
    let old_font_icon = SelectObject(mem_dc, icon_font);
    DrawTextA(
        mem_dc,
        &mut hg_fallback.to_vec(),
        &mut { hg_rect },
        DT_CENTER | DT_SINGLELINE | DT_VCENTER,
    );
    SelectObject(mem_dc, old_font_icon);
    DeleteObject(icon_font);

    // ── "Time limit reached" title ────────────────────────────────────────────
    let title_font = make_font(mem_dc, 15, true);
    let old_tf = SelectObject(mem_dc, title_font);
    SetTextColor(mem_dc, text_primary);
    SetBkMode(mem_dc, TRANSPARENT);
    let title_rect = RECT {
        left: card_rect.left + 16,
        top: card_rect.top + 96,
        right: card_rect.right - 16,
        bottom: card_rect.top + 122,
    };
    let mut title_txt = b"Time limit reached\0".to_vec();
    DrawTextA(
        mem_dc,
        &mut title_txt,
        &mut { title_rect },
        DT_CENTER | DT_SINGLELINE | DT_VCENTER,
    );
    SelectObject(mem_dc, old_tf);
    DeleteObject(title_font);

    // ── App name subtitle ─────────────────────────────────────────────────────
    let sub_font = make_font(mem_dc, 12, false);
    let old_sf = SelectObject(mem_dc, sub_font);
    SetTextColor(mem_dc, text_secondary);
    let sub_rect = RECT {
        left: card_rect.left + 16,
        top: card_rect.top + 124,
        right: card_rect.right - 16,
        bottom: card_rect.top + 146,
    };
    let app_name_cstr = format!("{}\0", ws.args.app_name);
    let mut app_name_bytes = app_name_cstr.into_bytes();
    DrawTextA(
        mem_dc,
        &mut app_name_bytes,
        &mut { sub_rect },
        DT_CENTER | DT_SINGLELINE | DT_VCENTER,
    );
    SelectObject(mem_dc, old_sf);
    DeleteObject(sub_font);

    // ── Stat boxes ────────────────────────────────────────────────────────────
    let stat_y = card_rect.top + 152;
    let stat_h = 42;
    let box_margin = 12;
    let box_gap = 8;
    let half_w = (CARD_W - box_margin * 2 - box_gap) / 2;

    // "Used today" box (left).
    let used_box = RECT {
        left: card_rect.left + box_margin,
        top: stat_y,
        right: card_rect.left + box_margin + half_w,
        bottom: stat_y + stat_h,
    };
    let stat_bg_brush = CreateSolidBrush(btn_secondary_bg);
    let np = GetStockObject(windows::Win32::Graphics::Gdi::NULL_PEN);
    let op3 = SelectObject(mem_dc, np);
    SelectObject(mem_dc, stat_bg_brush);
    RoundRect(mem_dc, used_box.left, used_box.top, used_box.right, used_box.bottom, 8, 8);
    SelectObject(mem_dc, op3);
    DeleteObject(stat_bg_brush);

    let mono_font = make_font(mem_dc, 11, true);
    let old_mf = SelectObject(mem_dc, mono_font);
    SetBkMode(mem_dc, TRANSPARENT);
    SetTextColor(mem_dc, color_red);
    let used_label_rect = RECT {
        left: used_box.left,
        top: used_box.top + 4,
        right: used_box.right,
        bottom: used_box.top + 18,
    };
    let mut used_label = b"Used today\0".to_vec();
    DrawTextA(mem_dc, &mut used_label, &mut { used_label_rect }, DT_CENTER | DT_SINGLELINE | DT_VCENTER);
    let used_val = format_duration(ws.args.used_seconds);
    let used_val_cstr = format!("{}\0", used_val);
    let mut used_val_bytes = used_val_cstr.into_bytes();
    let used_val_rect = RECT {
        left: used_box.left,
        top: used_box.top + 20,
        right: used_box.right,
        bottom: used_box.bottom - 4,
    };
    DrawTextA(mem_dc, &mut used_val_bytes, &mut { used_val_rect }, DT_CENTER | DT_SINGLELINE | DT_VCENTER);
    SelectObject(mem_dc, old_mf);
    DeleteObject(mono_font);

    // "Daily limit" box (right).
    let limit_box = RECT {
        left: used_box.right + box_gap,
        top: stat_y,
        right: used_box.right + box_gap + half_w,
        bottom: stat_y + stat_h,
    };
    let stat_bg_brush2 = CreateSolidBrush(btn_secondary_bg);
    let np2 = GetStockObject(windows::Win32::Graphics::Gdi::NULL_PEN);
    let op4 = SelectObject(mem_dc, np2);
    SelectObject(mem_dc, stat_bg_brush2);
    RoundRect(mem_dc, limit_box.left, limit_box.top, limit_box.right, limit_box.bottom, 8, 8);
    SelectObject(mem_dc, op4);
    DeleteObject(stat_bg_brush2);

    let mono_font2 = make_font(mem_dc, 11, true);
    let old_mf2 = SelectObject(mem_dc, mono_font2);
    SetTextColor(mem_dc, text_secondary);
    let lim_label_rect = RECT {
        left: limit_box.left,
        top: limit_box.top + 4,
        right: limit_box.right,
        bottom: limit_box.top + 18,
    };
    let mut lim_label = b"Daily limit\0".to_vec();
    DrawTextA(mem_dc, &mut lim_label, &mut { lim_label_rect }, DT_CENTER | DT_SINGLELINE | DT_VCENTER);
    let lim_val = format_duration(ws.args.limit_seconds);
    let lim_val_cstr = format!("{}\0", lim_val);
    let mut lim_val_bytes = lim_val_cstr.into_bytes();
    let lim_val_rect = RECT {
        left: limit_box.left,
        top: limit_box.top + 20,
        right: limit_box.right,
        bottom: limit_box.bottom - 4,
    };
    DrawTextA(mem_dc, &mut lim_val_bytes, &mut { lim_val_rect }, DT_CENTER | DT_SINGLELINE | DT_VCENTER);
    SelectObject(mem_dc, old_mf2);
    DeleteObject(mono_font2);

    // ── Separator ─────────────────────────────────────────────────────────────
    let sep_y = stat_y + stat_h + 10;
    let sep_pen: HPEN = CreatePen(PS_SOLID, 1, separator_color);
    let old_sep_pen = SelectObject(mem_dc, sep_pen);
    MoveToEx(mem_dc, card_rect.left + 16, sep_y, None);
    LineTo(mem_dc, card_rect.right - 16, sep_y);
    SelectObject(mem_dc, old_sep_pen);
    DeleteObject(sep_pen);

    // ── Grace badge (visible only when grace_active) ──────────────────────────
    let mut grace_badge_bottom = sep_y + 4;
    if ws.grace_active {
        let badge_rect = RECT {
            left: card_rect.left + 16,
            top: sep_y + 8,
            right: card_rect.right - 16,
            bottom: sep_y + 30,
        };
        let badge_brush = CreateSolidBrush(color_orange);
        let np3 = GetStockObject(windows::Win32::Graphics::Gdi::NULL_PEN);
        let op5 = SelectObject(mem_dc, np3);
        SelectObject(mem_dc, badge_brush);
        RoundRect(mem_dc, badge_rect.left, badge_rect.top, badge_rect.right, badge_rect.bottom, 6, 6);
        SelectObject(mem_dc, op5);
        DeleteObject(badge_brush);

        let grace_font = make_font(mem_dc, 10, true);
        let old_gf = SelectObject(mem_dc, grace_font);
        SetTextColor(mem_dc, color_white);
        SetBkMode(mem_dc, TRANSPARENT);
        let mins = ws.grace_seconds_left / 60;
        let secs = ws.grace_seconds_left % 60;
        let badge_txt = format!("Grace period: {:02}:{:02} remaining\0", mins, secs);
        let mut badge_bytes = badge_txt.into_bytes();
        DrawTextA(mem_dc, &mut badge_bytes, &mut { badge_rect }, DT_CENTER | DT_SINGLELINE | DT_VCENTER);
        SelectObject(mem_dc, old_gf);
        DeleteObject(grace_font);
        grace_badge_bottom = badge_rect.bottom + 4;
    }

    // ── Buttons ───────────────────────────────────────────────────────────────
    // Layout (top to bottom):
    //   Row 1: [Minimize]  [Quit]     — primary (red), half width each
    //   Row 2: [+5 min grace...]       — secondary, full width
    //   Row 3: [Unblock for today]     — secondary, full width

    let btn_top = grace_badge_bottom + 6;
    let btn_h = 34;
    let btn_gap = 6;
    let btn_margin = 16;
    let btn_full_w = CARD_W - btn_margin * 2;
    let btn_half_w = (btn_full_w - btn_gap) / 2;

    // Row 1: Minimize + Quit
    let r1_top = card_rect.top + btn_top;
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

    // Row 2: Grace
    let r2_top = r1_top + btn_h + btn_gap;
    let grace_rect = RECT {
        left: card_rect.left + btn_margin,
        top: r2_top,
        right: card_rect.left + btn_margin + btn_full_w,
        bottom: r2_top + btn_h,
    };

    // Row 3: Unblock
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

    // Draw primary buttons (red).
    draw_button(mem_dc, minimize_rect, b"Minimize\0", color_red, color_white, false);
    draw_button(mem_dc, quit_rect, b"Quit\0", color_red, color_white, false);

    // Draw secondary buttons.
    let grace_grayed = ws.grace_used;
    let grace_bg = if grace_grayed { text_secondary } else { btn_secondary_bg };
    let grace_txt_color = if grace_grayed { rgb(180, 180, 180) } else { btn_secondary_txt };
    draw_button(mem_dc, grace_rect, b"+5 min grace \x97 save and close\0", grace_bg, grace_txt_color, true);
    draw_button(mem_dc, unblock_rect, b"Unblock for today\0", btn_secondary_bg, btn_secondary_txt, true);

    // ── Footer ────────────────────────────────────────────────────────────────
    let footer_font = make_font(mem_dc, 9, false);
    let old_ff = SelectObject(mem_dc, footer_font);
    SetTextColor(mem_dc, text_secondary);
    SetBkMode(mem_dc, TRANSPARENT);
    let footer_rect = RECT {
        left: card_rect.left,
        top: card_rect.bottom - 22,
        right: card_rect.right,
        bottom: card_rect.bottom - 4,
    };
    let mut footer_txt = b"Scolect\0".to_vec();
    DrawTextA(mem_dc, &mut footer_txt, &mut { footer_rect }, DT_CENTER | DT_SINGLELINE | DT_VCENTER);
    SelectObject(mem_dc, old_ff);
    DeleteObject(footer_font);

    // ── Blit back-buffer to screen ────────────────────────────────────────────
    BitBlt(hdc, 0, 0, cw, ch, mem_dc, 0, 0, SRCCOPY);

    SelectObject(mem_dc, old_bmp);
    DeleteObject(bmp);
    DeleteDC(mem_dc);

    EndPaint(hwnd, &ps);
}

unsafe fn draw_button(hdc: HDC, rect: RECT, label: &[u8], bg: COLORREF, fg: COLORREF, secondary: bool) {
    let brush = CreateSolidBrush(bg);
    let border_pen = if secondary {
        CreatePen(PS_SOLID, 1, rgb(180, 180, 190))
    } else {
        CreatePen(PS_SOLID, 0, bg) // no visible border for primary
    };
    let old_pen = SelectObject(hdc, border_pen);
    SelectObject(hdc, brush);
    RoundRect(hdc, rect.left, rect.top, rect.right, rect.bottom, 8, 8);
    SelectObject(hdc, old_pen);
    DeleteObject(brush);
    DeleteObject(border_pen);

    let font = make_font(hdc, 11, !secondary);
    let old_font = SelectObject(hdc, font);
    SetTextColor(hdc, fg);
    SetBkMode(hdc, TRANSPARENT);
    let mut txt = label.to_vec();
    // Ensure null-terminated.
    if txt.last() != Some(&0) {
        txt.push(0);
    }
    DrawTextA(hdc, &mut txt, &mut { rect }, DT_CENTER | DT_SINGLELINE | DT_VCENTER);
    SelectObject(hdc, old_font);
    DeleteObject(font);
}

unsafe fn make_font(hdc: HDC, pt: i32, bold: bool) -> HFONT {
    // Convert point size to logical units.
    let dc_hdc = windows::Win32::Graphics::Gdi::GetDC(None);
    let dpi = windows::Win32::Graphics::Gdi::GetDeviceCaps(
        dc_hdc,
        windows::Win32::Graphics::Gdi::LOGPIXELSY,
    );
    windows::Win32::Graphics::Gdi::ReleaseDC(None, dc_hdc);

    let height = -(pt * dpi) / 72;
    let weight = if bold { 700i32 } else { 400i32 };
    CreateFontA(
        height,
        0,
        0,
        0,
        weight,
        0,
        0,
        0,
        windows::Win32::Graphics::Gdi::DEFAULT_CHARSET,
        windows::Win32::Graphics::Gdi::OUT_DEFAULT_PRECIS,
        windows::Win32::Graphics::Gdi::CLIP_DEFAULT_PRECIS,
        windows::Win32::Graphics::Gdi::CLEARTYPE_QUALITY,
        windows::Win32::Graphics::Gdi::DEFAULT_PITCH,
        PCSTR(b"Segoe UI\0".as_ptr()),
    )
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

    let x = (lparam.0 & 0xFFFF) as i16 as i32;
    let y = ((lparam.0 >> 16) & 0xFFFF) as i16 as i32;
    let pt = POINT { x, y };

    if point_in_rect(pt, ws.btn_minimize) {
        fire_callback("minimize");
        destroy_overlay_window();
    } else if point_in_rect(pt, ws.btn_quit) {
        fire_callback("quit");
        destroy_overlay_window();
    } else if point_in_rect(pt, ws.btn_grace) && !ws.grace_used {
        ws.grace_used = true;
        fire_callback("grace");
        // Don't dismiss — let Dart handle the countdown.
        let _ = windows::Win32::Graphics::Gdi::InvalidateRect(hwnd, None, false);
    } else if point_in_rect(pt, ws.btn_unblock) {
        fire_callback("unblock");
        destroy_overlay_window();
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
                        HWND_TOPMOST,
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
                windows::Win32::UI::WindowsAndMessaging::KillTimer(hwnd, TIMER_GRACE);
                // Grace expired — dismiss the overlay.
                fire_callback("dismiss");
                destroy_overlay_window();
            } else {
                let _ = windows::Win32::Graphics::Gdi::InvalidateRect(hwnd, None, false);
            }
        }
        TIMER_HIDE_APP => {
            // Hard block: hide all of the blocked app's windows.
            windows::Win32::UI::WindowsAndMessaging::KillTimer(hwnd, TIMER_HIDE_APP);
            let ws_ptr = GetWindowLongPtrA(hwnd, GWLP_USERDATA) as *mut WindowState;
            if ws_ptr.is_null() {
                return;
            }
            let ws = &*ws_ptr;
            show_hide_process_windows(ws.args.pid, false);
            // Start polling for foreground changes (100ms) to detect when another
            // app sneaks through, at which point we dismiss the hard block.
            let _ = SetTimer(hwnd, TIMER_REPOSITION, 100, None);
        }
        _ => {}
    }
}

// ─── Process window helpers ───────────────────────────────────────────────────

struct ShowHideCtx {
    pid: u32,
    show: bool,
}

unsafe extern "system" fn enum_windows_show_hide(hwnd: HWND, lparam: LPARAM) -> windows::Win32::Foundation::BOOL {
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
