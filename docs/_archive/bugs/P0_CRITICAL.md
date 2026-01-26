# P0 - Critical Bugs

**Status:** ACTIVE
**Last Updated:** 2026-01-25

These bugs can cause crashes, data loss, or prevent the app from running.

---

## BUG-001: DependencyContainer fatalError on Init Failure

**File:** `Cravey/App/DependencyContainer.swift`
**Verify:** `rg -n "Falling back to in-memory" Cravey/App/DependencyContainer.swift`

### Problem
Historical snippet (no longer present):

```swift
} catch {
    fatalError("Failed to initialize DependencyContainer: \\(error)")
}
```

If ModelContainer or repository setup fails (disk full, corrupted data, etc.), the entire app crashes immediately with no recovery option.

### Impact
- App won't launch
- User loses all data access
- No way to recover without reinstalling

### Status
✅ **FIXED** (2026-01-24)

### Fix Implemented
- Persistent init failure no longer crashes the app.
- App falls back to an in-memory SwiftData container and surfaces a user-facing alert.

**Related Files:**
- `Cravey/App/DependencyContainer.swift`
- `Cravey/App/CraveyApp.swift` (alert UI)

### Acceptance Criteria
- [x] App does not crash on persistent storage init failure
- [x] In-memory fallback mode activates
- [x] User sees a storage-unavailable alert

---

## BUG-002: Swift 6 Concurrency - DashboardView reduceMotion ✅ FIXED

**File:** `Cravey/Presentation/Views/Dashboard/DashboardView.swift`

### Problem
~~`@Environment(\.accessibilityReduceMotion)` accessed inside `@Sendable` `.scrollTransition {}` closures.~~

### Status
**FIXED** in commit `0a19b34` - Captured value before closure in all 4 card components.

## BUG-014: iOS Simulator Builds Fail Due to SwiftLint Script Sandboxing

**File:** `project.yml`
**Verify:**
- `rg -n "ENABLE_USER_SCRIPT_SANDBOXING" project.yml`
- `xcodegen generate && xcodebuild test -scheme Cravey -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:CraveyTests | xcbeautify`

### Problem
`xcodebuild` for iOS Simulator fails if `swiftlint` is installed locally. Xcode's User Script Sandboxing blocks
SwiftLint from reading the repo/config, producing build errors like:

- `Sandbox: swiftlint(...) deny file-read-data ...`

### Impact
- iOS Simulator builds/tests fail (CI + local dev blocked)
- False confidence: `scripts/verify.sh` passes on Mac Catalyst while iOS builds are broken

### Status
✅ **FIXED** (2026-01-25)

### Fix Implemented
- Disabled User Script Sandboxing in `project.yml` via `ENABLE_USER_SCRIPT_SANDBOXING: "NO"` to allow the SwiftLint
  build phase to read sources/config across all destinations.

---

## BUG-023: Startup Crashes on Unrecoverable Storage Failure (fatalError)

**File:** `Cravey/App/DependencyContainer.swift`
**Verify:**
- `! rg -n "fatalError\\(" Cravey/App/DependencyContainer.swift` (should return no matches)
- `rg -n "throw StartupFailure" Cravey/App/DependencyContainer.swift`
- `rg -n "AppUnavailableView\\(" Cravey/App/CraveyApp.swift`
- `bash scripts/verify.sh`

### Problem
If both persistent storage initialization and the in-memory fallback initialization fail, the app used to call
`fatalError(...)` and crash during startup.

### Impact
- App won’t launch
- No user-facing recovery path (beyond reinstall/device restart)

### Status
✅ **FIXED** (2026-01-25)

### Fix Implemented
- `DependencyContainer` now throws a `StartupFailure` error instead of calling `fatalError`.
- `CraveyApp` conditionally renders:
  - The normal app scene (with `.modelContainer(...)`) when startup succeeds
  - An `AppUnavailableView` fallback when startup fails (no `ModelContainer` required)
- Added a unit test that simulates both containers failing via injected factories:
  - `CraveyTests/App/DependencyContainerTests.swift`

### Acceptance Criteria
- [x] No `fatalError` call remains in startup code paths
- [x] Unrecoverable startup failure renders `AppUnavailableView` instead of crashing
- [x] Unit test covers double-failure path
- [x] `bash scripts/verify.sh` passes

---

## Summary

| Bug ID | Description | Status |
|--------|-------------|--------|
| BUG-001 | fatalError in DependencyContainer | ✅ FIXED |
| BUG-002 | Swift 6 reduceMotion concurrency | ✅ FIXED |
| BUG-014 | iOS Simulator builds fail due to SwiftLint script sandboxing | ✅ FIXED |
| BUG-023 | Startup fatalError on unrecoverable storage failure | ✅ FIXED |
