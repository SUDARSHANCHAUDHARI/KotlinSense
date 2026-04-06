Check the status of the KotlinSense Kotlin Language Server plugin.

## Steps

1. Check for the `kotlin-language-server` binary:
   ```bash
   which kotlin-language-server 2>/dev/null || echo "NOT FOUND"
   ```

2. Check Java:
   ```bash
   java -version 2>&1 | head -1
   ```

3. Run the verify script for a full diagnostic:
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/verify-install.sh"
   ```

4. Report status to the user in this format:

```
KOTLINSENSE STATUS
──────────────────────────────────
Binary:   ✓ kotlin-language-server found at /usr/local/bin/kotlin-language-server
Java:     ✓ Java 17.0.9 found
LSP:      ✓ .lsp.json loaded — watching .kt and .kts files

KotlinSense is ready. Type errors and diagnostics will appear
automatically after each .kt file edit in Claude Code.
```

Or if issues are found:

```
KOTLINSENSE STATUS
──────────────────────────────────
Binary:   ✗ kotlin-language-server NOT found in PATH
Java:     ✓ Java 17.0.9 found
LSP:      ✗ Inactive (binary missing)

Run /kotlinsense:install to install the language server binary.
```

## Known issues and fixes

| Issue | Fix |
|---|---|
| `kotlin-language-server: command not found` | Run `/kotlinsense:install` |
| Java not found | Install Java 17+ from https://adoptium.net/ |
| LSP not activating after install | Restart terminal so PATH changes take effect, then restart Claude Code |
| Slow diagnostics on first open | Normal — the server indexes the project on first run (30–90s) |
| False positives on generated code | Run `./gradlew build` first so annotation processors generate their files |
