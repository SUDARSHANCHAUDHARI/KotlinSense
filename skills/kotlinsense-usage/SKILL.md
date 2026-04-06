---
name: kotlinsense-usage
description: How to use the KotlinSense plugin effectively. Use when working on Kotlin or Android projects with the kotlinsense plugin active, or when explaining LSP diagnostics to the user.
---

## KotlinSense — How It Works

KotlinSense connects Claude Code to `kotlin-language-server` via the Language Server Protocol. After every `.kt` or `.kts` file edit, the server analyzes changes and returns diagnostics that appear directly in Claude's context.

### What happens automatically after each edit
- Type errors are detected and surfaced immediately
- Missing imports are flagged with resolution suggestions
- Null safety violations (`?.` vs `!!`) are caught
- Unused imports and variables are reported
- Suspend function misuse (calling from non-coroutine context) is detected
- Override and visibility modifier issues are caught

### What Claude can do with these diagnostics
- Fix type mismatches inline, in the same turn — no manual compile step needed
- Add missing imports automatically
- Correct null safety issues before they become runtime crashes
- Fix coroutine scope usage (e.g., replace `GlobalScope` with `viewModelScope`)

### First-time project indexing
On first open, `kotlin-language-server` takes 30–90 seconds to index the project. This is normal. Diagnostics begin appearing after indexing completes. Large multi-module Android projects take longer.

### When to run `/kotlinsense:status`
- If diagnostics aren't appearing after file edits
- After installing the binary for the first time
- After a terminal restart that updated PATH

### Known limitations
- Works best with Gradle-based projects
- Generated code (Room DAOs, Hilt components, etc.) may show false-positive errors until `./gradlew build` has run
- Kotlin Multiplatform projects are partially supported
- `.kts` build scripts have limited support
