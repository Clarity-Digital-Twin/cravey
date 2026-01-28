# Technical Debt Tracker

**Last Updated:** 2026-01-28

## Open Debt

| ID | Priority | Description | File |
|----|----------|-------------|------|
| DEBT-017 | P3 | LocationService: Main thread blocking warning. Refactor to delegate-based authorization. | `LocationService.swift` |
| DEBT-022 | P3 | Code duplication in ViewModel error handling. Decision: Accept (see doc). | `CravingLogViewModel`, `UsageLogViewModel` |

## Fixed (Archived)

All resolved DEBT items have been moved to `docs/_archive/debt/`.

| ID | Summary | Archived |
|----|---------|----------|
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

## Priority Definitions

- **P2** - Important. Tests are the safety net; privacy/data hygiene.
- **P3** - Architecture concerns. Pay down incrementally.
- **P4** - Code quality. Fix opportunistically.
