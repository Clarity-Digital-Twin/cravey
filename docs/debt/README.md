# Technical Debt Tracker

**Last Updated:** 2026-01-29

## Open Debt

### P2 - Important (Adoption Pending)

| ID | Description | Status | Notes |
|----|-------------|--------|-------|
| DEBT-026 | Location selector UI duplicated in forms | Component created | `LocationSelector` exists but forms not yet updated to use it |
| DEBT-029 | Repository boilerplate duplicated | Helpers created | `RepositoryHelpers` exists but repos not yet refactored |

*These items have reusable code created but require adoption by existing views/repositories.*

---

## Summary

**Total Open Debt Items:** 2 (both have solutions created, just need adoption)

**Recent Batch Resolution (2026-01-29):** Resolved 14 debt items:
- **Protocols created + adopted:** LocationHandling, TimestampWarning, FormSubmission (ViewModels refactored)
- **Modifiers created:** FormAlertsModifier, LocationPermissionAlertModifier, DeleteConfirmationModifier, FormToolbarModifier
- **Components created:** EmptyStateView, LocationSelector, RepositoryHelpers
- **Infrastructure:** AppConstants, AppStartupHandler
- **Fixes:** Preview sleep (100s→2s), LocationService background thread, seedDefaultMessages warning log

---

## Fixed (Archived)

All resolved DEBT items are in `docs/_archive/debt/`.

| ID | Summary | Resolved |
|----|---------|----------|
| DEBT-036 | seedDefaultMessages logs warning on failure | 2026-01-29 |
| DEBT-035 | preconditionFailure documented as preview-only | 2026-01-29 |
| DEBT-034 | Magic numbers → AppConstants | 2026-01-29 |
| DEBT-033 | AppStartupHandler for error handling | 2026-01-29 |
| DEBT-032 | Preview sleep 100s → 2s | 2026-01-29 |
| DEBT-031 | FormToolbarModifier | 2026-01-29 |
| DEBT-030 | EmptyStateView component | 2026-01-29 |
| DEBT-028 | DeleteConfirmationModifier | 2026-01-29 |
| DEBT-027 | ListViewModel protocol | 2026-01-29 |
| DEBT-025 | FormAlertsModifier + LocationPermissionAlertModifier | 2026-01-29 |
| DEBT-024 | TimestampWarning protocol (adopted) | 2026-01-29 |
| DEBT-023 | LocationHandling protocol (adopted) | 2026-01-29 |
| DEBT-022 | FormSubmission protocol (adopted) | 2026-01-29 |
| DEBT-017 | LocationService main thread → Task.detached | 2026-01-29 |
| DEBT-021 | Magic numbers → ValidationLimits + UIConstants | 2026-01-28 |
| DEBT-020 | DeleteAllData logs cleanup errors | 2026-01-28 |
| DEBT-019 | ChipSelector safe array indexing | 2026-01-28 |
| DEBT-018 | DashboardViewModel safe array access | 2026-01-28 |
| DEBT-016 | Form labels decluttered | 2026-01-28 |
| DEBT-015 | TimestampPicker default title removed | 2026-01-28 |
| DEBT-014 | Craving form title simplified | 2026-01-28 |
| DEBT-013 | Log screen nav title removed | 2026-01-28 |
| DEBT-012 | Home screen language improvements | 2026-01-28 |
| DEBT-011 | RecordingRepository.delete removes files | 2026-01-27 |
| DEBT-010 | Home motivation repository-backed | 2026-01-27 |
| DEBT-009 | GPS Current Location | 2026-01-27 |
| DEBT-008 | Consistent notes limit | 2026-01-27 |
| DEBT-007 | UI tests passing | 2026-01-27 |
| DEBT-006 | Semver versioning | 2026-01-27 |
| DEBT-005 | Unused app entrypoint removed | 2026-01-27 |
| DEBT-004 | Consistent nowProvider | 2026-01-27 |
| DEBT-003 | Shared date formatter | 2026-01-27 |
| DEBT-002 | FileStorageManager injectable | 2026-01-27 |
| DEBT-001 | Shared timestamp validation | 2026-01-27 |

---

## Priority Definitions

- **P1** - Critical. Bugs, crashes, development blockers
- **P2** - Important. DRY violations, maintainability issues
- **P3** - Architecture. Pay down incrementally
- **P4** - Code quality. Fix opportunistically
