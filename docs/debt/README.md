# Technical Debt Tracker

**Last Updated:** 2026-01-28

## Open Debt

### P2 - Important (DRY Violations - High Impact)

| ID | Description | Files Affected | Lines Duplicated |
|----|-------------|----------------|------------------|
| DEBT-023 | Location handling logic duplicated in ViewModels | `CravingLogViewModel`, `UsageLogViewModel` | 54 lines |
| DEBT-024 | Timestamp warning flow duplicated in ViewModels | `CravingLogViewModel`, `UsageLogViewModel` | 40 lines |
| DEBT-025 | Alert patterns duplicated across views (error, timestamp, location) | `CravingLogForm`, `UsageLogForm` | 70+ lines |
| DEBT-026 | Location selector UI duplicated in forms | `CravingLogForm`, `UsageLogForm` | 50 lines |
| DEBT-027 | List ViewModel pattern duplicated | `CravingListViewModel`, `UsageListViewModel` | 60 lines |

### P3 - Architecture (DRY Violations - Medium Impact)

| ID | Description | Files Affected | Lines Duplicated |
|----|-------------|----------------|------------------|
| DEBT-017 | LocationService main thread blocking warning | `LocationService.swift` | N/A |
| DEBT-022 | ViewModel error handling pattern duplicated | `CravingLogViewModel`, `UsageLogViewModel` | 30 lines |
| DEBT-028 | Delete confirmation dialog duplicated | `CravingListView`, `UsageListView` | 42 lines |
| DEBT-029 | Repository boilerplate duplicated | `CravingRepository`, `UsageRepository` | 100+ lines |
| DEBT-030 | Empty state component duplicated | `CravingListView`, `UsageListView` | 48 lines |
| DEBT-031 | Form toolbar pattern duplicated | `CravingLogForm`, `UsageLogForm` | 36 lines |

---

## Summary

**Total Duplicated Code:** ~530+ lines (15-20% of presentation/domain layers)

**Root Cause:** Parallel Craving/Usage features were implemented by copy-paste instead of extracting reusable protocols, base classes, and components.

**Rob C. Martin Approach:**
1. Extract common ViewModel behavior to protocols with default implementations
2. Extract UI patterns to reusable ViewModifiers
3. Create generic base classes for repositories
4. Parameterize UI components instead of duplicating

---

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

---

## Priority Definitions

- **P2** - Important. DRY violations with high impact, tests are the safety net
- **P3** - Architecture concerns. Pay down incrementally
- **P4** - Code quality. Fix opportunistically
