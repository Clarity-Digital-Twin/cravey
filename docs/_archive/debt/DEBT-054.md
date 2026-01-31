# DEBT-054: Test Suite Structure & Coverage Gaps

**Created:** 2026-01-31
**Priority:** P2 (Important - maintainability)
**Status:** Open

## Problem

Test suite has structural gaps and missing unit tests for files with business logic.

## Audit Results

### 1. Folder Structure Gaps

| Source Path | Test Path | Status |
|-------------|-----------|--------|
| `App/` | `App/` | ✅ Exists |
| `Data/` | `Data/` | ❌ Empty folder |
| `Domain/Entities/` | `Domain/Entities/` | ✅ Exists |
| `Domain/Services/` | `Domain/Services/` | ✅ Exists |
| `Domain/UseCases/` | `Domain/UseCases/` | ✅ Exists |
| `Presentation/ViewModels/` | `Presentation/ViewModels/` | ✅ Exists |
| `Presentation/Components/` | `Presentation/Components/` | ✅ Exists |
| `Presentation/Utilities/` | `Presentation/Utilities/` | ✅ Exists |

**Issue:** `CraveyTests/Data/` exists but is empty. Either populate it or delete it.

### 2. Missing Unit Tests (Files with Business Logic)

#### Domain/UseCases (CRITICAL)

| File | Has Test? | Business Logic |
|------|-----------|----------------|
| `LogUsageUseCase.swift` | ❌ NO | 6 validation rules, error handling |
| `FetchUsageUseCase.swift` | ❌ NO | Simple passthrough (low priority) |

**LogUsageUseCase** validates:
- Method must be valid ROA
- Amount > 0
- Timestamp not in future
- Amount within method's valid range
- Notes ≤ 500 chars

This is as complex as `LogCravingUseCase` (which HAS tests). **Must add tests.**

#### Domain/Entities (MEDIUM)

| File | Has Test? | Business Logic |
|------|-----------|----------------|
| `MotivationalMessageEntity.swift` | ❌ NO | `markAsShown()` method |
| `RecordingEntity.swift` | ❌ NO | `durationFormatted`, `incrementPlayCount()` |
| `UsageEntity.swift` | ❌ NO | No business logic (data only) |
| `TriggerOptions.swift` | ❌ NO | Static data (no test needed) |

### 3. Acceptably Covered by Integration Tests

| Source File | Integration Test |
|-------------|------------------|
| `Data/Mappers/*.swift` | `MapperCompatibilityTests.swift` |
| `Data/Repositories/*.swift` | Various integration tests |
| `Data/Storage/FileStorageManager.swift` | `FileStorageManagerTests.swift` |
| `Data/UseCases/SwiftDataDeleteAllUserDataUseCase.swift` | `DeleteAllUserDataUseCaseTests.swift` |

### 4. Files That Don't Need Tests

| File | Reason |
|------|--------|
| `Domain/Protocols/*.swift` | Interfaces only |
| `Domain/Repositories/*.swift` | Protocols only |
| `Presentation/Protocols/*.swift` | Interfaces only |
| `Presentation/Constants/*.swift` | Static values |
| `Domain/Entities/ValidationLimits.swift` | Static values |
| `Presentation/Views/*.swift` | UI (covered by UI tests) |

## Fix Plan

### Phase 1: Structure Cleanup
- Delete empty `CraveyTests/Data/` folder (integration tests cover Data layer)

### Phase 2: Critical Missing Tests
- Add `LogUsageUseCaseTests.swift` (mirrors LogCravingUseCaseTests)
- Add `FetchUsageUseCaseTests.swift` (mirrors FetchCravingsUseCaseTests)

### Phase 3: Entity Tests
- Add `MotivationalMessageEntityTests.swift` (test `markAsShown()`)
- Add `RecordingEntityTests.swift` (test `durationFormatted`, `incrementPlayCount()`)

## Files to Create

1. `CraveyTests/Domain/UseCases/LogUsageUseCaseTests.swift`
2. `CraveyTests/Domain/UseCases/FetchUsageUseCaseTests.swift`
3. `CraveyTests/Domain/Entities/MotivationalMessageEntityTests.swift`
4. `CraveyTests/Domain/Entities/RecordingEntityTests.swift`

## Expected Test Count After Fix

Current: 139 unit tests
After: ~155 unit tests (+16 estimated)
