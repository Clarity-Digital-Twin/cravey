# DEBT-007: Test Coverage Needs Expansion + UI Tests Outdated

**Priority:** P2 (Important - Tests Are Safety Net)
**Status:** OPEN
**Created:** 2026-01-27

## Executive Summary

> "Tests are the safety net that lets you refactor with confidence." - Robert C. Martin

Our UI tests **compile and run** (no Swift 6 concurrency blocker), but they **fail** because they were written for an old UI architecture. The tests expect a Home tab with "No Cravings Logged" text and an "addButton", but the current 4-tab structure is:
- Home (Dashboard)
- Log (Craving/Usage buttons)
- History (Lists)
- Settings

This is **technical debt**, not a framework limitation.

---

## Current Test State

### Unit Tests (CraveyTests) ✅
| Metric | Value |
|--------|-------|
| Test Files | 15 |
| Tests | 48 |
| Passing | 48 (100%) |
| Test Lines | 1,617 |
| Production Lines | 5,500 |
| Ratio | ~29% |

### UI Tests (CraveyUITests) ❌
| Metric | Value |
|--------|-------|
| Test Files | 4 |
| Tests | ~8 |
| Passing | 0 |
| Status | **OUTDATED - Tests don't match current UI** |

---

## Root Cause Analysis

### UI Tests Written For Old Architecture

**CraveyUITests.swift expects:**
```swift
let emptyStateMessage = app.staticTexts["No Cravings Logged"]  // Line 23
let plusButton = app.buttons["addButton"]  // Line 26
```

**Current UI has:**
- Home = Dashboard (streak, stats, motivation card)
- No "addButton" - logging is on Log tab
- "No Cravings Logged" is in History → Cravings list

### Tests Were Never Updated After UI Redesign

The 4-tab structure (Home/Log/History/Settings) replaced the old 3-tab (+menu) structure, but UI tests weren't updated to match.

---

## Test Directory Structure (Current vs Ideal)

### Current Structure
```
CraveyTests/
├── App/
│   └── DependencyContainerTests.swift
├── Data/                           # ❌ Empty
├── Domain/
│   └── UseCases/
│       ├── ExportUserDataUseCaseTests.swift
│       └── LogCravingUseCaseTests.swift
├── Integration/
│   ├── CravingLogIntegrationTests.swift
│   ├── DeleteAllUserDataUseCaseTests.swift
│   ├── MapperCompatibilityTests.swift
│   ├── UsageDataLayerTests.swift
│   └── UsageLogIntegrationTests.swift
└── Presentation/
    ├── Components/
    │   ├── IntensitySliderTests.swift
    │   └── ROAPickerInputTests.swift
    ├── Utilities/
    │   └── UserDataExportFileBuilderTests.swift
    └── ViewModels/
        ├── CravingLogViewModelTests.swift
        ├── DashboardViewModelTests.swift
        ├── UsageListViewModelTests.swift
        └── UsageLogViewModelTests.swift
```

### Ideal Structure (Mirror Production)
```
CraveyTests/
├── App/
│   └── DependencyContainerTests.swift        ✅ Exists
├── Data/
│   ├── Mappers/                              ❌ Missing (use integration tests)
│   └── Repositories/                         ❌ Missing (use integration tests)
├── Domain/
│   └── UseCases/
│       ├── LogCravingUseCaseTests.swift      ✅ Exists
│       ├── LogUsageUseCaseTests.swift        ❌ Missing
│       ├── FetchCravingsUseCaseTests.swift   ❌ Missing
│       ├── FetchUsageUseCaseTests.swift      ❌ Missing
│       ├── DeleteCravingUseCaseTests.swift   ❌ Missing
│       ├── DeleteUsageUseCaseTests.swift     ❌ Missing
│       └── ExportUserDataUseCaseTests.swift  ✅ Exists
├── Integration/
│   ├── CravingLogIntegrationTests.swift      ✅ Exists
│   ├── UsageLogIntegrationTests.swift        ✅ Exists
│   ├── UsageDataLayerTests.swift             ✅ Exists
│   ├── DeleteAllUserDataUseCaseTests.swift   ✅ Exists
│   └── MapperCompatibilityTests.swift        ✅ Exists
└── Presentation/
    ├── Components/
    │   ├── IntensitySliderTests.swift        ✅ Exists
    │   ├── ROAPickerInputTests.swift         ✅ Exists
    │   ├── ChipSelectorTests.swift           ❌ Missing
    │   └── TimestampPickerTests.swift        ❌ Missing
    ├── Utilities/
    │   └── UserDataExportFileBuilderTests.swift  ✅ Exists
    └── ViewModels/
        ├── CravingLogViewModelTests.swift    ✅ Exists
        ├── CravingListViewModelTests.swift   ❌ Missing
        ├── UsageLogViewModelTests.swift      ✅ Exists
        ├── UsageListViewModelTests.swift     ✅ Exists
        ├── DashboardViewModelTests.swift     ✅ Exists
        └── SettingsViewModelTests.swift      ❌ Missing
```

---

## Priority Fixes

### Tier 1: Critical (Fix UI Tests)

**1. Update CraveyUITests.swift**
```swift
// OLD (broken)
let emptyStateMessage = app.staticTexts["No Cravings Logged"]
let plusButton = app.buttons["addButton"]

// NEW (matches current UI)
let homeTab = app.tabBars.buttons["Home"]
let logTab = app.tabBars.buttons["Log"]
let historyTab = app.tabBars.buttons["History"]
```

**2. Update UsageLogUITests.swift**
- Change from "addButton" → Log tab navigation
- Update flow to match current UI

**3. Update Phase1ScreenshotTests.swift**
- Update screenshot flow for 4-tab structure

### Tier 2: Missing ViewModel Tests

| Missing Test | Priority | Why |
|--------------|----------|-----|
| CravingListViewModelTests | High | Parity with UsageListViewModelTests |
| SettingsViewModelTests | High | Export + delete flows untested |

### Tier 3: Missing Component Tests

| Missing Test | Priority | Why |
|--------------|----------|-----|
| ChipSelectorTests | Medium | Complex selection logic |
| TimestampPickerTests | Low | Thin wrapper around DatePicker |

---

## Test Philosophy (Uncle Bob)

### Test Behavior, Not Implementation

```swift
// ❌ Bad: Tests implementation detail
@Test func testUseCaseCallsRepository() {
    let mockRepo = MockRepo()
    let useCase = UseCase(repo: mockRepo)
    useCase.execute()
    #expect(mockRepo.saveCalled == true)  // Tests HOW, not WHAT
}

// ✅ Good: Tests behavior
@Test func testLogCravingSavesToDatabase() async throws {
    let useCase = makeUseCase()
    let craving = try await useCase.execute(intensity: 5)
    let fetched = try await fetchUseCase.execute()
    #expect(fetched.contains { $0.id == craving.id })  // Tests WHAT
}
```

### Test Pyramid

```
        /\
       /  \      UI Tests (few, slow)
      /----\
     /      \    Integration Tests (some, medium)
    /--------\
   /          \  Unit Tests (many, fast)
  /------------\
```

---

## Running Tests

```bash
# All unit tests (fast)
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests | xcbeautify

# All UI tests (slow, currently failing)
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyUITests | xcbeautify

# Specific test
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests/LogCravingUseCaseTests | xcbeautify
```

---

## Acceptance Criteria

- [ ] UI tests updated to match current 4-tab architecture
- [ ] All UI tests pass
- [ ] CravingListViewModelTests added (parity with UsageListViewModelTests)
- [ ] SettingsViewModelTests added (export + delete flows)
- [ ] Test structure mirrors production structure
- [ ] `scripts/verify.sh` runs UI tests successfully

---

## References

- [XCTest Meets @MainActor](https://qualitycoding.org/xctest-mainactor/) - Swift 6 testing patterns
- [Swift Concurrency Testing](https://commitstudiogs.medium.com/swift-concurrency-testing-writing-safe-and-fast-async-unit-tests-0a511117a4c4) - Best practices
- [Swift 6 Concurrency Guide](https://medium.com/@gauravios/swift-6-concurrency-a-practical-guide-for-ios-developers-27dee88b1adc) - Practical patterns
