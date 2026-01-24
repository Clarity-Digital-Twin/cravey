# P1 - Major Bugs

**Status:** ACTIVE
**Last Updated:** 2025-01-24

Features not working as specified, significant issues that affect user experience.

---

## BUG-003: ModelContext Thread Safety (nonisolated unsafe)

**Files:**
- `Cravey/Data/Repositories/CravingRepository.swift:6`
- `Cravey/Data/Repositories/UsageRepository.swift:6`

### Problem
```swift
private nonisolated(unsafe) let modelContext: ModelContext
```

Using `nonisolated(unsafe)` is a workaround for Clean Architecture compatibility, but it bypasses Swift's concurrency safety checks.

### Impact
- Potential data races if accessed from multiple threads
- SwiftData runtime warnings: "Unbinding from the main queue"
- Could cause crashes or data corruption under heavy load

### Current Mitigation
All repository access goes through `@MainActor` ViewModels, so in practice it's main-thread only.

### Proper Fix
Use `@ModelActor` pattern (but requires architecture change):
```swift
@ModelActor
actor CravingRepository: CravingRepositoryProtocol {
    func save(_ entity: CravingEntity) async throws {
        // Automatically thread-safe
    }
}
```

### Decision Needed
- Accept current workaround with documented risk, OR
- Refactor to `@ModelActor` (breaks some Clean Architecture patterns)

### Acceptance Criteria
- [ ] Document the thread safety assumption in code comments
- [ ] Add assertion that we're on main thread in debug builds
- [ ] OR refactor to proper actor isolation

---

## BUG-004: Silently Swallowed Errors in ModelContainerSetup

**File:** `Cravey/Data/Storage/ModelContainerSetup.swift`
**Lines:** 82, 93-95

### Problem
```swift
let existingMessages = (try? context.fetch(descriptor)) ?? []  // Silent fail

} catch {
    print("[ModelContainerSetup] Failed to seed default messages: \(error)")  // Logged but ignored
}
```

### Impact
- If default motivational messages fail to load, user sees empty list
- No indication to user that something went wrong
- Hard to debug in production

### Fix
```swift
// Option 1: Propagate error
func seedDefaultMessages(context: ModelContext) throws {
    // ...
    let existingMessages = try context.fetch(descriptor)
    // ...
}

// Option 2: Log properly and surface to user
} catch {
    Logger.error("Failed to seed messages: \(error)")
    // Set flag so UI can show "Some features unavailable"
}
```

### Acceptance Criteria
- [ ] Errors are logged with proper logging framework
- [ ] Critical failures surface to user appropriately
- [ ] No more `try?` that silently swallow errors

---

## BUG-005: LogUsageUseCase - 6 Parameter Function

**File:** `Cravey/Domain/UseCases/LogUsageUseCase.swift:5`

### Problem
```swift
func execute(
    timestamp: Date,
    method: String,
    amount: Double,
    triggers: [String],
    location: String?,
    notes: String?
) async throws -> UsageEntity
```

6 parameters violates SwiftLint rule and makes function hard to test/maintain.

### Impact
- SwiftLint warning
- Hard to remember parameter order
- Easy to make mistakes when calling

### Fix
Create a parameter object:
```swift
struct LogUsageRequest {
    let timestamp: Date
    let method: String
    let amount: Double
    let triggers: [String]
    let location: String?
    let notes: String?
}

func execute(_ request: LogUsageRequest) async throws -> UsageEntity
```

### Acceptance Criteria
- [ ] SwiftLint warning resolved
- [ ] Parameter object created
- [ ] All call sites updated

---

## BUG-006: Task.sleep Error Ignored in HomeView

**File:** `Cravey/Presentation/Views/Home/HomeView.swift:180`

### Problem
```swift
try? await Task.sleep(for: .seconds(2))
showSuccessToast = false
```

### Impact
Low - if sleep fails, toast just disappears immediately. Not critical.

### Fix
```swift
do {
    try await Task.sleep(for: .seconds(2))
} catch {
    // Task was cancelled, that's fine
}
showSuccessToast = false
```

### Priority
Low - but should fix for consistency.

---

## Summary

| Bug ID | Description | Status | Priority |
|--------|-------------|--------|----------|
| BUG-003 | nonisolated(unsafe) ModelContext | OPEN | High |
| BUG-004 | Swallowed errors in seed data | OPEN | High |
| BUG-005 | 6 param function violation | OPEN | Medium |
| BUG-006 | Task.sleep error ignored | OPEN | Low |
