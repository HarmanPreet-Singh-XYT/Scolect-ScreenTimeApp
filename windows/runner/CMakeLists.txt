cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Add dependency libraries and include directories. Add any application-specific
# dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)

# ── block_overlay Rust DLL ────────────────────────────────────────────────────
# Built automatically as part of this CMake build (same pattern as the
# window_focus plugin's windows/CMakeLists.txt) so the DLL's architecture
# always matches the runner's — no manual `cargo build` step to remember, and
# no risk of copying a stale/mismatched-architecture DLL (e.g. an x64 DLL
# next to an ARM64 exe, which fails to load at runtime with
# "block_overlay.dll not loaded" instead of failing loudly at build time).
find_program(CARGO_EXECUTABLE cargo
  HINTS "$ENV{CARGO_HOME}/bin" "$ENV{USERPROFILE}/.cargo/bin"
  REQUIRED
)

if(CMAKE_VS_PLATFORM_NAME STREQUAL "ARM64")
  set(BLOCK_OVERLAY_RUST_TARGET "aarch64-pc-windows-msvc")
else()
  set(BLOCK_OVERLAY_RUST_TARGET "x86_64-pc-windows-msvc")
endif()

set(BLOCK_OVERLAY_CRATE_DIR "${CMAKE_SOURCE_DIR}/block_overlay")
set(BLOCK_OVERLAY_DLL
    "${BLOCK_OVERLAY_CRATE_DIR}/target/${BLOCK_OVERLAY_RUST_TARGET}/release/block_overlay.dll")

add_custom_command(
  OUTPUT "${BLOCK_OVERLAY_DLL}"
  COMMAND "${CARGO_EXECUTABLE}" build --release --target ${BLOCK_OVERLAY_RUST_TARGET}
          --manifest-path "${BLOCK_OVERLAY_CRATE_DIR}/Cargo.toml"
  WORKING_DIRECTORY "${BLOCK_OVERLAY_CRATE_DIR}"
  COMMENT "Building block_overlay.dll (${BLOCK_OVERLAY_RUST_TARGET})"
  VERBATIM
)
add_custom_target(block_overlay_rust_build ALL DEPENDS "${BLOCK_OVERLAY_DLL}")
add_dependencies(${BINARY_NAME} block_overlay_rust_build)

add_custom_command(TARGET ${BINARY_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "${BLOCK_OVERLAY_DLL}"
    "$<TARGET_FILE_DIR:${BINARY_NAME}>/block_overlay.dll"
  COMMENT "Copying block_overlay.dll (${BLOCK_OVERLAY_RUST_TARGET}) to output directory"
)
