# DEBT-033: CraveyApp Error Handling Code Duplicated 3x

**Priority:** P2 (Important - DRY Violation)
**Status:** OPEN
**Created:** 2026-01-29

## Problem

`CraveyApp.swift` has **three nearly identical catch blocks** that set all ViewModels to nil and configure startup failure. This is ~45 lines of duplicated code.

---

## Duplicated Pattern

### Location 1: init() - catch StartupFailure (lines 29-37)
### Location 2: init() - catch generic error (lines 38-52)
### Location 3: retryStartup() - catch StartupFailure (lines 124-132)
### Location 4: retryStartup() - catch generic error (lines 133-145)

```swift
// Pattern repeated 4 times with minor variations:
dependencyContainer = nil
cravingListViewModel = nil
usageListViewModel = nil
dashboardViewModel = nil
settingsViewModel = nil
homeMotivationViewModel = nil
startupFailure = error  // or wrapped error
showStorageAlert = false
```

---

## Why This Is Bad

1. **Maintenance nightmare** - Adding a new ViewModel requires updating 4 places
2. **Easy to forget** - Miss one catch block and you have inconsistent state
3. **Violates DRY** - Same code repeated with only assignment style differences (`State(initialValue:)` vs direct)

---

## Rob C. Martin Fix: Extract Helper Methods

```swift
@main
struct CraveyApp: App {
    @State private var dependencyContainer: DependencyContainer?
    @State private var cravingListViewModel: CravingListViewModel?
    // ... other ViewModels ...

    init() {
        let result = Self.initializeApp()
        _dependencyContainer = State(initialValue: result.container)
        _cravingListViewModel = State(initialValue: result.cravingListVM)
        _usageListViewModel = State(initialValue: result.usageListVM)
        _dashboardViewModel = State(initialValue: result.dashboardVM)
        _settingsViewModel = State(initialValue: result.settingsVM)
        _homeMotivationViewModel = State(initialValue: result.homeMotivationVM)
        _startupFailure = State(initialValue: result.failure)
        _showStorageAlert = State(initialValue: result.showStorageAlert)
    }

    private static func initializeApp() -> AppInitResult {
        do {
            let container = try DependencyContainer()
            return AppInitResult(
                container: container,
                cravingListVM: container.makeCravingListViewModel(),
                usageListVM: container.makeUsageListViewModel(),
                dashboardVM: container.makeDashboardViewModel(),
                settingsVM: container.makeSettingsViewModel(),
                homeMotivationVM: container.makeHomeMotivationViewModel(),
                failure: nil,
                showStorageAlert: container.initializationError != nil
            )
        } catch let error as DependencyContainer.StartupFailure {
            return AppInitResult.failed(error)
        } catch {
            return AppInitResult.failed(
                DependencyContainer.StartupFailure(
                    persistentErrorDescription: error.localizedDescription,
                    inMemoryErrorDescription: error.localizedDescription
                )
            )
        }
    }

    @MainActor
    private func retryStartup() {
        let result = Self.initializeApp()
        dependencyContainer = result.container
        cravingListViewModel = result.cravingListVM
        // ... apply result ...
    }
}

private struct AppInitResult {
    let container: DependencyContainer?
    let cravingListVM: CravingListViewModel?
    let usageListVM: UsageListViewModel?
    let dashboardVM: DashboardViewModel?
    let settingsVM: SettingsViewModel?
    let homeMotivationVM: HomeMotivationViewModel?
    let failure: DependencyContainer.StartupFailure?
    let showStorageAlert: Bool

    static func failed(_ error: DependencyContainer.StartupFailure) -> AppInitResult {
        AppInitResult(
            container: nil,
            cravingListVM: nil,
            usageListVM: nil,
            dashboardVM: nil,
            settingsVM: nil,
            homeMotivationVM: nil,
            failure: error,
            showStorageAlert: false
        )
    }
}
```

---

## Files to Modify

| File | Change |
|------|--------|
| `CraveyApp.swift` | Extract `AppInitResult` struct and `initializeApp()` method |

---

## Acceptance Criteria

- [ ] Single source of truth for "reset all ViewModels to nil" logic
- [ ] Adding a new ViewModel only requires updating ONE place
- [ ] `init()` and `retryStartup()` both use the same helper
- [ ] All tests pass
