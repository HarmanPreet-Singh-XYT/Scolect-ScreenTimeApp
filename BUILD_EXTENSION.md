# Browser Extension Source Code Build Guide (Mozilla Firefox AMO)

This add-on is built from Dart/Flutter source code using the Flutter Web compiler and standard shell scripts.

---

## 1. Operating System Used for Build
- **Supported OS**: macOS (macOS 14+ / 15+), Linux (Ubuntu 20.04+), or Windows 10/11 (via Git Bash / WSL / PowerShell).

---

## 2. Specific Versions of Tools Needed
- **Flutter SDK**: `3.27.0` or higher (includes Dart `3.6.0`+)
- **Node.js**: `v18.0.0` or higher (used for `npx web-ext`)
- **Bash / Unix Shell**: Standard bash/zsh shell with `sed`, `zip`, `find`

---

## 3. Links to Tools to Download
- **Flutter SDK**: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
- **Node.js**: [https://nodejs.org/en/download/](https://nodejs.org/en/download/)
- **Git**: [https://git-scm.com/downloads](https://git-scm.com/downloads)

---

## 4. Guidance for Installing Tools & Online Instructions
- **Flutter Installation Guide**: Follow instructions at [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install). Add `flutter/bin` to your system `PATH` and verify using `flutter doctor`.
- **Node.js Installation**: Follow instructions at [https://nodejs.org/en/learn/getting-started/how-to-install-nodejs](https://nodejs.org/en/learn/getting-started/how-to-install-nodejs). Verify using `node -v` and `npm -v`.

---

## 5. Instructions for Building Add-On Code & Build Scripts
The project root contains an automated build script: `build_extension.sh`.

### Step-by-Step Build Command:
```bash
# 1. Install dependencies
flutter pub get

# 2. Make build script executable and run it
chmod +x build_extension.sh
./build_extension.sh
```

### What `build_extension.sh` Executables Perform:
1. Runs `flutter build web --csp` (Content Security Policy compliance mode required for MV3).
2. Patches `index.html` base href (`<base href="./">`).
3. Configures local CanvasKit asset paths for offline MV3 engine execution.
4. Strips `.DS_Store` OS metadata files.
5. Produces `build/web` (unpacked extension directory with root `manifest.json`) and packages `build/scolect-extension.zip`.
