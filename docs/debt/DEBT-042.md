# DEBT-042: Success toast/banner logic is duplicated; broad catch hides intent

**Priority:** P4 (Code quality / duplication)
**Status:** OPEN
**Created:** 2026-01-30

## Problem

Success toast/banner logic is implemented multiple times with similar patterns:

- Overlay UI
- Animate in/out
- `Task.sleep` to auto-dismiss
- `catch { /* ignore */ }` that is broader than necessary

This is duplicated in at least:

- `Cravey/Presentation/Views/Log/LogView.swift`
- `Cravey/Presentation/Views/Settings/SettingsView.swift`

## Why This Is Bad

- **Duplication:** Every UX tweak requires editing multiple call sites.
- **Intent unclear:** A broad `catch` reads like “ignore all errors”, even though only cancellation is expected.

## Proposed Fix

- Create a small reusable component/modifier, e.g. `ToastBanner`:
  - takes `systemImage`, `text`, and `Binding<Bool>` for presentation
  - owns the auto-dismiss `Task.sleep`
  - catches `CancellationError` explicitly (no broad catch)
- Replace duplicated overlay logic in Log + Settings with the component.

## Acceptance Criteria

- [ ] One reusable toast/banner implementation.
- [ ] Call sites only configure content, not timing/task logic.
- [ ] Cancellation is caught explicitly (no broad `catch`).

