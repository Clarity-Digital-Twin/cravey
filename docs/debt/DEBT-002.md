# DEBT-002: FileStorageManager Singleton Pattern

**Status:** FIXED
**Priority:** P3
**Files:**
- `Cravey/Data/Storage/FileStorageManager.swift`
- `Cravey/App/DependencyContainer.swift`

## Problem

`FileStorageManager.shared` is a singleton with `@MainActor`, making it hard to mock for testing and potentially causing thread safety issues.

## Current Code

```swift
@MainActor
final class FileStorageManager {
    static let shared = FileStorageManager()
```

## Expected

FileStorageManager should be injectable through DependencyContainer for testability.

## Fix

Remove the singleton, make FileStorageManager injectable, and wire it through DependencyContainer like other services.

✅ Implemented by converting `FileStorageManager` to an actor (no global `shared`) and instantiating it in `DependencyContainer.makeWiring(modelContainer:)`.
