# DEBT-050: Missing FetchCravingsUseCase Unit Tests

**Created:** 2026-01-31
**Priority:** P2 (Important)
**Status:** Open

## Problem

`FetchCravingsUseCase` has no dedicated unit tests. The date-range filtering logic (`execute(from:to:)`) is business logic that should be tested in isolation.

## Current State

- Integration tests fetch via ViewModel
- No unit tests verify date filtering or sorting behavior

## Missing Tests

1. **Date range filtering** - Only cravings within range returned
2. **Sorting order** - Results sorted by timestamp descending
3. **Empty range** - Returns empty array when no matches
4. **Boundary conditions** - Exact start/end date inclusion

## Solution

Add `CraveyTests/Domain/UseCases/FetchCravingsUseCaseTests.swift`:

```swift
@Suite("FetchCravingsUseCase Tests")
struct FetchCravingsUseCaseTests {
    @Test("Should return all cravings sorted by timestamp descending")
    func fetchAllSortedDescending() async throws {
        let mockRepo = MockCravingRepository()
        let now = Date(timeIntervalSince1970: 1_000_000_000)

        let older = CravingEntity(timestamp: now.addingTimeInterval(-3600), intensity: 3)
        let newer = CravingEntity(timestamp: now, intensity: 7)
        await mockRepo.save(older)
        await mockRepo.save(newer)

        let useCase = DefaultFetchCravingsUseCase(repository: mockRepo)
        let result = try await useCase.execute()

        #expect(result.count == 2)
        #expect(result[0].id == newer.id) // Newest first
        #expect(result[1].id == older.id)
    }

    @Test("Should filter by date range")
    func fetchByDateRange() async throws {
        let mockRepo = MockCravingRepository()
        let now = Date(timeIntervalSince1970: 1_000_000_000)

        let inRange = CravingEntity(timestamp: now, intensity: 5)
        let outOfRange = CravingEntity(timestamp: now.addingTimeInterval(-86400 * 10), intensity: 3)
        await mockRepo.save(inRange)
        await mockRepo.save(outOfRange)

        let useCase = DefaultFetchCravingsUseCase(repository: mockRepo)
        let startDate = now.addingTimeInterval(-86400) // 1 day ago
        let endDate = now.addingTimeInterval(86400) // 1 day from now
        let result = try await useCase.execute(from: startDate, to: endDate)

        #expect(result.count == 1)
        #expect(result[0].id == inRange.id)
    }
}
```

## Files to Create/Modify

- Create: `CraveyTests/Domain/UseCases/FetchCravingsUseCaseTests.swift`

## Verification

```bash
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests/FetchCravingsUseCaseTests | xcbeautify
```
