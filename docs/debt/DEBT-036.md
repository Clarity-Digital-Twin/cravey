# DEBT-036: Silent Failure in seedDefaultMessages Swallows All Errors

**Priority:** P3 (Architecture - Silent Exception)
**Status:** OPEN
**Created:** 2026-01-29

## Problem

`ModelContainerSetup.seedDefaultMessages()` has an overly broad `catch` block that silently swallows all errors. The app continues running with **no motivational messages** and the user is never informed.

---

## Location

**File:** `Cravey/Data/Storage/ModelContainerSetup.swift`
**Lines:** 83-99

```swift
@MainActor
static func seedDefaultMessages(context: ModelContext) {
    do {
        let descriptor = FetchDescriptor<MotivationalMessageModel>()
        let existingMessages = try context.fetch(descriptor)

        guard existingMessages.isEmpty else { return }

        for message in MotivationalMessageEntity.defaultMessages {
            let model = MessageMapper.toModel(message)
            context.insert(model)
        }

        try context.save()
    } catch {
        logger.error("Failed to seed default messages: \(error.localizedDescription)")
        // SILENT FAILURE - app continues with empty messages
    }
}
```

---

## Why This Is Bad

1. **User doesn't know** - The app works but motivational messages are missing
2. **Debugging nightmare** - Error is logged but buried in console
3. **No distinction** - Treats cancellation the same as database corruption
4. **Violates fail-fast** - Rob C. Martin would say: "If you can't recover, fail loudly"

---

## Rob C. Martin Fix: Distinguish Error Types

```swift
@MainActor
static func seedDefaultMessages(context: ModelContext) throws {
    let descriptor = FetchDescriptor<MotivationalMessageModel>()
    let existingMessages = try context.fetch(descriptor)

    guard existingMessages.isEmpty else { return }

    for message in MotivationalMessageEntity.defaultMessages {
        let model = MessageMapper.toModel(message)
        context.insert(model)
    }

    try context.save()
}

// Caller handles the error:
do {
    try ModelContainerSetup.seedDefaultMessages(context: context)
} catch is CancellationError {
    // Acceptable - task was cancelled
} catch {
    // Surface to user or track as non-critical initialization failure
    logger.warning("Messages will be empty: \(error.localizedDescription)")
    // Optionally: container.initializationWarnings.append(.messagesSeedingFailed)
}
```

### Alternative: Make It Non-Critical But Visible

If seeding failure is truly non-critical:

```swift
enum SeedingResult {
    case success(count: Int)
    case skipped(reason: String)
    case failed(Error)
}

@MainActor
static func seedDefaultMessages(context: ModelContext) -> SeedingResult {
    do {
        // ... seeding logic ...
        return .success(count: MotivationalMessageEntity.defaultMessages.count)
    } catch {
        logger.error("Failed to seed: \(error.localizedDescription)")
        return .failed(error)
    }
}

// Caller can decide what to do with the result
let result = ModelContainerSetup.seedDefaultMessages(context: context)
if case .failed = result {
    // Maybe show a subtle warning in Settings?
}
```

---

## Files to Modify

| File | Change |
|------|--------|
| `ModelContainerSetup.swift` | Make `seedDefaultMessages` throw or return `Result` |
| `DependencyContainer.swift` | Handle seeding failure appropriately |

---

## Acceptance Criteria

- [ ] Seeding errors are not silently swallowed
- [ ] Cancellation is distinguished from real errors
- [ ] Caller can decide how to handle failure (log, warn user, retry)
- [ ] All tests pass
