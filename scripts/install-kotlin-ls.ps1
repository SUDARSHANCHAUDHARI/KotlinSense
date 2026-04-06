#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$KOTLIN_LS_VERSION = "1.3.13"
$LS_HOME = "$env:USERPROFILE\.kotlin-language-server"
$DOWNLOAD_URL = "https://github.com/fwcd/kotlin-language-server/releases/download/$KOTLIN_LS_VERSION/server.zip"

Write-Host "Installing Kotlin Language Server v$KOTLIN_LS_VERSION..."

# Check Java
try {
    $javaOutput = (java -version 2>&1) | Select-Object -First 1
    Write-Host "Found Java: $javaOutput"
} catch {
    Write-Error "Java is required but not found. Install Java 17+ from https://adoptium.net/"
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

    Write-Host "Extracting..."
    Expand-Archive -Path "$TEMP_DIR\server.zip" -DestinationPath "$TEMP_DIR\extracted" -Force

    # The zip extracts to server/ — copy the whole thing to LS_HOME
    if (Test-Path $LS_HOME) { Remove-Item -Recurse -Force $LS_HOME }
    Copy-Item -Path "$TEMP_DIR\extracted\server" -Destination $LS_HOME -Recurse -Force

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
}
