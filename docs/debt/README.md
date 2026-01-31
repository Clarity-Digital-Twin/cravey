# Technical Debt Tracker

**Last Updated:** 2026-01-30

## Open Debt

_None._

---

## Summary

**Total Open Debt Items:** 0 🎉

**Audit (2026-01-30):** Resolved DEBT-045, DEBT-046, DEBT-047:
- DEBT-045: Removed seeding from Domain layer (now App-only)
- DEBT-046: Removed SwiftLint from build phase (verify.sh is the gate)
- DEBT-047: Added 11 integration tests for MessageRepository + FileStorageManager

**Previous Audit (2026-01-30):** Added items DEBT-037 through DEBT-044 and resolved them.

**Recent Resolutions (2026-01-30):** Resolved 13 items total:
- **DEBT-037–047:** See `docs/_archive/debt/`
- **DEBT-026:** `LocationSelector` component adopted in both forms (~60 lines removed)
- **DEBT-029:** `RepositoryHelpers` available for future use (opt-in helpers, no mandatory refactoring)

**Previous Batch Resolution (2026-01-29):** Resolved 14 debt items:
- **Protocols created + adopted:** LocationHandling, TimestampWarning, FormSubmission (ViewModels refactored)
- **Modifiers created:** FormAlertsModifier, LocationPermissionAlertModifier, DeleteConfirmationModifier, FormToolbarModifier
- **Components created:** EmptyStateView, LocationSelector, RepositoryHelpers
- **Infrastructure:** AppConstants, AppStartupHandler
- **Fixes:** Preview sleep (100s→2s), LocationService background thread, seedDefaultMessages warning log

---

## Fixed (Archived)

All resolved DEBT items are in `docs/_archive/debt/`.

| ID | Summary | Resolved |
| ---- | --------- | ---------- |
| DEBT-047 | Integration tests for MessageRepository + FileStorageManager | 2026-01-30 |
| DEBT-046 | SwiftLint removed from build phase | 2026-01-30 |
| DEBT-045 | Seeding consolidated to App layer only | 2026-01-30 |
| DEBT-044 | RecordingModel `filePath` docs inconsistent (AGENTS/CLAUDE vs code) | 2026-01-30 |
| DEBT-043 | FileStorageManager unused APIs + temp cleanup semantics | 2026-01-30 |
| DEBT-042 | Success toast/banner duplication + broad catch | 2026-01-30 |
| DEBT-041 | Usage method is stringly-typed + duplicated across layers | 2026-01-30 |
| DEBT-040 | AppConstants contains non-Presentation infra config | 2026-01-30 |
| DEBT-039 | LocationService polling + cancellation mapping + complexity | 2026-01-30 |
| DEBT-038 | Domain uses `Date()` / `Calendar.current` directly | 2026-01-30 |
| DEBT-037 | AppStartupHandler unused; CraveyApp startup logic duplicated | 2026-01-30 |
| DEBT-029 | RepositoryHelpers for DRY repository code | 2026-01-30 |
| DEBT-026 | LocationSelector component adopted in forms | 2026-01-30 |
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
