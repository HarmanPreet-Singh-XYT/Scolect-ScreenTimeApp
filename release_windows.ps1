param (
    [ValidateSet("Release", "Debug")]
    [string]$Configuration = "Release",

    [ValidateSet("arm64", "x64")]
    [string]$Architecture = "",

    [switch]$Msix,
    [switch]$Clean
)

$ErrorActionPreference = "Stop"

# File to track last build information
$stateFile = Join-Path $PSScriptRoot ".dart_tool\last_build_info.json"
$lastArch = $null
$lastDate = $null

if (Test-Path $stateFile) {
    try {
        $state = Get-Content $stateFile -Raw | ConvertFrom-Json
        $lastArch = $state.Architecture
        $lastDate = $state.Date
    } catch {}
}

# Detect host CPU architecture
$hostArch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLower()

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      Scolect Windows Build Script      " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Host System Architecture: " -NoNewline
Write-Host "$hostArch" -ForegroundColor Green

if ($lastArch) {
    Write-Host "Last Build Architecture:  " -NoNewline
    Write-Host "$lastArch" -ForegroundColor Yellow -NoNewline
    if ($lastDate) {
        Write-Host " (Built on: $lastDate)" -ForegroundColor Gray
    } else {
        Write-Host ""
    }
} else {
    Write-Host "Last Build Architecture:  None recorded" -ForegroundColor Gray
}

# Determine target architecture
$selectedArch = $Architecture

if (-not $selectedArch) {
    Write-Host "`nSelect target architecture to build:" -ForegroundColor White
    Write-Host "  [1] arm64 $(if ($hostArch -eq 'arm64') { '(Native)' } else { '' })" -ForegroundColor Cyan
    Write-Host "  [2] x64   $(if ($hostArch -eq 'x64') { '(Native)' } else { '' })" -ForegroundColor Cyan
    
    $defaultChoice = if ($lastArch) { $lastArch } else { $hostArch }
    $choice = Read-Host "`nEnter choice (1=arm64, 2=x64) [Default: $defaultChoice]"
    
    if ($choice -eq "1" -or $choice -eq "arm64") {
        $selectedArch = "arm64"
    } elseif ($choice -eq "2" -or $choice -eq "x64") {
        $selectedArch = "x64"
    } else {
        $selectedArch = $defaultChoice
    }
}

$selectedArch = $selectedArch.ToLower()

# Check if attempting cross-compilation
if ($selectedArch -ne $hostArch) {
    Write-Host "`n[!] Cross-Architecture Notice:" -ForegroundColor Yellow
    Write-Host "    Flutter desktop compiles native binaries matching your machine's CPU ($hostArch)." -ForegroundColor Yellow
    Write-Host "    Cross-compiling $selectedArch binaries directly on a $hostArch machine is not supported by Flutter's build toolchain." -ForegroundColor Yellow
    Write-Host "`n    -> To build the $selectedArch package for Microsoft Store (Intel/AMD):" -ForegroundColor Cyan
    Write-Host "       Run this build on an x64 Windows PC or in GitHub Actions (runs-on: windows-latest)." -ForegroundColor Cyan
    Write-Host "    -> Falling back to native host architecture: $hostArch`n" -ForegroundColor Gray
    $selectedArch = $hostArch
}

Write-Host "`nTarget Architecture: " -NoNewline
Write-Host "$selectedArch" -ForegroundColor Green
Write-Host "Configuration:       " -NoNewline
Write-Host "$Configuration" -ForegroundColor Green
Write-Host "------------------------------------------" -ForegroundColor Gray

# 1. Clean if requested
if ($Clean) {
    Write-Host "`n[1/3] Cleaning build directory..." -ForegroundColor Yellow
    flutter clean
    flutter pub get
}

# 2. Build Windows executable
Write-Host "`n[2/3] Building Windows application ($Configuration)..." -ForegroundColor Yellow
if ($Configuration -eq "Debug") {
    flutter build windows --debug
} else {
    flutter build windows --release
}

if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter build failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

# 3. Create MSIX Package
if ($Msix -or ($Configuration -eq "Release")) {
    Write-Host "`n[3/3] Packaging MSIX installer for $selectedArch..." -ForegroundColor Yellow
    
    dart run msix:create --architecture $selectedArch
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "MSIX packaging failed with exit code $LASTEXITCODE"
        exit $LASTEXITCODE
    }
}

# Save state
try {
    $infoDir = Split-Path $stateFile
    if (-not (Test-Path $infoDir)) { New-Item -ItemType Directory -Path $infoDir -Force | Out-Null }
    @{
        Architecture = $selectedArch
        Date         = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Configuration= $Configuration
    } | ConvertTo-Json | Set-Content $stateFile -Force
} catch {}

Write-Host "`n==========================================" -ForegroundColor Green
Write-Host "  Build completed successfully!" -ForegroundColor Green
Write-Host "  MSIX output: build\windows\$selectedArch\runner\Release\screentime.msix" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green