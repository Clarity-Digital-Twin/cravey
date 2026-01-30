# DEBT-012: Home Screen Copy Assumes Abstinence Goal

**Priority:** P4 (Code Quality)
**Status:** RESOLVED
**Created:** 2026-01-28
**Resolved:** 2026-01-28

## Problem

The Home screen has copy that assumes the user's goal is full abstinence, excluding harm reduction users.

### Issue 1: Navigation Title "My Recovery"
- "Recovery" implies abstinence-based goal
- "My" sounds cheap/casual
- Left-aligned looks unbalanced

### Issue 2: Hero Card Says "abstinent"
- "22 DAYS abstinent" doesn't apply to harm reduction users
- Assumes binary quit/not-quit mentality

---

## Files to Modify

### Source Code

| File | Line | Current | New |
| --- | --- | --- | --- |
| `Cravey/Presentation/Views/Home/HomeView.swift` | 52 | `.navigationTitle("My Recovery")` | `.navigationTitle("Overview")` + `.navigationBarTitleDisplayMode(.inline)` |
| `Cravey/Presentation/Views/Home/HomeView.swift` | 89 | `Text("abstinent")` | `Text("since last use")` |

### UI Tests

| File | Line | Current | New |
| --- | --- | --- | --- |
| `CraveyUITests/Screens/HomeScreen.swift` | 8 | `/// Navigation bar with "My Recovery" title` | `/// Navigation bar with "Overview" title` |
| `CraveyUITests/Screens/HomeScreen.swift` | 10 | `app.navigationBars["My Recovery"]` | `app.navigationBars["Overview"]` |

### Docs (Informational - Update if desired)
- `docs/brainstorming/HOME_SCREEN_REDESIGN.md:67`
- `docs/specs/UI_REDESIGN_SPEC.md:187,213`

---

## Acceptance Criteria

- [x] `HomeView.swift:52` - Title changed to "Overview", centered
- [x] `HomeView.swift:89` - "abstinent" changed to "since last use"
- [x] `HomeScreen.swift:8,10` - UI test updated
- [x] All tests pass
