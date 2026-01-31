# DEBT-052: LogCravingUseCaseTests Uses Non-Deterministic Date()

**Created:** 2026-01-31
**Priority:** P3 (Architecture)
**Status:** Open

## Problem

`LogCravingUseCaseTests` uses `Date()` instead of an injected `Clock`, making tests potentially flaky and not taking advantage of the Clock infrastructure added in DEBT-038.

## Current State

```swift
// Current (non-deterministic)
@Test("Should save valid craving")
func logValidCraving() async throws {
    let mockRepo = MockCravingRepository()
    let useCase = DefaultLogCravingUseCase(repository: mockRepo) // Uses SystemClock

    let result = try await useCase.execute(
        timestamp: Date(), // Non-deterministic!
        intensity: 5,
        // ...
    )
}

@Test("Should reject future timestamp")
func rejectFutureTimestamp() async throws {
    // ...
    _ = try await useCase.execute(
        timestamp: Date().addingTimeInterval(60), // Race condition if clock drifts
        // ...
    )
}
```

## Risk

- Tests could fail intermittently if system clock changes during execution
- Tests are harder to reason about
- Not following the pattern established for time-based testing

## Solution

Update tests to use `FixedClock`:

```swift
private struct FixedClock: Clock, Sendable {
    let fixedNow: Date
    let calendar: Calendar

    init(fixedNow: Date, calendar: Calendar = Calendar(identifier: .gregorian)) {
        self.fixedNow = fixedNow
        self.calendar = calendar
    }

    func now() -> Date { fixedNow }
}

@Test("Should save valid craving")
func logValidCraving() async throws {
    let fixedNow = Date(timeIntervalSince1970: 1_000_000_000)
    let clock = FixedClock(fixedNow: fixedNow)
    let mockRepo = MockCravingRepository()
    let useCase = DefaultLogCravingUseCase(repository: mockRepo, clock: clock)

    let result = try await useCase.execute(
        timestamp: fixedNow.addingTimeInterval(-3600), // 1 hour before "now"
        intensity: 5,
        triggers: ["Anxious", "Bored"],
        notes: "Test note",
        location: "Office"
    )

    #expect(result.intensity == 5)
    #expect(result.createdAt == fixedNow) // Verifiable!
}

@Test("Should reject future timestamp")
func rejectFutureTimestamp() async throws {
    let fixedNow = Date(timeIntervalSince1970: 1_000_000_000)
    let clock = FixedClock(fixedNow: fixedNow)
    let mockRepo = MockCravingRepository()
    let useCase = DefaultLogCravingUseCase(repository: mockRepo, clock: clock)

    await #expect(throws: CravingError.futureTimestamp) {
        try await useCase.execute(
            timestamp: fixedNow.addingTimeInterval(60), // Always future relative to fixedNow
            intensity: 5,
            triggers: [],
            notes: nil,
            location: nil
        )
    }
}
```

## Files to Modify

- `CraveyTests/Domain/UseCases/LogCravingUseCaseTests.swift`

## Verification

```bash
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests/LogCravingUseCaseTests | xcbeautify
```
