# KotlinSense — Full Documentation

This document covers everything needed to use KotlinSense effectively. See [README.md](README.md) for a quick overview.

---

## Table of Contents

1. [Installation](#installation)
2. [Commands](#commands)
   - [/kotlinsense:install](#kotlinsenseinstall)
   - [/kotlinsense:status](#kotlinsensestatus)
   - [/kotlinsense:navigate](#kotlinsensenavigate)
3. [How Diagnostics Work](#how-diagnostics-work)
4. [Diagnostics Reference](#diagnostics-reference)
5. [Kotlin Android Patterns](#kotlin-android-patterns)
6. [First-Time Project Setup](#first-time-project-setup)
7. [Plugin Architecture](#plugin-architecture)
8. [Troubleshooting](#troubleshooting)

---

## Installation

### Step 1 — Install the plugin

```bash
/plugin install kotlinsense
```

### Step 2 — Install the language server binary

```bash
/kotlinsense:install
```

This downloads `kotlin-language-server` from GitHub Releases and installs it to `~/.kotlin-language-server/`. The binary is symlinked into `~/.local/bin/` so it is available in your PATH.

**Requirements:**
- Java 17+ (`java -version` to check — install from [adoptium.net](https://adoptium.net/) if missing)
- Internet connection for the initial ~50 MB download
- ~100 MB free disk space

### Step 3 — Verify

```bash
/kotlinsense:status
```

Expected output:
```
KOTLINSENSE STATUS
──────────────────────────────────
Binary:   ✓ kotlin-language-server found at /Users/you/.local/bin/kotlin-language-server
Java:     ✓ Java 21.0.9 found
LSP:      ✓ .lsp.json loaded — watching .kt and .kts files

KotlinSense is ready. Type errors and diagnostics will appear
automatically after each .kt file edit in Claude Code.
```

### PATH setup (macOS / Linux)

If `kotlin-language-server` is not found after install, add `~/.local/bin` to your PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```

Replace `.zshrc` with `.bashrc` if you use bash.

### Windows install

Run in PowerShell:

```powershell
PowerShell -ExecutionPolicy Bypass -File scripts/install-kotlin-ls.ps1
```

The installer copies `kotlin-language-server` to `%USERPROFILE%\.kotlin-language-server\bin\` and adds that directory to your user PATH automatically. Restart your terminal after install.

---

## Commands

### /kotlinsense:install

Downloads and installs the `kotlin-language-server` binary on your machine.

**What it does:**
1. Checks if `kotlin-language-server` is already installed — skips if found (use `--force` to reinstall)
2. Verifies Java is available
3. Downloads `server.zip` from the official [fwcd/kotlin-language-server](https://github.com/fwcd/kotlin-language-server) GitHub Releases
4. Extracts the server to `~/.kotlin-language-server/`
5. Creates a symlink at `~/.local/bin/kotlin-language-server`
6. Runs the verify script to confirm everything is working

**What gets installed:**
```
~/.kotlin-language-server/
├── bin/
│   └── kotlin-language-server   # launch script (not a jar — resolves lib/ automatically)
└── lib/
    ├── server-1.3.13.jar
    ├── kotlin-compiler-2.1.0.jar
    └── ...                      # all required jars
```

**Example output:**
```
Installing Kotlin Language Server v1.3.13...
Downloading kotlin-language-server...
Extracting...

Installation complete!
Binary:  /Users/you/.kotlin-language-server/bin/kotlin-language-server
Symlink: /Users/you/.local/bin/kotlin-language-server

Verify: kotlin-language-server --version
```

---

### /kotlinsense:status

Checks whether KotlinSense is correctly installed and ready.

**What it checks:**
1. `kotlin-language-server` binary exists in PATH
2. Java is installed and accessible
3. `~/.local/bin` is in PATH (macOS/Linux)

**Example output — ready:**
```
KOTLINSENSE STATUS
──────────────────────────────────
Binary:   ✓ kotlin-language-server found at /Users/you/.local/bin/kotlin-language-server
Java:     ✓ Java 21.0.9 found
PATH:     ✓ ~/.local/bin is in PATH

KotlinSense is ready.
```

**Example output — needs attention:**
```
KOTLINSENSE STATUS
──────────────────────────────────
Binary:   ✗ kotlin-language-server NOT found in PATH
Java:     ✓ Java 21.0.9 found
PATH:     ✗ ~/.local/bin is NOT in PATH

Run /kotlinsense:install to install the language server binary.
```

---

### /kotlinsense:navigate

Uses KotlinSense's code intelligence to navigate and explore your Kotlin project.

**Available operations:**

#### 1. Go to definition
Find where a class, function, property, or object is declared.

```
Where is [ClassName / functionName] defined?
```

Searches for `class Foo`, `interface Foo`, `object Foo`, `fun foo`, `val foo`, `var foo` across all `.kt` files.

#### 2. Find all references
Find every place a symbol is used in the project.

```
Where is [symbol] used?
```

Searches for the symbol name across all `.kt` files in the project.

#### 3. Type inspection
Get the inferred type of an expression or the documentation for a symbol.

```
What is the type of [expression]?
```

Reads the relevant file and explains the type based on Kotlin's type inference rules.

#### 4. File symbol outline
List all classes, interfaces, functions, and top-level properties declared in a file.

```
What are all the functions in [file]?
```

Reads the file and extracts all declarations.

#### 5. Find implementations
Find all classes that implement an interface or extend a base class.

```
What classes implement [InterfaceName]?
```

Searches for `: InterfaceName` patterns across the project.

**Note:** Navigation works best with a full Gradle project open. Run `./gradlew build` at least once so generated code (Room DAOs, Hilt components) is available for analysis.

---

## How Diagnostics Work

KotlinSense connects Claude Code to `kotlin-language-server` via the Language Server Protocol (LSP). The connection is configured in `.lsp.json` at the plugin root and activates automatically when the plugin is enabled.

```
Claude Code edits a .kt or .kts file
            ↓
PostToolUse event fires
            ↓
kotlin-language-server analyzes the change via LSP
            ↓
Diagnostics (errors, warnings) returned to Claude Code
            ↓
Claude sees: "error: Unresolved reference 'foo' at MainActivity.kt:42"
            ↓
Claude fixes the error immediately — same turn, no manual compile step
```

### What is injected automatically

After every `.kt` or `.kts` file edit, Claude sees:

- **Type errors** — wrong type passed to a function, incompatible assignment
- **Unresolved references** — class or function not found (missing import or typo)
- **Null safety violations** — calling a method on a nullable without `?.` or `!!`
- **Suspend function misuse** — calling a suspend function from a non-coroutine context
- **Val reassignment** — attempting to reassign an immutable value
- **Missing override** — function hiding a supertype member without `override`
- **Unused imports** — import statements that are no longer needed

### LSP configuration

The `.lsp.json` file at the plugin root:

```json
{
  "kotlin": {
    "command": "kotlin-language-server",
    "args": [],
    "extensionToLanguage": {
      ".kt": "kotlin",
      ".kts": "kotlin"
    },
    "initializationOptions": {
      "storagePath": "${workspaceFolder}/.kotlin-ls"
    },
    "restartOnCrash": true,
    "maxRestarts": 3,
    "startupTimeout": 60000
  }
}
```

`restartOnCrash: true` ensures the server recovers automatically if it crashes — important for JVM-based servers which can timeout under GC pressure on large projects.

---

## Diagnostics Reference

### Unresolved reference
```
error: unresolved reference: 'FooClass'
```
**Causes:** Missing import, typo, or the class is generated (Room, Hilt) and Gradle has not built yet.

**Fixes:**
- Add the missing import: `import com.example.FooClass`
- Run `./gradlew build` if the class is generated
- Check the dependency is in `build.gradle.kts`

---

### Type mismatch
```
error: type mismatch: inferred type is String but Int was expected
```
**Fix:** Add explicit conversion:
```kotlin
str.toInt()      // String → Int
num.toString()   // Int → String
num.toLong()     // Int → Long
```

---

### Null safety violation
```
error: only safe (?.) or non-null asserted (!!.) calls are allowed on a nullable receiver
```
**Fixes (prefer in this order):**
```kotlin
nullableObj?.method()                    // safe call — returns null if null
nullableObj?.property ?: defaultValue    // Elvis — provide a fallback
nullableObj?.let { obj -> obj.method() } // let block — only runs if non-null
nullableObj!!.method()                   // non-null assertion — crashes if null, use sparingly
```

---

### Val cannot be reassigned
```
error: val cannot be reassigned
```
**Fix:** Change `val` to `var` if the value must change. Prefer `val` (immutable) by default.

---

### Override modifier required
```
error: 'foo' hides member of supertype and needs 'override' modifier
```
**Fix:**
```kotlin
override fun foo() { ... }
override val bar: String = "value"
```

---

### Suspend function in non-suspend context
```
error: suspend function 'collect' should be called only from a coroutine or another suspend function
```
**Fix:**
```kotlin
// In ViewModel
viewModelScope.launch {
    repository.flow.collect { value -> ... }
}

// In Fragment/Activity
viewLifecycleOwner.lifecycleScope.launch {
    viewModel.uiState.collect { state -> render(state) }
}
```

---

### GlobalScope usage discouraged
```
warning: GlobalScope usage is strongly discouraged
```
**Fix:**
```kotlin
viewModelScope.launch { ... }    // in ViewModel
lifecycleScope.launch { ... }    // in Fragment/Activity
coroutineScope { ... }           // in suspend functions
```

---

## Kotlin Android Patterns

KotlinSense includes a `kotlin-android-patterns` skill that provides reference patterns for writing idiomatic, LSP-clean Kotlin code in Android projects.

### StateFlow in ViewModel

```kotlin
private val _uiState = MutableStateFlow<UiState>(UiState.Loading)
val uiState: StateFlow<UiState> = _uiState.asStateFlow()
```

### Collecting StateFlow in Fragment

```kotlin
viewLifecycleOwner.lifecycleScope.launch {
    viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
        viewModel.uiState.collect { state -> render(state) }
    }
}
```

### Sealed class for UI state

```kotlin
sealed class UiState {
    object Loading : UiState()
    data class Success(val data: List<Item>) : UiState()
    data class Error(val message: String) : UiState()
}
```

### Jetpack Compose state hoisting

```kotlin
@Composable
fun MyScreen(viewModel: MyViewModel = viewModel()) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    MyContent(state = uiState, onAction = viewModel::handleAction)
}
```

### Hilt ViewModel injection

```kotlin
@HiltViewModel
class MyViewModel @Inject constructor(
    private val repository: MyRepository
) : ViewModel()
```

For the full pattern reference, see the `kotlin-android-patterns` skill which is automatically loaded by Claude when working on Kotlin files with this plugin active.

---

## First-Time Project Setup

### 1. Open your project in Claude Code

Navigate to your Android project root (the directory containing `settings.gradle.kts`).

### 2. Wait for indexing

On first open, `kotlin-language-server` indexes your project. This takes:

| Project size | Indexing time |
|---|---|
| Small (1–2 modules) | 15–30 seconds |
| Medium Android app (3–5 modules) | 30–60 seconds |
| Large multi-module project | 60–120 seconds |

Diagnostics start appearing after indexing completes.

### 3. Run a Gradle build first

Generated code (Room DAOs, Hilt components, Navigation args, Parcelize) only exists after Gradle has run annotation processors. If you see unresolved reference errors on generated classes:

```bash
./gradlew build
```

Then reopen or re-edit the affected file.

### 4. Edit a .kt file to trigger diagnostics

Make any edit to a `.kt` file — even adding a blank line. The LSP will analyze the change and inject diagnostics into Claude's context. Claude will then see and fix any errors automatically in the same turn.

---

## Plugin Architecture

```
KotlinSense/
├── .claude-plugin/
│   ├── plugin.json              # Plugin manifest
│   └── marketplace.json         # Marketplace manifest
├── .lsp.json                    # LSP server config — connects Claude Code to kotlin-language-server
├── commands/
│   ├── install.md               # /kotlinsense:install
│   ├── status.md                # /kotlinsense:status
│   └── navigate.md              # /kotlinsense:navigate
├── scripts/
│   ├── install-kotlin-ls.sh     # macOS/Linux installer
│   ├── install-kotlin-ls.ps1    # Windows PowerShell installer
│   └── verify-install.sh        # Binary + Java environment check
├── skills/
│   ├── kotlinsense-usage/       # How the plugin works, known limitations
│   ├── kotlin-diagnostics/      # Common diagnostics with causes and fixes
│   └── kotlin-android-patterns/ # Idiomatic ViewModel, StateFlow, Compose, Hilt patterns
├── README.md                    # Quick overview and install guide
├── DOCUMENTATION.md             # This file — full reference
├── CHANGELOG.md                 # Version history
└── LICENSE                      # MIT
```

### How commands and skills interact

- **Commands** (`commands/*.md`) define the user-facing workflow. They give Claude step-by-step instructions for what to check, run, and report.
- **Skills** (`skills/*/SKILL.md`) are reference knowledge loaded automatically by Claude when working on Kotlin files. They contain diagnostic rules, fix patterns, and Android-specific guidance — without requiring the user to invoke them manually.
- **`.lsp.json`** is the core of the plugin — it tells Claude Code how to start `kotlin-language-server` and which file extensions to watch. Everything else is guidance layered on top of the live LSP connection.

---

## Troubleshooting

### Diagnostics not appearing after file edits

1. Run `/kotlinsense:status` — check binary and Java are found
2. If binary is missing: run `/kotlinsense:install`
3. If PATH issue: add `~/.local/bin` to PATH and restart terminal
4. Restart Claude Code after PATH changes

### kotlin-language-server: command not found

```bash
export PATH="$HOME/.local/bin:$PATH"
which kotlin-language-server
```

If still not found, run `/kotlinsense:install`. If already installed, check the symlink:

```bash
ls -la ~/.local/bin/kotlin-language-server
ls -la ~/.kotlin-language-server/bin/kotlin-language-server
```

### Slow startup (30–90+ seconds)

Normal on first project open — the server indexes all source files. Wait for indexing to complete before expecting diagnostics. Large multi-module Android projects take longer.

### False positive errors on generated code

Room DAOs, Hilt components, Navigation args, and Parcelize implementations are generated by annotation processors at build time. They don't exist as source files, so the language server can't find them until Gradle has run.

**Fix:**
```bash
./gradlew build
```

Then edit the affected `.kt` file to trigger a fresh LSP analysis.

### Server keeps crashing

`.lsp.json` has `restartOnCrash: true` and `maxRestarts: 3` — the server will restart automatically up to 3 times. If crashes persist:

1. Check Java version: `java -version` (17+ required)
2. Check available RAM — `kotlin-language-server` uses 512 MB–1 GB for large projects
3. Try reinstalling: `/kotlinsense:install --force`

### Kotlin Multiplatform projects

KMP projects are partially supported. The language server indexes the `commonMain`, `androidMain`, and `jvmMain` source sets. `iosMain` and native targets have limited support. Expect some false positives in shared code that uses platform-specific expect/actual declarations.
