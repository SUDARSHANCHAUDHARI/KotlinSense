Install the Kotlin Language Server binary required by the KotlinSense plugin.

## Steps

1. Check if `kotlin-language-server` is already installed:
   ```bash
   which kotlin-language-server || echo "NOT FOUND"
   ```

2. Check Java version (required dependency):
   ```bash
   java -version 2>&1 | head -1
   ```

3. If `kotlin-language-server` is not found, detect the OS and run the appropriate script.

   **macOS / Linux:**
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-kotlin-ls.sh"
   ```

   **Windows (PowerShell):**
   ```powershell
   PowerShell -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/install-kotlin-ls.ps1"
   ```

   Ask the user to confirm before running — the script downloads ~50 MB from GitHub.

4. After install, verify:
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/verify-install.sh"
   ```

5. If the PATH was updated, remind the user to restart their terminal before KotlinSense will activate.

## Prerequisites
- Java 17+ installed (`java -version` to check)
- Internet connection (~50 MB download from github.com)
- ~100 MB free disk space

## Manual install alternative
If the script fails, direct the user to download manually:
1. Go to https://github.com/fwcd/kotlin-language-server/releases
2. Download `server.zip` from the latest release
3. Extract it and add the `bin/` folder to PATH
4. Create a wrapper: `java -jar /path/to/kotlin-language-server.jar`
