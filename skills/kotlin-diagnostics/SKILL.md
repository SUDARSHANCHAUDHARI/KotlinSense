---
name: kotlin-diagnostics
description: Common Kotlin diagnostics from the language server and how to fix them. Use when the LSP reports Kotlin errors or warnings, or when diagnosing compilation failures in a Kotlin or Android project.
---

## Common KotlinSense Diagnostics and Fixes

### Unresolved reference
```
error: unresolved reference: 'FooClass'
```
**Fixes:**
- Add the missing import: `import com.example.FooClass`
- Check for a typo in the class/function name
- Ensure the dependency is in `build.gradle.kts` (`implementation(...)`)
- Run `./gradlew build` if the class is generated (Room, Hilt, etc.)

---

### Type mismatch
```
error: type mismatch: inferred type is String but Int was expected
```
**Fixes:**
- Add explicit conversion: `str.toInt()`, `num.toString()`, `num.toLong()`
- Use `when` for sealed class branches to satisfy exhaustiveness
- Check if you're passing the wrong variable to a function

---

### Null safety violation
```
error: only safe (?.) or non-null asserted (!!.) calls are allowed on a nullable receiver
```
**Fixes (prefer in this order):**
```kotlin
// 1. Safe call — returns null if receiver is null
nullableObj?.method()

// 2. Elvis operator — provide a default
nullableObj?.property ?: defaultValue

// 3. Let block — operate only when non-null
nullableObj?.let { obj ->
    obj.method()
}

// 4. Non-null assertion — only if you're certain it can't be null
nullableObj!!.method()  // crashes with NullPointerException if null
```

---

### Val cannot be reassigned
```
error: val cannot be reassigned
```
**Fix:** Change `val` to `var` if reassignment is needed. Prefer `val` (immutable) by default.

---

### Override modifier required
```
error: 'foo' hides member of supertype and needs 'override' modifier
```
**Fix:** Add the `override` keyword:
```kotlin
override fun foo() { ... }
override val bar: String = "value"
```

---

### Suspend function called from non-suspend context
```
error: suspend function 'collect' should be called only from a coroutine or another suspend function
```
**Fix:** Call from a coroutine scope:
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

### Missing return statement
```
error: a 'return' expression required in a function with a block body
```
**Fixes:**
```kotlin
// Option 1: add explicit return
fun foo(): String {
    return "value"
}

// Option 2: use expression body (preferred for simple functions)
fun foo(): String = "value"
```

---

### GlobalScope usage discouraged
```
warning: GlobalScope usage is strongly discouraged
```
**Fix:** Replace with structured concurrency:
```kotlin
// In ViewModel
viewModelScope.launch { ... }

// In Fragment/Activity
lifecycleScope.launch { ... }

// In a suspend function — use coroutineScope { } for fan-out
coroutineScope {
    launch { ... }
    launch { ... }
}
```

---

### Android-specific: View? type mismatch
```
error: type mismatch: inferred type is View? but View was expected
```
**Fix:** Migrate to View Binding or Jetpack Compose. If using XML temporarily:
```kotlin
val button = findViewById<Button>(R.id.myButton) ?: return
```

---

### Compose: state read inside non-restartable composable
**Fix:** Hoist state reads into restartable composables, or use `remember`:
```kotlin
val count by remember { mutableStateOf(0) }
```
