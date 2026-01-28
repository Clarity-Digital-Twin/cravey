# DEBT-014: Craving Form Title "Log Craving" → "Craving"

**Priority:** P4 (Code Quality)
**Status:** OPEN
**Created:** 2026-01-28

## Problem

The Craving form navigation title says "Log Craving" which is redundant:
- User just tapped "Log Craving" to get here
- The action of logging is self-apparent from context

---

## Files to Modify

### Source Code

| File | Line | Current | New |
|------|------|---------|-----|
| `Cravey/Presentation/Views/Craving/CravingLogForm.swift` | 84 | `.navigationTitle("Log Craving")` | `.navigationTitle("Craving")` |

### UI Tests

| File | Line | Current | New |
|------|------|---------|-----|
| `CraveyUITests/Screens/CravingFormScreen.swift` | 9 | `app.navigationBars["Log Craving"]` | `app.navigationBars["Craving"]` |

### Note: Keep These Unchanged
These reference the **button text** on LogView, not the form title:
- `LogView.swift:30` - `title: "Log Craving"` (button label - keep as is)
- `LogScreen.swift:8,27,29,59,60` - References to "Log Craving" button (keep as is)

---

## Acceptance Criteria

- [ ] `CravingLogForm.swift:84` - Title changed to "Craving"
- [ ] `CravingFormScreen.swift:9` - UI test updated
- [ ] All tests pass
