# DEBT-022: Code Duplication in ViewModel Error Handling

**Priority:** P3 (Architecture)
**Status:** RESOLVED
**Resolved:** 2026-01-29
**Resolution:** Created FormSubmission protocol with withLoadingState/markSuccess/handleError. Both ViewModels now conform.
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

**Option A (Extract)** - Extraction completed via `FormSubmission` protocol and `withLoadingState` helper. Both `CravingLogViewModel` and `UsageLogViewModel` now share the loading/error/success pattern while keeping their domain-specific validation and error types.

**Status:** Resolved — extraction implemented; monitor for regressions.

---

## Files Affected

| File | Lines | Notes |
| --- | --- | --- |
| `CravingLogViewModel.swift` | 61-88 | logCraving() |
| `UsageLogViewModel.swift` | 87-116 | logUsage() |

---

## Acceptance Criteria

- [x] Decision made: Extract
- [x] Protocol created, ViewModels updated
- [x] All tests pass
