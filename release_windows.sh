#!/usr/bin/env bash
# Delegate to the canonical PowerShell Windows release script
set -e

if command -v powershell.exe &> /dev/null; then
    powershell.exe -ExecutionPolicy Bypass -File "./release_windows.ps1" "$@"
elif command -v pwsh &> /dev/null; then
    pwsh -ExecutionPolicy Bypass -File "./release_windows.ps1" "$@"
else
    echo "❌ Error: PowerShell (powershell.exe or pwsh) is required to run the Windows release script."
    echo "Please run release_windows.ps1 directly from PowerShell on Windows."
    exit 1
fi

