# DEBT-056: UsageLogForm Final Polish

**Created:** 2026-01-31
**Priority:** P4 (Code quality / UX polish)
**Status:** Open

## Summary

Final polish items for UsageLogForm to match CravingLogForm's clean aesthetic. Most work was done in DEBT-055, these are the remaining nits.

## Current State (Post DEBT-055)

```
When                          ← REMOVE (Craving has no header here)
┌─────────────────────────────┐
│ [Jan 31, 2026] [11:54 AM]   │
└─────────────────────────────┘

What & How Much               ← Keep (Usage-specific, provides context)
┌─────────────────────────────┐
│ Method (ROA)                │  ← Already clean
│ [chips wrap correctly]      │
│ Amount                      │
│ [picker]                    │
└─────────────────────────────┘

Triggers                      ← ✅ Already fixed
Location                      ← ✅ Already fixed
Notes                         ← ✅ Already fixed (was "Notes (Optional)")
```

## Changes Required

### 1. Remove "When" Header

**File:** `UsageLogForm.swift` lines 19-23

**Current:**
```swift
Section {
    TimestampPicker(title: nil, date: $viewModel.timestamp)
} header: {
    Text("When")
}
```

**Target:**
```swift
Section {
    TimestampPicker(title: nil, date: $viewModel.timestamp)
}
```

**Rationale:** Match CravingLogForm which has no header on timestamp section. The date/time picker is self-explanatory.

### 2. Remove "(ROA)" from Method Label

**File:** `UsageLogForm.swift` line 31

**Current:**
```swift
SingleSelectChipSelector(
    title: "Method (ROA)",
    ...
)
```

**Target:**
```swift
SingleSelectChipSelector(
    title: "Method",
    ...
)
```

**Rationale:** Steve Jobs minimal. "ROA" is jargon (Route of Administration). "Method" is sufficient - the options (Bowls, Joints, etc.) make it clear what's being asked.

### 2. Decision: Footer Text (OPTIONAL)

The footer "Any additional context or observations" was removed in DEBT-055.

**Options:**
- A) Keep it removed (Steve Jobs minimal) ✅ Current
- B) Add placeholder text inside TextField instead

If user wants hint text, can add later as:
```swift
TextEditor(text: $viewModel.notes)
    .overlay(alignment: .topLeading) {
        if viewModel.notes.isEmpty {
            Text("Any additional context...")
                .foregroundStyle(.tertiary)
                .padding(.top, 8)
                .padding(.leading, 4)
        }
    }
```

## Files to Modify

1. `Cravey/Presentation/Views/Usage/UsageLogForm.swift`

## Verification

1. Open UsageLogForm
2. Verify NO "When" header above timestamp
3. Verify "Notes" section has no "(Optional)"
4. Verify no footer text below Notes
5. Run `scripts/verify.sh` - all tests pass

## Comparison

| Element | CravingLogForm | UsageLogForm (Target) |
|---------|----------------|----------------------|
| Timestamp header | None | None |
| Method/Amount | N/A | "What & How Much" |
| Triggers | "Triggers" | "Triggers" |
| Location | "Location" | "Location" |
| Notes | "Notes" | "Notes" |

## Notes

- ROA chips already wrap correctly (Bowls, Joints, Blunts, Vape, Dab | Edible)
- "What & How Much" header kept because it groups two related inputs (Method + Amount)
- This is the final polish - V0.10 is functional as-is
