# DEBT-019: ChipSelector Fragile Array Indexing Pattern

**Priority:** P3 (Architecture - Code Smell)
**Status:** OPEN
**Created:** 2026-01-28

## Problem

Array index access without proper nil-safety in chip layout calculation.

**File:** `Cravey/Presentation/Views/Components/ChipSelector.swift`

```swift
// Lines 228, 233-234 - UNSAFE
if currentRowWidth + size.width > maxWidth, !rows[rows.count - 1].indices.isEmpty {
    rows[rows.count - 1].indices.append(index)
    rows[rows.count - 1].maxHeight = max(...)
}
```

**Risk:** While `rows` is initialized with one element (line 220), this `[count - 1]` pattern is fragile and error-prone. Future refactoring could introduce bugs. Using `.last` is cleaner and safer.

---

## Files to Modify

| File | Line | Fix |
|------|------|-----|
| `ChipSelector.swift` | 228, 233-234 | Guard `rows.isEmpty` or use `rows.last` |

---

## Recommended Fix

```swift
// Instead of:
rows[rows.count - 1].indices.append(index)

// Use:
guard var lastRow = rows.last else { return }
lastRow.indices.append(index)
rows[rows.count - 1] = lastRow

// Or better - use indices safely:
if let lastIndex = rows.indices.last {
    rows[lastIndex].indices.append(index)
}
```

---

## Acceptance Criteria

- [ ] No `rows[rows.count - 1]` pattern
- [ ] Guard against empty rows array
- [ ] ChipSelector works correctly in all scenarios
- [ ] All UI tests pass
