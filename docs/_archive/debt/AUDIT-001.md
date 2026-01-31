# Test Suite & Code Quality Audit

**Created:** 2026-01-31
**Status:** Open
**Priority:** P2-P3 (Important but not blocking)

---

## Executive Summary

**121 unit tests passing, 22 UI tests optional.**

The test suite is solid for a pre-release app. The codebase follows Clean Architecture properly with good separation of concerns. However, there are coverage gaps and test quality issues that Uncle Bob would flag.

---

## Audit Findings

### 1. GOOD: Test Structure Follows Best Practices

✅ **Unit tests use mocks correctly** - Domain use cases test business logic with mock repositories
✅ **Integration tests use real SwiftData** - In-memory containers test full stack
✅ **Mocks are actors** - Swift 6 concurrency-safe
✅ **Tests are deterministic** - `nowProvider` / `Clock` injection enables time-based testing
✅ **Error paths tested** - Failure scenarios covered for most flows

### 2. COVERAGE GAPS (P2)

| Gap | Impact | Recommendation |
|-----|--------|----------------|
| **No unit tests for DeleteCravingUseCase** | Use case logic untested | Add 2-3 tests for validation |
| **No unit tests for DeleteUsageUseCase** | Use case logic untested | Add 2-3 tests for validation |
| **No unit tests for FetchCravingsUseCase** | Business logic (sorting, filtering) untested | Add date-range filtering tests |
| **No unit tests for FetchUsageUseCase** | Business logic untested | Add since-date filtering tests |
| **Clock injection missing in tests** | LogCravingUseCaseTests uses `Date()` not injected clock | Test determinism risk |
| **No CravingEntity/UsageEntity unit tests** | Entity helper methods (`isWithinLast`) untested | Add entity unit tests |

**Specific Missing Tests:**
1. `DeleteCravingUseCase` - What happens when ID doesn't exist?
2. `DeleteUsageUseCase` - Same gap
3. `FetchCravingsUseCase.execute(from:to:)` - Date filtering logic untested
4. `FetchUsageUseCase.execute(since:)` - Date filtering logic untested
5. `CravingEntity.isWithinLast(_:now:)` - DEBT-038 added `now` param but no unit test

### 3. WEAK TESTS (P3)

| Test | Problem | Fix |
|------|---------|-----|
| `LogCravingUseCaseTests.logValidCraving` | Uses `Date()` instead of fixed clock | Inject `FixedClock` for determinism |
| `LogCravingUseCaseTests.rejectFutureTimestamp` | Uses `Date().addingTimeInterval(60)` - flaky if clock drift | Use injected clock |
| `UsageDataLayerTests.allROAMethods` | Uses hardcoded `["Bowls", "Joints"...]` instead of `UsageMethod.allCases` | Use single source of truth |
| `CravingLogViewModelTests.cancellingGPSRequestClearsLoadingState` | Relies on `HangingLocationService` sleeping 5s | Timeout-dependent, slow |

### 4. MOCK DUPLICATION (P4)

Multiple test files define the same mocks:
- `MockCravingRepository` in 3 files
- `MockUsageRepository` in 2 files
- `MockMessageRepository` in 3 files

**Recommendation:** Create `CraveyTests/Mocks/` directory with shared mocks.

### 5. MISSING EDGE CASES (P2)

**LogCravingUseCase:**
- ✅ Invalid intensity (>10) tested
- ❌ Invalid intensity (<1) NOT tested
- ❌ Empty triggers array boundary NOT tested
- ❌ Null vs empty notes distinction NOT tested

**LogUsageUseCase:**
- ✅ Invalid method tested
- ✅ Zero amount tested
- ❌ Negative amount NOT tested
- ✅ Amount out of range tested
- ❌ Boundary values (exact min/max per method) NOT tested

**DashboardViewModel:**
- ✅ Streak calculation tested
- ❌ Edge case: No data (empty arrays) NOT tested
- ❌ Edge case: Only today's data NOT tested
- ❌ Edge case: Gap in streaks NOT tested

### 6. ARCHITECTURAL VIOLATIONS (None Critical)

✅ Domain layer clean - no SwiftUI/SwiftData imports
✅ Presentation layer clean - no ModelContext references
✅ Repository pattern properly implemented
✅ Use case injection throughout

**Minor concern:** Two test files have stale `seedDefaultMessagesIfNeeded` mock methods that don't match current protocol (protocol method was removed per DEBT-045):
- `ExportUserDataUseCaseTests.swift:168`
- `MarkMessageShownUseCaseTests.swift:120`

Tests still pass because Swift doesn't require removing extra methods from protocol conforming types.

### 7. OVER-MOCKING CONCERNS (P3)

**SettingsViewModelTests** - Tests mock both export AND delete use cases. This is correct for unit tests, but there's **no integration test for Settings flow end-to-end**.

**HomeMotivationViewModelTests** - Well-structured, but message selection algorithm (dayOfYear-based) is NOT tested. The mock just returns whatever you give it.

---

## Recommended Actions

### Immediate (P2)

1. **Add DeleteCravingUseCase unit tests**
   - Test: ID not found throws error
   - Test: Successful deletion returns void
   - Test: Repository error propagates correctly

2. **Add DeleteUsageUseCase unit tests**
   - Same as above

3. **Add FetchCravingsUseCase unit tests**
   - Test: Date range filtering works correctly
   - Test: Results sorted by timestamp descending
   - Test: Empty date range returns empty array

4. **Add CravingEntity unit tests**
   - Test: `isWithinLast(24, now: fixedDate)` with various timestamps
   - Test: Boundary conditions (exactly 24h ago)

5. **Fix LogCravingUseCaseTests to use injected Clock**
   ```swift
   @Test("Should save valid craving")
   func logValidCraving() async throws {
       let fixedNow = Date(timeIntervalSince1970: 1_000_000_000)
       let clock = FixedClock(fixedNow: fixedNow)
       let mockRepo = MockCravingRepository()
       let useCase = DefaultLogCravingUseCase(repository: mockRepo, clock: clock)
       // ...
   }
   ```

### Soon (P3)

6. **Consolidate mocks into shared test utilities**
   - Create `CraveyTests/Mocks/MockRepositories.swift`
   - Import in test files that need them

7. **Add missing edge case tests**
   - Intensity = 0 (below minimum)
   - Negative amount for usage
   - Empty string notes vs nil notes

8. **Add SelectMotivationalMessageUseCase algorithm test**
   - Verify dayOfYear rotation works as expected
   - Test tiebreaker logic (timesShown)

### Later (P4)

9. **Add Settings integration test**
   - Test export writes real file to temp directory
   - Test delete actually removes data from SwiftData

10. **Remove stale mock methods**
    - `seedDefaultMessagesIfNeeded` in `ExportUserDataUseCaseTests.MockMessageRepository`
    - `seedDefaultMessagesIfNeeded` in `MarkMessageShownUseCaseTests.MarkMessageMockRepository`

---

## Test Count Summary

| Category | Count | Notes |
|----------|-------|-------|
| Domain Use Case Unit Tests | 11 | Missing: Delete/Fetch use cases |
| Domain Entity Unit Tests | 17 | UsageMethod only; CravingEntity/UsageEntity missing |
| Presentation ViewModel Tests | 35 | Good coverage |
| Presentation Component Tests | 7 | IntensitySlider, ROAPicker covered |
| Integration Tests | 42 | Strong end-to-end coverage |
| App Bootstrap Tests | 1 | DependencyContainer startup |
| **Total Unit Tests** | **121** | Passing |
| UI Tests (optional) | 22 | XCTest-based |

---

## Clean Architecture Compliance

| Layer | Status | Notes |
|-------|--------|-------|
| **Domain** | ✅ Clean | No framework imports |
| **Data** | ✅ Clean | Implements protocols, no UI |
| **Presentation** | ✅ Clean | Uses use cases, no SwiftData |
| **App** | ✅ Clean | Composition root only |

**Uncle Bob would approve** of the layer separation. The gaps are in test coverage, not architecture.

---

## Next Steps

1. Create individual debt items for P2 gaps
2. Prioritize based on risk (Delete/Fetch use cases are higher risk)
3. Add tests incrementally, don't block features

