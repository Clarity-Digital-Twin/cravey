# DEBT-018: DashboardViewModel Array Index Without Bounds Checking

**Priority:** P2 (Important - Potential Crash)
**Status:** RESOLVED
**Created:** 2026-01-28
**Resolved:** 2026-01-28
**Resolution:** Fixed in `DashboardViewModel.calculateStreaks()` by replacing unsafe indexing with a max-by-timestamp lookup and `zip` iteration over consecutive elements.

## Problem

Direct array indexing without bounds validation in `calculateStreaks()` method.

**File:** `Cravey/Presentation/ViewModels/DashboardViewModel.swift`

```swift
// Line 113 - UNSAFE
let lastUsage = sortedUsages[sortedUsages.count - 1]

// Lines 119-120 - UNSAFE
let current = sortedUsages[idx].timestamp
let next = sortedUsages[idx + 1].timestamp
```

**Risk:** Potential crash if:
- Array is mutated between guard check and access
- Loop bounds are off-by-one

---

## Files to Modify

| File | Line | Current | Fix |
| --- | --- | --- | --- |
| `DashboardViewModel.swift` | 113 | `sortedUsages[sortedUsages.count - 1]` | `sortedUsages.last!` or guard with `.last` |
| `DashboardViewModel.swift` | 119-120 | Direct indexing in loop | Use `zip(sortedUsages, sortedUsages.dropFirst())` pattern |

---

## Recommended Fix

```swift
// Instead of:
let lastUsage = sortedUsages[sortedUsages.count - 1]

// Use:
guard let lastUsage = sortedUsages.last else { return }

// Instead of loop with idx and idx+1:
for (current, next) in zip(sortedUsages, sortedUsages.dropFirst()) {
    // Safe iteration over consecutive pairs
}
```

---

## Acceptance Criteria

- [x] No direct array indexing with computed indices
- [x] Use a safe last-usage lookup (`.last`/`.max`) instead of `[count - 1]`
- [x] Use `zip` pattern for consecutive element iteration
- [x] All dashboard tests pass
