# DEBT-022: Code Duplication in ViewModel Error Handling

**Priority:** P3 (Architecture)
**Status:** OPEN
**Created:** 2026-01-28

## Problem

`CravingLogViewModel.logCraving()` and `UsageLogViewModel.logUsage()` have nearly identical:
- Loading state management
- Timestamp warning logic
- Error handling flow
- Success/failure state updates

---

## Duplicated Pattern

### CravingLogViewModel (Lines 61-88)
```swift
func logCraving() async {
    isLoading = true
    defer { isLoading = false }
    errorMessage = nil

    // Timestamp warning check...

    do {
        try await logCravingUseCase.execute(...)
        didSaveSuccessfully = true
    } catch let error as CravingError {
        errorMessage = error.localizedDescription
    } catch {
        errorMessage = "An unexpected error occurred"
    }
}
```

### UsageLogViewModel (Lines 87-116)
```swift
func logUsage() async {
    isLoading = true
    defer { isLoading = false }
    errorMessage = nil

    // Timestamp warning check...

    do {
        try await logUsageUseCase.execute(...)
        didSaveSuccessfully = true
    } catch let error as UsageError {
        errorMessage = error.localizedDescription
    } catch {
        errorMessage = "An unexpected error occurred"
    }
}
```

---

## Options

### Option A: Extract to Protocol Extension (Recommended)
Create a `LoggingViewModel` protocol with default implementations:

```swift
protocol LoggingViewModel: AnyObject {
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
    var didSaveSuccessfully: Bool { get set }
}

extension LoggingViewModel {
    func withLoadingState<T>(_ operation: () async throws -> T) async rethrows -> T {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        return try await operation()
    }
}
```

### Option B: Accept Duplication
The duplication is ~30 lines per ViewModel. If requirements diverge (different validation, different error types), keeping them separate may be cleaner.

---

## Recommendation

**Option B (Accept)** - The duplication is manageable and the ViewModels may diverge. The error types are already different (`CravingError` vs `UsageError`), and extracting would add complexity for minimal gain.

**Status:** Document as known duplication, monitor for drift.

---

## Files Affected

| File | Lines | Notes |
|------|-------|-------|
| `CravingLogViewModel.swift` | 61-87 | logCraving() |
| `UsageLogViewModel.swift` | 87-116 | logUsage() |

---

## Acceptance Criteria

- [ ] Decision made: Extract or Accept
- [ ] If Extract: Protocol created, ViewModels updated
- [ ] If Accept: Document as intentional, add comment referencing this debt item
