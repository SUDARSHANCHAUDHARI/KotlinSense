#!/bin/bash
set -e

KOTLIN_LS_VERSION="1.3.13"
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

JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
if [ -n "$JAVA_VERSION" ] && [ "$JAVA_VERSION" -lt "17" ] 2>/dev/null; then
    echo "WARNING: Java 17+ recommended. Found Java ${JAVA_VERSION}."
fi

# Check if already installed
if command -v kotlin-language-server &> /dev/null && [ "$1" != "--force" ]; then
    echo "kotlin-language-server is already installed at: $(which kotlin-language-server)"
    echo "Run with --force to reinstall."
    exit 0
fi

mkdir -p "$INSTALL_DIR"
TEMP_DIR=$(mktemp -d)
trap "rm -rf '$TEMP_DIR'" EXIT

echo "Downloading kotlin-language-server..."
if command -v curl &> /dev/null; then
    curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_DIR/server.zip"
elif command -v wget &> /dev/null; then
    wget -q "$DOWNLOAD_URL" -O "$TEMP_DIR/server.zip"
else
    echo "ERROR: curl or wget is required."
    exit 1
fi

echo "Extracting..."
unzip -q "$TEMP_DIR/server.zip" -d "$TEMP_DIR/extracted"

# The zip extracts to server/ — copy the whole thing to LS_HOME
rm -rf "$LS_HOME"
mkdir -p "$LS_HOME"
cp -r "$TEMP_DIR/extracted/server/"* "$LS_HOME/"
chmod +x "$LS_HOME/bin/kotlin-language-server"

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
