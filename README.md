# KotlinSense

[![Version](https://img.shields.io/badge/version-1.0.0-blue)](.claude-plugin/plugin.json)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)
![Platform](https://img.shields.io/badge/platform-Claude%20Code-blueviolet)
![Target](https://img.shields.io/badge/target-Kotlin%20%2F%20Android-brightgreen)

> Kotlin code intelligence for Claude Code — automatic type checking, import resolution, null safety detection, and error diagnostics injected directly into Claude's context after every `.kt` file edit.

**KotlinSense** is a Claude Code plugin that bridges `kotlin-language-server` into Claude's
context, so Claude sees what the Kotlin compiler sees and fixes issues in the same turn —
before they reach the build.

## Table of Contents

- [Overview](#overview)
- [What It Does](#what-it-does)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Commands](#commands)
- [How It Works](#how-it-works)
- [Plugin Structure](#plugin-structure)
- [Requirements](#requirements)
- [Troubleshooting](#troubleshooting)
- [Documentation](#documentation)
- [License](#license)
- [About](#about)

## Overview

AI code generation for Kotlin without LSP context produces suggestions that compile but fail
at runtime. Missing imports get suggested. Incorrect types get inferred. Null safety violations
get introduced. The suggestions look plausible but are wrong in ways that only the Kotlin
compiler would catch.

KotlinSense bridges `kotlin-language-server` into Claude Code's context. After every `.kt` file
edit, real diagnostics — type errors, missing imports, null safety violations — are injected
automatically. Claude sees what the compiler sees and fixes issues in the same turn, before
they reach the build.

## What It Does

1. Connects Claude Code to `kotlin-language-server` via the Language Server Protocol
2. After every `.kt` / `.kts` file edit, diagnostics are injected into Claude's context automatically
3. Claude sees type errors, missing imports, and null safety violations — and fixes them in the same turn

Works for any Kotlin or Android developer. No project-specific config needed — just install the binary and go.

## Installation

**Step 1 — Add the marketplace**
```bash
/plugin marketplace add SUDARSHANCHAUDHARI/KotlinSense
```

**Step 2 — Install the plugin**
```bash
/plugin install kotlinsense
```

Then install the language server binary:

```bash
/kotlinsense:install
```

Requires Java 17+. Run `/kotlinsense:status` to verify.

## Quick Start

**1. Install the language server**
```
/kotlinsense:install
```
Downloads `kotlin-language-server` and adds it to your PATH. Requires Java 17+.

**2. Verify it's working**
```
/kotlinsense:status
```
Confirms the binary, Java, and LSP connection are all ready.

**3. Open a Kotlin project and start editing**

Open any `.kt` file and make an edit. KotlinSense automatically injects diagnostics into Claude's context — type errors, missing imports, null safety violations — and Claude fixes them in the same turn.

## Commands

| Command | Description |
|---|---|
| `/kotlinsense:install` | Download and install `kotlin-language-server` |
| `/kotlinsense:status` | Check binary, Java, and LSP activation status |
| `/kotlinsense:navigate` | Go-to-definition, find references, type inspection |

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

## Requirements

- [Claude Code](https://claude.ai/code) installed and authenticated
- Java 17+ (`java -version` to check — install from [adoptium.net](https://adoptium.net/))
- Internet connection for initial binary download (~50 MB)

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

## Documentation

For full details — complete command walkthroughs, diagnostics reference, first-time setup guide, troubleshooting, and plugin architecture — see [DOCUMENTATION.md](DOCUMENTATION.md).

- Kotlin Language Server: [github.com/fwcd/kotlin-language-server](https://github.com/fwcd/kotlin-language-server)
- Privacy Policy: [github.com/SUDARSHANCHAUDHARI/kotlinsense-claude-plugin-privacy-policy](https://github.com/SUDARSHANCHAUDHARI/kotlinsense-claude-plugin-privacy-policy)
- Issues: [github.com/SUDARSHANCHAUDHARI/KotlinSense/issues](https://github.com/SUDARSHANCHAUDHARI/KotlinSense/issues)

## License

MIT — see [LICENSE](LICENSE).

---

## About

I'm Sudarshan Chaudhari, a Senior Quality Engineer, Test Automation specialist, and AI systems builder based in Bangkok, Thailand.

I have 13+ years of experience in software quality engineering, working across SaaS, fintech, gaming, web, mobile, cloud, and digital signage platforms. My background combines hands-on test automation with QA leadership, test strategy, CI/CD, release quality, production investigation, and cross-platform validation.

Alongside my professional QA career, I run [SudarshanTechLabs](https://sudarshantechlabs.com/), my independent engineering and product lab where I design, build, test, and ship software across Android, web, AI, cybersecurity, developer tooling, and cross-platform applications.

### What I work on

- ⚙️ **Quality Engineering & Test Automation** — Playwright, Selenium, Cypress, Appium, API testing, automation frameworks, end-to-end testing, CI/CD, release gates, GitHub Actions, risk-based testing, and production validation
- 🤖 **AI Systems & Automation** — AI agents, multi-agent orchestration, MCP servers, AI-assisted QA, prompt tooling, developer workflows, automation systems, and Claude Code plugins
- 📱 **Mobile & Cross-Platform Applications** — Android applications built with Kotlin and Jetpack Compose, Google Play releases, automated build and publishing pipelines, and cross-platform development spanning iOS, web, Windows, and macOS
- 🌐 **Web Applications & Platforms** — Full-stack applications using Next.js, TypeScript, Firebase, Cloudflare, REST APIs, and modern web infrastructure
- 🛠️ **Developer Tooling & CLI Engineering** — Rust, Python, TypeScript, CLI utilities, multi-repository tooling, build automation, release tooling, and engineering productivity systems
- 🛡️ **Cybersecurity & Observability** — Threat detection, log analysis, security auditing, vulnerability assessment, monitoring, and security-focused developer tools
- 📺 **Digital Signage & Device Platforms** — Content validation, playback testing, device compatibility, production investigation, monitoring, and QA across diverse hardware and operating-system environments

My work sits at the intersection of quality engineering, automation, AI, and software development. I approach products with a QA mindset from the beginning: understanding failure modes, designing for testability, automating repetitive work, and building release confidence into the engineering process.

Through SudarshanTechLabs, I also build products and tools from idea to production, covering architecture, development, testing, CI/CD, release automation, monitoring, and ongoing maintenance.

🌐 [sudarshantechlabs.com](https://sudarshantechlabs.com/) · 💼 [LinkedIn](https://linkedin.com/in/sudarshan-chaudhari) · 🐙 [GitHub](https://github.com/SUDARSHANCHAUDHARI) · ✉️ [sunny.sudarshan@gmail.com](mailto:sunny.sudarshan@gmail.com)
