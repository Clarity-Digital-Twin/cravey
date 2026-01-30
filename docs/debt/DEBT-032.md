# DEBT-032: 100-Second Sleep in Preview Mock Blocks Development

**Priority:** P1 (Critical - Development Blocker)
**Status:** OPEN
**Created:** 2026-01-29

## Problem

The `PreviewMockFetchUsageUseCase` in `UsageListView.swift` has a **100-second sleep** that blocks the preview system for over 1.5 minutes when testing the loading state.

---

## Location

**File:** `Cravey/Presentation/Views/Usage/UsageListView.swift`
**Line:** 259

```swift
actor PreviewMockFetchUsageUseCase: FetchUsageUseCase {
    let returnEmpty: Bool
    let simulateLoading: Bool

    init(returnEmpty: Bool = false, simulateLoading: Bool = false) {
        self.returnEmpty = returnEmpty
        self.simulateLoading = simulateLoading
    }

    func execute() async throws -> [UsageEntity] {
        if simulateLoading {
            try await Task.sleep(for: .seconds(100)) // <- BUG: 100 seconds!
        }
        // ...
    }
}
```

---

## Impact

- Preview "Loading State" hangs for 100 seconds
- Developers cannot quickly iterate on loading UI
- Likely a debugging leftover (forgot to change back from 100 to 1-2 seconds)
- Wastes developer time waiting for preview to render

---

## Fix

Change from 100 seconds to a reasonable preview duration (1-2 seconds):

```swift
if simulateLoading {
    try await Task.sleep(for: .seconds(2)) // Realistic loading simulation
}
```

---

## Files to Modify

| File | Change |
|------|--------|
| `UsageListView.swift` | Line 259: Change `.seconds(100)` to `.seconds(2)` |

---

## Acceptance Criteria

- [ ] Preview "Loading State" renders within 2-3 seconds
- [ ] Loading animation is visible during the sleep
- [ ] All tests pass
