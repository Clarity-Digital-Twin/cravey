# DEBT-002: FileStorageManager Singleton Pattern

**Status:** OPEN
**Priority:** P3
**File:** `Cravey/Data/Storage/FileStorageManager.swift:35-36`

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

Remove singleton, inject through DependencyContainer like other services.
