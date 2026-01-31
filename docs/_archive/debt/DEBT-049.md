# DEBT-049: Missing DeleteUsageUseCase Unit Tests

**Created:** 2026-01-31
**Resolved:** 2026-01-31
**Priority:** P2 (Important)
**Status:** ✅ RESOLVED

## Resolution

- Added `CraveyTests/Domain/UseCases/DeleteUsageUseCaseTests.swift`.

## Problem

`DeleteUsageUseCase` has no dedicated unit tests. Same gap as DEBT-048 but for usage deletion.

## Current State

- `UsageListViewModelTests` tests delete via ViewModel (mock use case)
- No tests verify the actual `DefaultDeleteUsageUseCase` implementation

## Missing Tests

1. **Delete non-existent ID** - Should throw error
2. **Successful delete** - Should call repository.delete
3. **Repository error propagates** - Should re-throw repository errors

## Solution

Add `CraveyTests/Domain/UseCases/DeleteUsageUseCaseTests.swift`:

```swift
@Suite("DeleteUsageUseCase Tests")
struct DeleteUsageUseCaseTests {
    @Test("Should delete existing usage")
    func deleteExistingUsage() async throws {
        let mockRepo = MockUsageRepository()
        let usage = UsageEntity(timestamp: Date(), method: "Bowls", amount: 1.0)
        await mockRepo.save(usage)

        let useCase = DefaultDeleteUsageUseCase(repository: mockRepo)
        try await useCase.execute(id: usage.id)

        let remaining = try await mockRepo.fetchAll()
        #expect(remaining.isEmpty)
    }

    @Test("Should propagate repository errors")
    func propagatesErrors() async throws {
        let mockRepo = ThrowingUsageRepository()
        let useCase = DefaultDeleteUsageUseCase(repository: mockRepo)

        await #expect(throws: (any Error).self) {
            try await useCase.execute(id: UUID())
        }
    }
}
```

## Files to Create/Modify

- Create: `CraveyTests/Domain/UseCases/DeleteUsageUseCaseTests.swift`

## Verification

```bash
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests/DeleteUsageUseCaseTests | xcbeautify
```
