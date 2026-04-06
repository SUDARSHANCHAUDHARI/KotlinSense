---
name: kotlin-android-patterns
description: Kotlin and Android code patterns that produce LSP-clean, idiomatic code. Use when writing Kotlin for Android, reviewing Kotlin code quality, or generating new Kotlin/Compose code.
---

## Kotlin Android Patterns — LSP-Clean and Idiomatic

### Null safety
```kotlin
// Safe call + Elvis (preferred)
val name = user?.name ?: "Unknown"

// Let block for operations on nullable
user?.let { processUser(it) }

// Avoid: force unwrap crashes on null
val name = user!!.name  // only use if you are certain it's non-null
```

### Coroutines — scope by context
```kotlin
// ViewModel: use viewModelScope (auto-cancelled when ViewModel clears)
class MyViewModel : ViewModel() {
    fun loadData() {
        viewModelScope.launch {
            val result = repository.getData()
            _uiState.value = UiState.Success(result)
        }
    }
}

// Fragment/Activity: use lifecycleScope
lifecycleScope.launch {
    viewModel.uiState.collect { state -> render(state) }
}

// Structured fan-out in suspend functions
suspend fun fetchAll() = coroutineScope {
    val a = async { repository.getA() }
    val b = async { repository.getB() }
    combine(a.await(), b.await())
}
```

### StateFlow pattern (ViewModel → UI)
```kotlin
// ViewModel
private val _uiState = MutableStateFlow<UiState>(UiState.Loading)
val uiState: StateFlow<UiState> = _uiState.asStateFlow()

// Fragment — collect safely with repeatOnLifecycle
viewLifecycleOwner.lifecycleScope.launch {
    viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
        viewModel.uiState.collect { state -> render(state) }
    }
}
```

### Sealed class for UI state (exhaustive when)
```kotlin
sealed class UiState {
    object Loading : UiState()
    data class Success(val data: List<Item>) : UiState()
    data class Error(val message: String) : UiState()
}

// In Compose — exhaustive when prevents missing branches
when (val state = uiState) {
    is UiState.Loading -> LoadingSpinner()
    is UiState.Success -> ItemList(state.data)
    is UiState.Error   -> ErrorMessage(state.message)
}
```

### Jetpack Compose patterns
```kotlin
// State hoisting: ViewModel owns state, composable is stateless
@Composable
fun MyScreen(viewModel: MyViewModel = viewModel()) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    MyContent(state = uiState, onAction = viewModel::handleAction)
}

// Derived state — recomputes only when inputs change
val filteredList by remember(searchQuery, items) {
    derivedStateOf { items.filter { it.name.contains(searchQuery, ignoreCase = true) } }
}

// Side effects — launch once on first composition
LaunchedEffect(Unit) {
    viewModel.loadInitialData()
}
```

### Data classes
```kotlin
// Use data classes for models and UI state
data class User(
    val id: String,
    val name: String,
    val email: String
)

// Modify with copy (preserves immutability)
val updated = user.copy(name = "New Name")
```

### Extension functions
```kotlin
// Prefer extension functions over utility classes
fun String.isValidEmail(): Boolean =
    android.util.Patterns.EMAIL_ADDRESS.matcher(this).matches()

fun Context.showToast(message: String, duration: Int = Toast.LENGTH_SHORT) =
    Toast.makeText(this, message, duration).show()

// Extension on Flow for common patterns
fun <T> Flow<T>.stateIn(scope: CoroutineScope, initial: T): StateFlow<T> =
    stateIn(scope, SharingStarted.WhileSubscribed(5_000), initial)
```

### Result type for error handling
```kotlin
// Wrap repository calls in Result
suspend fun getUser(id: String): Result<User> = runCatching {
    api.getUser(id)
}

// In ViewModel
viewModelScope.launch {
    repository.getUser(userId)
        .onSuccess { user -> _uiState.value = UiState.Success(user) }
        .onFailure { e -> _uiState.value = UiState.Error(e.message ?: "Unknown error") }
}
```

### Hilt dependency injection
```kotlin
// ViewModel injection (no factory boilerplate needed)
@HiltViewModel
class MyViewModel @Inject constructor(
    private val repository: MyRepository
) : ViewModel()

// Fragment
@AndroidEntryPoint
class MyFragment : Fragment() {
    private val viewModel: MyViewModel by viewModels()
}
```
