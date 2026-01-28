# DEBT-008: Notes Character Limit Enforcement Inconsistency

**Priority:** P4 (Code Quality)
**Status:** FIXED
**Created:** 2026-01-27
**Fixed:** 2026-01-27

## Problem

Notes field character limit (500 chars) is enforced differently between forms:

### UsageLogViewModel (lines 26-32)
```swift
var notes: String = "" {
    didSet {
        // Enforce 500 char limit (DATA_MODEL_SPEC:122, UX_FLOW:391)
        if notes.count > 500 {
            notes = String(notes.prefix(500))
        }
    }
}
```
**Behavior:** Auto-truncates silently. User can keep typing but excess is trimmed.

### CravingLogViewModel (lines 48-52)
```swift
func logCraving() async {
    // Validate notes length (500 char limit per DATA_MODEL_SPEC.md:275)
    if notes.count > 500 {
        errorMessage = "Notes cannot exceed 500 characters"
        return
    }
    // ...
}
```
**Behavior:** Shows error on submit. User must manually delete excess.

## Impact

- Inconsistent UX between Craving and Usage forms
- User confusion: "Why can I type past 500 in one form but not the other?"

## Options

### Option A: Auto-Truncate Both (Recommended)
- Less disruptive UX
- Matches standard iOS text field behavior
- User sees character count, knows limit

### Option B: Error on Submit Both
- More explicit feedback
- Forces user awareness
- Can feel punitive

### Option C: Block Input at Limit
- Most restrictive
- Requires custom TextField wrapper
- Clearest feedback but may feel "broken"

## Recommended Fix

Apply UsageLogViewModel pattern to CravingLogViewModel:
```swift
var notes: String = "" {
    didSet {
        if notes.count > 500 {
            notes = String(notes.prefix(500))
        }
    }
}
```

Remove the validation check in `logCraving()` (Domain layer already validates).

## Acceptance Criteria

- [x] Both forms handle notes limit identically (auto-truncate at 500)
- [x] Character counter appears at 400+ chars in both forms
- [x] Unit tests cover limit enforcement
