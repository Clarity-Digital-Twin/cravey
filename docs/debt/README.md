# Technical Debt Tracker

**Last Updated:** 2026-01-31

## Open Debt

| ID | Summary | Priority | Status |
|----|---------|----------|--------|

**Total Open Debt Items:** 0

---

## Recent Resolution (2026-01-31)

### Test Suite Overhaul

Resolved DEBT-053 and DEBT-054 in single session:

**Structure fixes:**
- Removed empty `CraveyTests/Data/` folder (Data layer tested via Integration/)
- Created `CraveyTests/Support/` with shared test utilities

**New test files created:**
- `Support/TestConstants.swift` - Eliminates magic numbers per Clean Code
- `Domain/UseCases/LogUsageUseCaseTests.swift` - 10 tests for validation logic
- `Domain/UseCases/FetchUsageUseCaseTests.swift` - 4 tests
- `Domain/Entities/MotivationalMessageEntityTests.swift` - 10 tests for business logic
- `Domain/Entities/RecordingEntityTests.swift` - 16 tests for formatting/business logic

**Test count:** 139 → 174 (+35 tests)

---

## Test Suite Structure

```
CraveyTests/
├── Support/                  # Shared test utilities
│   └── TestConstants.swift   # Time constants, FixedClock, etc.
├── App/                      # DependencyContainer tests
├── Domain/
│   ├── Entities/             # Entity business logic tests
│   ├── Services/             # LocationService tests
│   └── UseCases/             # Use case unit tests
├── Integration/              # Data layer integration tests
│   ├── *RepositoryTests      # Repository implementations
│   ├── MapperTests           # Entity ↔ Model mapping
│   └── *IntegrationTests     # End-to-end flows
└── Presentation/
    ├── Components/           # UI component tests
    ├── Utilities/            # Helper tests
    └── ViewModels/           # ViewModel unit tests
```

**Design Decision:** Data layer (`Cravey/Data/`) is tested via `Integration/` tests with real SwiftData in-memory, not mocked unit tests. This provides better confidence that the actual implementations work correctly.

---

## Summary

**Total Open Debt Items:** 0

**UI Overhaul (2026-01-31):**
- DEBT-055: CravingLogForm + UsageLogForm restructured (Steve Jobs minimal, explicit row breaks)

**Test Coverage Resolution (2026-01-31):**
- DEBT-053: Added TestConstants.swift, eliminated magic numbers
- DEBT-054: Added 35 tests covering LogUsageUseCase, FetchUsageUseCase, MotivationalMessageEntity, RecordingEntity

**Previous Resolution (2026-01-31):** Resolved DEBT-048–052:
- Added 14 tests for CravingEntity, FetchCravingsUseCase, DeleteCravingUseCase, DeleteUsageUseCase
- Refactored LogCravingUseCaseTests for determinism

**Audit (2026-01-30):** Resolved DEBT-045–047

**Previous Resolutions:** See Fixed (Archived) section below.

---

## Fixed (Archived)

All resolved DEBT items are in `docs/_archive/debt/`.

| ID | Summary | Resolved |
| ---- | --------- | ---------- |
| DEBT-055 | CravingLogForm + UsageLogForm UI overhaul | 2026-01-31 |
| DEBT-054 | Test suite structure & coverage gaps | 2026-01-31 |
| DEBT-053 | Test suite magic numbers | 2026-01-31 |
| DEBT-052 | LogCravingUseCaseTests uses deterministic FixedClock | 2026-01-31 |
| DEBT-051 | CravingEntity unit tests added | 2026-01-31 |
| DEBT-050 | FetchCravingsUseCase unit tests added | 2026-01-31 |
| DEBT-049 | DeleteUsageUseCase unit tests added | 2026-01-31 |
| DEBT-048 | DeleteCravingUseCase unit tests added | 2026-01-31 |
| DEBT-047 | Integration tests for MessageRepository + FileStorageManager | 2026-01-30 |
| DEBT-046 | SwiftLint removed from build phase | 2026-01-30 |
| DEBT-045 | Seeding consolidated to App layer only | 2026-01-30 |
| DEBT-044 | RecordingModel `filePath` docs inconsistent | 2026-01-30 |
| DEBT-043 | FileStorageManager unused APIs | 2026-01-30 |
| DEBT-042 | Success toast/banner duplication | 2026-01-30 |
| DEBT-041 | Usage method stringly-typed | 2026-01-30 |
| DEBT-040 | AppConstants layer violation | 2026-01-30 |
| DEBT-039 | LocationService complexity | 2026-01-30 |
| DEBT-038 | Domain uses Date() directly | 2026-01-30 |
| DEBT-037 | AppStartupHandler unused | 2026-01-30 |
| DEBT-029 | RepositoryHelpers | 2026-01-30 |
| DEBT-026 | LocationSelector component | 2026-01-30 |
| DEBT-036 | seedDefaultMessages logs warning | 2026-01-29 |
| DEBT-035 | preconditionFailure documented | 2026-01-29 |
| DEBT-034 | Magic numbers → AppConstants | 2026-01-29 |
| DEBT-033 | AppStartupHandler for error handling | 2026-01-29 |
| DEBT-032 | Preview sleep 100s → 2s | 2026-01-29 |
| DEBT-031 | FormToolbarModifier | 2026-01-29 |
| DEBT-030 | EmptyStateView component | 2026-01-29 |
| DEBT-028 | DeleteConfirmationModifier | 2026-01-29 |
| DEBT-027 | ListViewModel protocol | 2026-01-29 |
| DEBT-025 | FormAlertsModifier | 2026-01-29 |
| DEBT-024 | TimestampWarning protocol | 2026-01-29 |
| DEBT-023 | LocationHandling protocol | 2026-01-29 |
| DEBT-022 | FormSubmission protocol | 2026-01-29 |
| DEBT-017 | LocationService main thread | 2026-01-29 |
| DEBT-021 | Magic numbers → ValidationLimits | 2026-01-28 |
| DEBT-020 | DeleteAllData logs errors | 2026-01-28 |
| DEBT-019 | ChipSelector safe indexing | 2026-01-28 |
| DEBT-018 | DashboardViewModel safe access | 2026-01-28 |
| DEBT-016 | Form labels decluttered | 2026-01-28 |
| DEBT-015 | TimestampPicker default title | 2026-01-28 |
| DEBT-014 | Craving form title simplified | 2026-01-28 |
| DEBT-013 | Log screen nav title removed | 2026-01-28 |
| DEBT-012 | Home screen language | 2026-01-28 |
| DEBT-011 | RecordingRepository.delete | 2026-01-27 |
| DEBT-010 | Home motivation repository-backed | 2026-01-27 |
| DEBT-009 | GPS Current Location | 2026-01-27 |
| DEBT-008 | Consistent notes limit | 2026-01-27 |
| DEBT-007 | UI tests passing | 2026-01-27 |
| DEBT-006 | Semver versioning | 2026-01-27 |
| DEBT-005 | Unused app entrypoint | 2026-01-27 |
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
