#!/bin/bash
set -euo pipefail

KOTLIN_LS_VERSION="1.3.13"
# SHA-256 of the 1.3.13 server.zip release asset
SERVER_ZIP_SHA256="4fe7d71d087b307c7869036171bd9d8c6a4284cd7c25b89098b0a24eb2d9b6d2"
LS_HOME="$HOME/.kotlin-language-server"
INSTALL_DIR="$HOME/.local/bin"
DOWNLOAD_URL="https://github.com/fwcd/kotlin-language-server/releases/download/${KOTLIN_LS_VERSION}/server.zip"

echo "Installing Kotlin Language Server v${KOTLIN_LS_VERSION}..."

# Check Java is available (required by kotlin-language-server)
if ! command -v java &> /dev/null; then
    echo "ERROR: Java is required but not found."
    echo "Install Java 17+ from: https://adoptium.net/"
    exit 1
fi

# java -version writes to stderr; '|| true' lets an unreadable result reach the check below
JAVA_OUTPUT=$(java -version 2>&1 || true)
JAVA_VERSION=$(awk -F '"' '/version/ {print $2; exit}' <<< "$JAVA_OUTPUT")
JAVA_MAJOR=${JAVA_VERSION%%.*}
if ! [[ "$JAVA_MAJOR" =~ ^[0-9]+$ ]] || [ "$JAVA_MAJOR" -lt 17 ]; then
    echo "ERROR: Java 17+ is required. Detected version: ${JAVA_VERSION:-unknown}"
    echo "Install Java 17+ from: https://adoptium.net/"
    exit 1
fi

# Check if already installed
if command -v kotlin-language-server &> /dev/null && [ "${1:-}" != "--force" ]; then
    echo "kotlin-language-server is already installed at: $(which kotlin-language-server)"
    echo "Run with --force to reinstall."
    exit 0
fi

mkdir -p "$INSTALL_DIR"
TEMP_DIR=$(mktemp -d)
STAGE_DIR="$LS_HOME.new"
BAK_DIR="$LS_HOME.bak"
trap 'rm -rf "$TEMP_DIR" "$STAGE_DIR"' EXIT

echo "Downloading kotlin-language-server..."
if command -v curl &> /dev/null; then
    curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_DIR/server.zip"
elif command -v wget &> /dev/null; then
    wget -q "$DOWNLOAD_URL" -O "$TEMP_DIR/server.zip"
else
    echo "ERROR: curl or wget is required."
    exit 1
fi

echo "Verifying checksum..."
if command -v shasum &> /dev/null; then
    ACTUAL_SHA256=$(shasum -a 256 "$TEMP_DIR/server.zip" | awk '{print $1}')
elif command -v sha256sum &> /dev/null; then
    ACTUAL_SHA256=$(sha256sum "$TEMP_DIR/server.zip" | awk '{print $1}')
else
    echo "ERROR: shasum or sha256sum is required to verify the download."
    exit 1
fi
if [ "$ACTUAL_SHA256" != "$SERVER_ZIP_SHA256" ]; then
    echo "ERROR: checksum mismatch for server.zip (v${KOTLIN_LS_VERSION})."
    echo "  Expected: $SERVER_ZIP_SHA256"
    echo "  Actual:   $ACTUAL_SHA256"
    echo "Nothing was installed. Check your network or proxy, then retry."
    exit 1
fi

echo "Extracting..."
unzip -q "$TEMP_DIR/server.zip" -d "$TEMP_DIR/extracted"

# The zip extracts to server/. Stage it beside LS_HOME, then swap it in;
# restore the previous install if the swap fails.
rm -rf "$STAGE_DIR"
cp -r "$TEMP_DIR/extracted/server" "$STAGE_DIR"
chmod +x "$STAGE_DIR/bin/kotlin-language-server"

# A .bak with no live install means an earlier run stopped mid-swap: restore it before going on.
if [ -e "$BAK_DIR" ] && [ ! -e "$LS_HOME" ]; then
    mv "$BAK_DIR" "$LS_HOME"
fi
rm -rf "$BAK_DIR" # stale copy; the live install above is kept
if [ -e "$LS_HOME" ]; then
    mv "$LS_HOME" "$BAK_DIR"
fi
if ! mv "$STAGE_DIR" "$LS_HOME"; then
    echo "ERROR: could not move the new install into $LS_HOME. Restoring the previous install."
    if [ -e "$BAK_DIR" ]; then
        mv "$BAK_DIR" "$LS_HOME"
    fi
    exit 1
fi
rm -rf "$BAK_DIR"

# Symlink the binary into PATH — the script resolves symlinks to find its own lib/
ln -sf "$LS_HOME/bin/kotlin-language-server" "$INSTALL_DIR/kotlin-language-server"

echo ""
echo "Installation complete!"
echo "Binary:  $LS_HOME/bin/kotlin-language-server"
echo "Symlink: $INSTALL_DIR/kotlin-language-server"
echo ""

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "NOTE: $INSTALL_DIR is not in your PATH. Add it:"
    echo "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc && source ~/.zshrc"
    echo ""
fi

echo "Verify: kotlin-language-server --version"
