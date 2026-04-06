#!/bin/bash
echo "Verifying Kotlin Language Server installation..."
echo ""

PASS=0
FAIL=0

# Check kotlin-language-server binary
if command -v kotlin-language-server &> /dev/null; then
    echo "✓ kotlin-language-server found at: $(which kotlin-language-server)"
    PASS=$((PASS + 1))
else
    echo "✗ kotlin-language-server NOT found in PATH"
    echo "  Run /kotlinsense:install to install it."
    FAIL=$((FAIL + 1))
fi

# Check Java
if command -v java &> /dev/null; then
    JAVA_VER=$(java -version 2>&1 | head -1)
    echo "✓ Java found: $JAVA_VER"
    PASS=$((PASS + 1))
else
    echo "✗ Java NOT found — required by kotlin-language-server"
    echo "  Install Java 17+ from: https://adoptium.net/"
    FAIL=$((FAIL + 1))
fi

# Check ~/.local/bin in PATH
if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
    echo "✓ \$HOME/.local/bin is in PATH"
    PASS=$((PASS + 1))
else
    echo "! \$HOME/.local/bin is NOT in PATH"
    echo "  Add it: echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc && source ~/.zshrc"
fi

echo ""
if [ "$FAIL" -eq 0 ]; then
    echo "KotlinSense installation verified. Plugin is ready."
    exit 0
else
    echo "Verification failed: $FAIL issue(s) found. See above for fixes."
    exit 1
fi
