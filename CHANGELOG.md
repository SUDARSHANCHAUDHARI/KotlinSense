# Changelog

All notable changes to KotlinSense will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.0.0] — 2026-04-06

### Added
- `/kotlinsense:install` — download and install `kotlin-language-server` on macOS, Linux, and Windows
- `/kotlinsense:status` — check binary, Java, and LSP activation status
- `/kotlinsense:navigate` — go-to-definition, find references, type inspection, and symbol listing
- `.lsp.json` — LSP server config connecting Claude Code to `kotlin-language-server` for `.kt` and `.kts` files
- `kotlinsense-usage` skill — how the plugin works, what happens automatically, known limitations
- `kotlin-diagnostics` skill — 10 common Kotlin diagnostics with causes and fixes
- `kotlin-android-patterns` skill — idiomatic patterns for ViewModel, StateFlow, Compose, Hilt, coroutines
- `scripts/install-kotlin-ls.sh` — macOS/Linux installer for `kotlin-language-server` v1.3.13
- `scripts/install-kotlin-ls.ps1` — Windows PowerShell installer
- `scripts/verify-install.sh` — binary and Java environment verification script
- MIT License
