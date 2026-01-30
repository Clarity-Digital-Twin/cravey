# DEBT-015: Craving Form "When did this happen?" Label Redundant

**Priority:** P4 (Code Quality)
**Status:** RESOLVED
**Created:** 2026-01-28
**Resolved:** 2026-01-28
**Resolution:** Implemented by changing `TimestampPicker` initializer default to `init(title: String? = nil, ...)`.

## Problem

The timestamp section has a label "When did this happen?" above the date/time pickers. This is unnecessary - date and time pickers are visually obvious.

---

## Files to Modify

### Source Code

| File | Line | Current | New |
| --- | --- | --- | --- |
| `Cravey/Presentation/Views/Components/TimestampPicker.swift` | 9 | `init(title: String? = "When did this happen?", ...)` | `init(title: String? = nil, ...)` |

### Note
The `TimestampPicker` component has an optional title parameter.

**Verified call sites:**
- `CravingLogForm.swift:14` - Uses default (`TimestampPicker(date: $viewModel.timestamp)`) → Will be affected
- `UsageLogForm.swift:20` - Explicitly passes `title: nil` → Already has no label

Changing the default to `nil` only affects CravingLogForm.

---

## Acceptance Criteria

- [x] `TimestampPicker.swift:9` - Default title changed to `nil`
- [x] Verify CravingLogForm doesn't override title
- [x] Verify UsageLogForm doesn't override title
- [x] Date and time pickers remain functional
- [x] All tests pass
