# DEBT-024: Timestamp Warning Flow Duplicated Across ViewModels

**Priority:** P2 (Important - DRY Violation)
**Status:** OPEN
**Created:** 2026-01-28

## Problem

The old timestamp warning and confirmation flow is **90% identical** across two ViewModels - ~40 lines duplicated.

---

## Duplicated Pattern

### CravingLogViewModel.swift (lines 61-95)
### UsageLogViewModel.swift (lines 87-123)

```swift
// Both VMs have identical:
var showTimestampWarning: Bool = false
@ObservationIgnored private var hasAcknowledgedOldTimestamp: Bool = false

var isTimestampOld: Bool {
    TimestampValidation.isOlderThanWarningThreshold(timestamp: timestamp, now: nowProvider())
}

func logX() async {
    // Check for old timestamp warning
    if isTimestampOld, !hasAcknowledgedOldTimestamp {
        showTimestampWarning = true
        return
    }

    guard canSubmit else { return }

    isLoading = true
    errorMessage = nil
    defer { isLoading = false }

    do {
        _ = try await useCase.execute(...)
        triggerSuccessFeedback()
    } catch {
        errorMessage = error.localizedDescription
    }
}

func confirmOldTimestamp() async {
    showTimestampWarning = false
    hasAcknowledgedOldTimestamp = true
    await logX()
}

private func triggerSuccessFeedback() {
    didSucceed = true
}
```

---

## Rob C. Martin Fix: Protocol with Default Implementation

```swift
// Cravey/Presentation/Protocols/TimestampWarningHandling.swift

/// Shared timestamp warning flow for logging ViewModels.
@MainActor
protocol TimestampWarningHandling: AnyObject {
    var timestamp: Date { get }
    var showTimestampWarning: Bool { get set }
    var hasAcknowledgedOldTimestamp: Bool { get set }
    var nowProvider: @Sendable () -> Date { get }

    /// Called to perform the actual logging operation
    func performLog() async
}

extension TimestampWarningHandling {
    var isTimestampOld: Bool {
        TimestampValidation.isOlderThanWarningThreshold(timestamp: timestamp, now: nowProvider())
    }

    /// Validates timestamp and either shows warning or proceeds with logging
    func validateAndLog() async {
        if isTimestampOld, !hasAcknowledgedOldTimestamp {
            showTimestampWarning = true
            return
        }
        await performLog()
    }

    func confirmOldTimestamp() async {
        showTimestampWarning = false
        hasAcknowledgedOldTimestamp = true
        await performLog()
    }
}

// Usage in ViewModel:
func logCraving() async {
    await validateAndLog()  // Shared warning logic
}

func performLog() async {
    // Actual use case execution (specific to each VM)
}
```

---

## Files to Modify

| File | Change |
|------|--------|
| Create `Cravey/Presentation/Protocols/TimestampWarningHandling.swift` | New protocol |
| `CravingLogViewModel.swift` | Conform to protocol, refactor logCraving() |
| `UsageLogViewModel.swift` | Conform to protocol, refactor logUsage() |

---

## Acceptance Criteria

- [ ] Single source of truth for timestamp validation logic
- [ ] Both ViewModels use shared `validateAndLog()` and `confirmOldTimestamp()`
- [ ] `isTimestampOld` computed property defined once
- [ ] All tests pass
