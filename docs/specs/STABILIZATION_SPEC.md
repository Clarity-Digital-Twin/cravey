# Stabilization Specification

**Version:** 1.0
**Status:** ✅ COMPLETED (2026-01-26)
**Goal:** Keep the existing features robust before adding anything new

---

## Current State (What Exists)

### Working Features
| Feature | Files | Status |
|---------|-------|--------|
| Craving Logging | CravingLogForm, CravingLogViewModel | Works |
| Usage Logging | UsageLogForm, UsageLogViewModel | Works |
| Dashboard | DashboardView, DashboardViewModel | Works but has bugs |
| Settings | SettingsView, SettingsViewModel | Works |
| Home Screen | HomeView, lists | Works |

### Known Issues

Stabilization work is tracked in the bug and debt trackers:
- `docs/bugs/`
- `docs/debt/`

---

## What NOT to Do

1. ❌ Add new features (recordings, onboarding)
2. ❌ Refactor architecture
3. ❌ Add new dependencies
4. ❌ Change data models
5. ❌ "Improve" working code

---

## Acceptance Criteria

### Must Have (Stabilization Complete)
- [x] `bash scripts/verify.sh` exits 0
- [x] `xcodebuild build` succeeds (validated by verify gate via iOS Simulator compile check)
- [x] All unit/integration tests pass (`CraveyTests`, 42 tests)

### Nice to Have
- [ ] UI Tests included in the convergence gate (currently out-of-scope for headless CI)

---

## File Audit Checklist

Run this to validate the current stabilization gate:
```bash
bash scripts/verify.sh
```

---

## Implementation Order

1. Fix DashboardView.swift concurrency bugs (P0)
2. Run full test suite, verify nothing broke
3. (Optional) Fix trailing commas via swiftformat
4. Commit with clear message
