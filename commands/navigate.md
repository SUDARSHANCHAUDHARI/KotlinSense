Use KotlinSense navigation features to explore the current Kotlin project.

Ask the user which navigation operation they need, then assist using LSP-backed information:

## Available operations

### 1. Go to definition
Find where a class, function, property, or variable is declared.

Ask: "What class or function do you want to find the definition of?"

Then search the codebase using Glob and Read tools:
- For a class `Foo`: search for `class Foo`, `interface Foo`, `object Foo`
- For a function `doSomething`: search for `fun doSomething`
- For a property: search for `val name` or `var name`

### 2. Find all references / usages
Find every place a symbol is used in the project.

Ask: "What symbol do you want to find usages of?"

Then use Grep to search across all `.kt` files:
```bash
grep -rn "symbolName" --include="*.kt" .
```

### 3. Inspect type / hover information
Get the inferred type of an expression or read the documentation for a symbol.

Ask: "Which expression or symbol do you want type information for?"

Then read the relevant file and explain the type based on Kotlin type inference rules.

### 4. List symbols in a file
List all classes, functions, and properties declared in a specific file.

Ask: "Which file do you want to see the symbol outline for?"

Then read the file and extract:
- All `class`, `interface`, `object`, `enum class` declarations
- All `fun` declarations (including their signatures)
- All top-level `val`/`var` declarations

### 5. Find implementations of an interface
Find all classes that implement a given interface or extend a given class.

Ask: "Which interface or base class do you want to find implementations of?"

Then search for `: InterfaceName` patterns across the project.

## Notes on availability
- Navigation works best when the full project is open (not just a single file)
- Run `./gradlew build` at least once so Gradle generates annotation processor output
- The language server takes 30–60 seconds to finish indexing a large project on first open
- KMP (Kotlin Multiplatform) projects are partially supported
