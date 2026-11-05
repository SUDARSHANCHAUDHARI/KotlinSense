#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$KOTLIN_LS_VERSION = "1.3.13"
# SHA-256 of the 1.3.13 server.zip release asset
$SERVER_ZIP_SHA256 = "4fe7d71d087b307c7869036171bd9d8c6a4284cd7c25b89098b0a24eb2d9b6d2"
$LS_HOME = "$env:USERPROFILE\.kotlin-language-server"
$DOWNLOAD_URL = "https://github.com/fwcd/kotlin-language-server/releases/download/$KOTLIN_LS_VERSION/server.zip"

Write-Host "Installing Kotlin Language Server v$KOTLIN_LS_VERSION..."

# Check Java
try {
    $javaOutput = (java -version 2>&1 | Where-Object { $_ -match 'version "' } | Select-Object -First 1)
    Write-Host "Found Java: $javaOutput"
} catch {
    Write-Error "Java is required but not found. Install Java 17+ from https://adoptium.net/"
    exit 1
}

# Java 17+ gate: the version is the first quoted token (e.g. "25.0.3"; legacy "1.8.0_292" gives 1)
$javaMajor = 0
if ("$javaOutput" -match 'version "(\d+)') { $javaMajor = [int]$Matches[1] }
if ($javaMajor -lt 17) {
    Write-Error "Java 17+ is required. Detected: $javaOutput"
    exit 1
}

# Check if already installed
$existing = Get-Command "kotlin-language-server" -ErrorAction SilentlyContinue
if ($existing -and $args -notcontains "--force") {
    Write-Host "kotlin-language-server is already installed at: $($existing.Source)"
    Write-Host "Run with -Force to reinstall."
    exit 0
}

$TEMP_DIR = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Force -Path $TEMP_DIR | Out-Null

try {
    Write-Host "Downloading kotlin-language-server..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile "$TEMP_DIR\server.zip" -UseBasicParsing

    $actualSha256 = (Get-FileHash -Algorithm SHA256 -Path "$TEMP_DIR\server.zip").Hash
    if ($actualSha256 -ne $SERVER_ZIP_SHA256) {
        throw "Checksum mismatch for server.zip (v$KOTLIN_LS_VERSION). Expected $SERVER_ZIP_SHA256, got $actualSha256. Nothing was installed. Check your network or proxy, then retry."
    }

    Write-Host "Extracting..."
    Expand-Archive -Path "$TEMP_DIR\server.zip" -DestinationPath "$TEMP_DIR\extracted" -Force

    # The zip extracts to server/. Stage it beside LS_HOME, then swap it in;
    # restore the previous install if the swap fails.
    $STAGE_DIR = "$LS_HOME.new"
    $BAK_DIR = "$LS_HOME.bak"
    if (Test-Path $STAGE_DIR) { Remove-Item -Recurse -Force $STAGE_DIR }
    Copy-Item -Path "$TEMP_DIR\extracted\server" -Destination $STAGE_DIR -Recurse -Force

    # A .bak with no live install means an earlier run stopped mid-swap: restore it before going on.
    if ((Test-Path $BAK_DIR) -and -not (Test-Path $LS_HOME)) { Move-Item -Path $BAK_DIR -Destination $LS_HOME }
    if (Test-Path $BAK_DIR) { Remove-Item -Recurse -Force $BAK_DIR } # stale copy; the live install is kept
    $hadOld = Test-Path $LS_HOME
    if ($hadOld) { Move-Item -Path $LS_HOME -Destination $BAK_DIR }
    try {
        Move-Item -Path $STAGE_DIR -Destination $LS_HOME
    } catch {
        if ($hadOld) { Move-Item -Path $BAK_DIR -Destination $LS_HOME }
        throw
    }
    if ($hadOld) { Remove-Item -Recurse -Force $BAK_DIR }

    # The real binary is server/bin/kotlin-language-server.bat
    # Add bin/ to user PATH so it's directly invokable
    $binDir = "$LS_HOME\bin"
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentPath -notlike "*$binDir*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$binDir", "User")
        Write-Host "Added $binDir to your user PATH."
        Write-Host "Restart your terminal for the PATH change to take effect."
    }

    Write-Host ""
    Write-Host "Installation complete!"
    Write-Host "Binary: $binDir\kotlin-language-server.bat"
    Write-Host ""
    Write-Host "Restart your terminal, then verify with:"
    Write-Host "  kotlin-language-server --version"

} finally {
    Remove-Item -Recurse -Force $TEMP_DIR -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force "$LS_HOME.new" -ErrorAction SilentlyContinue
}
