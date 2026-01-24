# P3 - Tech Debt

**Status:** ACTIVE
**Last Updated:** 2025-01-24

Architecture violations, incomplete implementations, design issues that need addressing.

---

## DEBT-001: SettingsViewModel Violates Clean Architecture 🔴

**File:** `Cravey/Presentation/ViewModels/SettingsViewModel.swift`
**Lines:** 6, 48-49

### Problem
ViewModel directly imports and uses Data layer classes:
```swift
import SwiftData  // ❌ Presentation should not import Data framework

// Direct access to models
let cravings = try context.fetch(FetchDescriptor<CravingModel>())
let usages = try context.fetch(FetchDescriptor<UsageModel>())
```

### Violation
**Clean Architecture Rule:** Presentation → Domain ← Data

SettingsViewModel bypasses Domain layer entirely:
```
Current:   SettingsViewModel → Data (CravingModel, UsageModel)
Should be: SettingsViewModel → Domain (ExportDataUseCase, DeleteAllDataUseCase)
```

### Impact
- Breaks testability (can't mock without SwiftData)
- Couples UI to persistence framework
- Makes future changes harder

### Fix
1. Create Domain use cases:
```swift
// Domain/UseCases/ExportDataUseCase.swift
protocol ExportDataUseCase {
    func execute() async throws -> ExportData
}

// Domain/UseCases/DeleteAllDataUseCase.swift
protocol DeleteAllDataUseCase {
    func execute() async throws
}
```

2. Implement in Data layer
3. Inject into SettingsViewModel via DependencyContainer

### Acceptance Criteria
- [ ] SettingsViewModel has no SwiftData imports
- [ ] Export/Delete logic in Domain use cases
- [ ] SettingsViewModel only depends on protocols

---

## DEBT-002: UI Tests Not Functional (Swift 6 Issues)

**Files:**
- `CraveyUITests/CraveyUITests.swift`
- `CraveyUITests/UsageLogUITests.swift`
- `CraveyUITests/Phase1ScreenshotTests.swift`

### Problem
Swift 6 `@MainActor` isolation breaks UI test setup:
```swift
nonisolated(unsafe) var app: XCUIApplication!  // Workaround

override func setUp() {
    app = XCUIApplication()  // ❌ Main actor isolation error
    app.launchArguments = ["--uitesting"]
    app.launch()
}
```

### Impact
- UI tests may not run properly
- No automated UI regression testing
- Manual testing burden

### Fix
```swift
@MainActor
final class CraveyUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() async throws {
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
}
```

---

## DEBT-003: Incomplete TODO Features

**Files:**
- `HomeView.swift:28` - "TODO: Quick Play section (Phase 4 - Recordings)"
- `LocationOptions.swift:8` - "TODO: Phase 2 - Wire CoreLocation GPS detection"

### Impact
Features specified in master specs but not implemented.

### Decision
These are deferred to future phases. TODOs should reference the future spec:
```swift
// TODO: See docs/future/RECORDINGS_SPEC.md
```

---

## DEBT-004: Missing Error Recovery in App Init

**File:** `Cravey/App/DependencyContainer.swift`

### Problem
No try-catch around ModelContainer creation. If it fails, app crashes.

### Related To
BUG-001 (P0) - Same root cause.

---

## DEBT-005: DashboardViewModel Streak Logic Unclear

**File:** `Cravey/Presentation/ViewModels/DashboardViewModel.swift`
**Lines:** 79-114

### Problem
Streak calculation logic is confusing:
- `calculateCurrentStreak()` - Days since last usage
- `calculateLongestStreak()` - Longest gap between usages

### Questions
1. Is "streak" days clean, or days between usages?
2. What if user has never used? (streak = days since install?)
3. What if user uses multiple times per day?

### Fix
1. Add clear documentation for streak semantics
2. Add unit tests for edge cases
3. Consider renaming: `daysSinceLastUsage`, `longestCleanPeriod`

---

## Summary

| Debt ID | Description | Impact | Status |
|---------|-------------|--------|--------|
| DEBT-001 | SettingsViewModel Clean Arch violation | High | OPEN |
| DEBT-002 | UI Tests broken (Swift 6) | Medium | OPEN |
| DEBT-003 | TODO features not implemented | Low | DEFERRED |
| DEBT-004 | No error recovery in init | High | OPEN |
| DEBT-005 | Streak logic unclear | Medium | OPEN |
