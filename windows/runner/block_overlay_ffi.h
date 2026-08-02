#pragma once
#include <windows.h>

// Callback type: fired from the Rust Win32 thread when the user clicks a button.
// action is one of: "minimize", "quit", "grace", "unblock", "dismiss".
typedef void (*BlockOverlayCallback)(const char* action);

extern "C" {
  // Show the block overlay for the given process.
  // pid          - target process ID
  // app_name     - null-terminated UTF-8 application name
  // used_seconds - total seconds used today
  // limit_seconds- configured daily limit in seconds
  // hard_block   - true: full-screen TOPMOST overlay that hides the blocked app
  //                false: soft overlay covering only the blocked window
  // callback     - called with action string when the user interacts with the card
  void block_overlay_show(DWORD pid, const char* app_name, int used_seconds,
                          int limit_seconds, bool hard_block,
                          BlockOverlayCallback callback);

  // Dismiss the overlay immediately.
  void block_overlay_dismiss();

  // Show/update the grace countdown badge (call after block_overlay_show).
  // seconds - total grace period duration in seconds (counts down to 0).
  void block_overlay_start_grace(int seconds);
}
