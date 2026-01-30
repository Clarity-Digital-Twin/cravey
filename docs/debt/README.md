# Technical Debt Tracker

**Last Updated:** 2026-01-29

## Open Debt

### P2 - Important (DRY Violations - High Impact)

| ID | Description | Files Affected | Lines Duplicated |
|----|-------------|----------------|------------------|
| DEBT-026 | Location selector UI duplicated in forms | `CravingLogForm`, `UsageLogForm` | 50 lines |
| DEBT-029 | Repository boilerplate duplicated | `CravingRepository`, `UsageRepository` | 100+ lines |

*Note: DEBT-026 and DEBT-029 have reusable components/helpers created but not yet adopted by existing code.*

### P3 - Architecture (Code Quality)

_No open P3 items_

---

## Summary

**Total Open Debt Items:** 2 (0 P1, 2 P2, 0 P3)

**Recent Batch Resolution (2026-01-29):** Resolved 16 debt items including DRY violations in ViewModels, forms, error handling, and magic numbers. Created reusable protocols (`LocationHandling`, `TimestampWarning`, `FormSubmission`, `ListViewModel`), ViewModifiers (`FormAlertsModifier`, `LocationPermissionAlertModifier`, `DeleteConfirmationModifier`, `FormToolbarModifier`), and components (`EmptyStateView`, `LocationSelector`, `RepositoryHelpers`, `AppConstants`).

---

## Fixed (Archived)

All resolved DEBT items have been moved to `docs/_archive/debt/`.

| ID | Summary | Archived |
|----|---------|----------|
| DEBT-036 | seedDefaultMessages logs warning on failure | 2026-01-29 |
| DEBT-035 | preconditionFailure documented as preview-only | 2026-01-29 |
| DEBT-034 | Magic numbers extracted to AppConstants | 2026-01-29 |
| DEBT-033 | AppStartupHandler created for error handling | 2026-01-29 |
| DEBT-032 | Preview sleep reduced to 2 seconds | 2026-01-29 |
| DEBT-031 | FormToolbarModifier created | 2026-01-29 |
| DEBT-030 | EmptyStateView component created | 2026-01-29 |
| DEBT-028 | DeleteConfirmationModifier created | 2026-01-29 |
| DEBT-027 | ListViewModel protocol created | 2026-01-29 |
| DEBT-025 | FormAlertsModifier + LocationPermissionAlertModifier created | 2026-01-29 |
| DEBT-024 | TimestampWarning protocol created | 2026-01-29 |
| DEBT-023 | LocationHandling protocol created | 2026-01-29 |
| DEBT-022 | FormSubmission protocol created | 2026-01-29 |
| DEBT-017 | LocationService main thread blocking fixed | 2026-01-29 |
| DEBT-021 | Magic numbers extracted to ValidationLimits + UIConstants | 2026-01-28 |
| DEBT-020 | DeleteAllData now logs cleanup errors | 2026-01-28 |
| DEBT-019 | ChipSelector safe array indexing with .last | 2026-01-28 |
| DEBT-018 | DashboardViewModel safe array access with .last + zip | 2026-01-28 |
| DEBT-016 | Form labels decluttered, chips centered, triggers/locations updated | 2026-01-28 |
| DEBT-015 | TimestampPicker default title removed | 2026-01-28 |
| DEBT-014 | Craving form title "Log Craving" → "Craving" | 2026-01-28 |
| DEBT-013 | Log screen "Log Entry" nav title removed | 2026-01-28 |
| DEBT-012 | Home screen "My Recovery" → "Overview", "abstinent" → "since last use" | 2026-01-28 |
| DEBT-011 | RecordingRepository.delete removes files | 2026-01-27 |
| DEBT-010 | Home motivation repository-backed | 2026-01-27 |
| DEBT-009 | GPS "Current Location" with CoreLocation | 2026-01-27 |
| DEBT-008 | Consistent notes limit enforcement | 2026-01-27 |
| DEBT-007 | UI tests passing; `--ui` flag added | 2026-01-27 |
| DEBT-006 | Semver versioning in Info.plist template | 2026-01-27 |
| DEBT-005 | Removed unused app entrypoint UI code | 2026-01-27 |
| DEBT-004 | Consistent nowProvider injection | 2026-01-27 |
| DEBT-003 | Shared export file date formatter | 2026-01-27 |
| DEBT-002 | FileStorageManager injectable (no singleton) | 2026-01-27 |
| DEBT-001 | Shared timestamp validation utility | 2026-01-27 |

---

## Priority Definitions

- **P1** - Critical. Bugs, crashes, or development blockers. Fix immediately.
- **P2** - Important. DRY violations with high impact, tests are the safety net
- **P3** - Architecture concerns. Pay down incrementally
- **P4** - Code quality. Fix opportunistically
