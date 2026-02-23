# scripts/build-qt.ps1
# Fixed version: English comments, UTF-8 compatible, correct package names

# Ensure UTF-8 output encoding to avoid garbled Chinese characters
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

param(
    [string]$QtVersion = "5.15.2",
    [string]$InstallDir = "C:\Qt\Static"
)

$ErrorActionPreference = "Stop"

# ============================================================
# 1. Install prerequisites (Perl is required for Qt5 build)
# ============================================================
Write-Host "=== Checking prerequisites ==="

# Install Strawberry Perl if Qt5 (required for qmake/moc)
if ($QtVersion -like "5.*") {
    Write-Host "=== Installing Strawberry Perl (required for Qt5) ==="
    # Fix: use 'strawberryperl' not 'perl', and remove trailing spaces in URL
    choco install strawberryperl -y --source="https://community.chocolatey.org/api/v2/"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install Strawberry Perl"
        exit 1
    }
    refreshenv  # Refresh PATH so perl is available immediately
}

# Install Ninja build tool
if (-not (Get-Command ninja -ErrorAction SilentlyContinue)) {
    Write-Host "=== Installing Ninja ==="
    choco install ninja -y
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install Ninja"
        exit 1
    }
    refreshenv
}

# Install Git if not present
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "=== Installing Git ==="
    choco install git -y
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install Git"
        exit 1
    }
    refreshenv
}

# ============================================================
# 2. Download Qt source code
# ============================================================
Write-Host "=== Downloading Qt source (Version: $QtVersion) ==="
$SourceDir = "C:\qt-src"
if (Test-Path $SourceDir) { 
    Remove-Item -Recurse -Force $SourceDir 
}

# Determine branch/tag name
$Branch = "v$QtVersion"
# Fix: removed trailing spaces in URL (was "https://...git  ")
$RepoUrl = "https://github.com/qt/qtbase.git"

# Try cloning with v-prefixed tag first, then without prefix (Qt5 compatibility)
git clone --depth 1 --branch $Branch $RepoUrl $SourceDir
if ($LASTEXITCODE -ne 0) { 
    Write-Host "Trying without 'v' prefix..."
    git clone --depth 1 --branch $QtVersion $RepoUrl $SourceDir
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to clone Qt repository. Check version tag: $QtVersion"
        exit 1
    }
}

# ============================================================
# 3. Configure Qt build options
# ============================================================
Write-Host "=== Configuring Qt (Static, Release, Minimal) ==="
Set-Location $SourceDir

# Core configuration arguments
$ConfigureArgs = @(
    "-static",
    "-release", 
    "-opensource",
    "-confirm-license",
    "-nomake", "examples",
    "-nomake", "tests",
    "-no-openssl",      # Skip OpenSSL dependency
    "-sql-sqlite",      # Enable built-in SQLite
    "-prefix", $InstallDir,
    "-install-prefix", $InstallDir
)

# Qt6-specific adjustments
if ($QtVersion -like "6.*") {
    $ConfigureArgs += "-skip", "qtshadertools"
    $ConfigureArgs += "-skip", "qttranslations"
    $ConfigureArgs += "-skip", "qtdeclarative"  # Skip QML if not needed
}

# Execute configure script
Write-Host "Running: configure.bat $ConfigureArgs"
./configure.bat $ConfigureArgs
if ($LASTEXITCODE -ne 0) { 
    Write-Error "Qt configuration failed. Check logs above."
    exit 1 
}

# ============================================================
# 4. Build Qt with Ninja
# ============================================================
Write-Host "=== Starting build (using Ninja) ==="
ninja
if ($LASTEXITCODE -ne 0) { 
    Write-Error "Qt build failed"
    exit 1 
}

# ============================================================
# 5. Install to target directory
# ============================================================
Write-Host "=== Installing to $InstallDir ==="
ninja install
if ($LASTEXITCODE -ne 0) { 
    Write-Error "Qt installation failed"
    exit 1 
}

# ============================================================
# 6. Cleanup source directory to save space
# ============================================================
Set-Location C:\
if (Test-Path $SourceDir) {
    Remove-Item -Recurse -Force $SourceDir
    Write-Host "=== Cleaned up source directory ==="
}

Write-Host "=== Build completed successfully ==="
Write-Host "Qt $QtVersion installed to: $InstallDir"
