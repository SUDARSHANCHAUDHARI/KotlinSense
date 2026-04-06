# KotlinSense — Claude Code Plugin

> Kotlin code intelligence for Claude Code. Automatic type checking, import resolution, null safety detection, and error diagnostics injected directly into Claude's context after every `.kt` file edit.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Claude%20Code-blueviolet)
![Target](https://img.shields.io/badge/target-Kotlin%20%2F%20Android-brightgreen)

---

## What It Does

1. Connects Claude Code to `kotlin-language-server` via the Language Server Protocol
2. After every `.kt` / `.kts` file edit, diagnostics are injected into Claude's context automatically
3. Claude sees type errors, missing imports, and null safety violations — and fixes them in the same turn

Works for any Kotlin or Android developer. No project-specific config needed — just install the binary and go.

---

## Install

```bash
/plugin install kotlinsense
```

Then install the language server binary:

```bash
/kotlinsense:install
```

Requires Java 17+. Run `/kotlinsense:status` to verify.

---

## Commands

| Command | Description |
|---|---|
| `/kotlinsense:install` | Download and install `kotlin-language-server` |
| `/kotlinsense:status` | Check binary, Java, and LSP activation status |
| `/kotlinsense:navigate` | Go-to-definition, find references, type inspection |

---

## How It Works

```
Claude Code edits a .kt file
    ↓
kotlin-language-server analyzes the change (via LSP)
    ↓
Diagnostics injected into Claude's context
    ↓
Claude sees: "error: Unresolved reference 'foo' at MainActivity.kt:42"
    ↓
Claude fixes it immediately — same turn, no manual compile step
```

The LSP connection is defined in `.lsp.json` and activates automatically when the plugin is enabled.

---

## What You Get

| Feature | Description |
|---|---|
| Auto diagnostics | After every `.kt` / `.kts` edit, type errors appear in Claude's context automatically |
| Import resolution | Missing imports detected and flagged |
| Null safety | Kotlin null safety violations caught before runtime |
| Coroutine checks | Suspend function misuse flagged (wrong scope, GlobalScope, etc.) |
| Code navigation | `/kotlinsense:navigate` for go-to-definition and find-references |
| Android patterns | Built-in knowledge of ViewModel, StateFlow, Compose, Hilt patterns |

---

## Plugin Structure

```
KotlinSense/
├── .claude-plugin/
│   ├── plugin.json              # Plugin manifest
│   └── marketplace.json         # Marketplace manifest
├── .lsp.json                    # LSP server config (.kt / .kts → kotlin-language-server)
├── commands/                    # /kotlinsense:install|status|navigate
├── scripts/
│   ├── install-kotlin-ls.sh     # macOS / Linux installer
│   ├── install-kotlin-ls.ps1   # Windows PowerShell installer
│   └── verify-install.sh        # Binary + Java environment check
├── skills/
│   ├── kotlinsense-usage/       # How the plugin works, known limitations
│   ├── kotlin-diagnostics/      # 10 common diagnostics with fixes
│   └── kotlin-android-patterns/ # Idiomatic ViewModel, StateFlow, Compose, Hilt patterns
├── README.md
├── CHANGELOG.md
└── LICENSE
```

---

## Requirements

- [Claude Code](https://claude.ai/code) installed and authenticated
- Java 17+ (`java -version` to check — install from [adoptium.net](https://adoptium.net/))
- Internet connection for initial binary download (~50 MB)

---

## Troubleshooting

**Diagnostics not appearing after file edits**
Run `/kotlinsense:status` to diagnose. Ensure `kotlin-language-server` is in PATH — restart terminal after install.

**`kotlin-language-server: command not found`**
Run `/kotlinsense:install`. Then check `$HOME/.local/bin` is in PATH: `echo $PATH`.

**Slow startup (30–90 seconds on first open)**
Normal — the server indexes the project on first open. Large Android projects take longer.

**False positive errors on generated code (Room, Hilt, etc.)**
Run `./gradlew build` first so annotation processors generate their output, then reopen the file.

**Java not found**
Install Java 17+ from [adoptium.net](https://adoptium.net/). Verify: `java -version`.

---

## Reference

- Kotlin Language Server: [github.com/fwcd/kotlin-language-server](https://github.com/fwcd/kotlin-language-server)
- Claude Code Plugins: [code.claude.com/docs/en/plugins](https://code.claude.com/docs/en/plugins)
- Privacy Policy: [github.com/SUDARSHANCHAUDHARI/kotlinsense-claude-plugin-privacy-policy](https://github.com/SUDARSHANCHAUDHARI/kotlinsense-claude-plugin-privacy-policy)
- Submit feedback: [github.com/SUDARSHANCHAUDHARI/KotlinSense/issues](https://github.com/SUDARSHANCHAUDHARI/KotlinSense/issues)

---

## Author

**SUDARSHANCHAUDHARI** — [github.com/SUDARSHANCHAUDHARI](https://github.com/SUDARSHANCHAUDHARI)
SudarshanTechLabs | sudarshantechlabs@gmail.com

---

## License

MIT — see [LICENSE](LICENSE)
