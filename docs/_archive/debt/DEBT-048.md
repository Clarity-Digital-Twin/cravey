# DEBT-048: Missing DeleteCravingUseCase Unit Tests

**Created:** 2026-01-31
**Priority:** P2 (Important)
**Status:** Open

## Problem

`DeleteCravingUseCase` has no dedicated unit tests. The use case is used via `CravingListViewModel` but its direct behavior (error handling, edge cases) is untested.

## Current State

- `CravingListViewModelTests` tests delete via ViewModel (mock use case)
- No tests verify the actual `DefaultDeleteCravingUseCase` implementation

## Missing Tests

1. **Delete non-existent ID** - Should throw error
2. **Successful delete** - Should call repository.delete
3. **Repository error propagates** - Should re-throw repository errors

## Solution

Add `CraveyTests/Domain/UseCases/DeleteCravingUseCaseTests.swift`:

```swift
@Suite("DeleteCravingUseCase Tests")
struct DeleteCravingUseCaseTests {
    @Test("Should delete existing craving")
    func deleteExistingCraving() async throws {
        let mockRepo = MockCravingRepository()
        let craving = CravingEntity(timestamp: Date(), intensity: 5)
        await mockRepo.save(craving)

        let useCase = DefaultDeleteCravingUseCase(repository: mockRepo)
        try await useCase.execute(id: craving.id)

        let remaining = try await mockRepo.fetchAll()
        #expect(remaining.isEmpty)
    }

    @Test("Should propagate repository errors")
    func propagatesErrors() async throws {
        let mockRepo = ThrowingCravingRepository()
        let useCase = DefaultDeleteCravingUseCase(repository: mockRepo)

        await #expect(throws: (any Error).self) {
            try await useCase.execute(id: UUID())
        }
    }
}
```

## Files to Create/Modify

- Create: `CraveyTests/Domain/UseCases/DeleteCravingUseCaseTests.swift`

## Verification

```bash
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests/DeleteCravingUseCaseTests | xcbeautify
```
