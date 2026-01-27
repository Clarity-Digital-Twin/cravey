# DEBT-007: Test Coverage Needs Expansion

**Priority:** P3 (Architecture)
**Status:** OPEN
**Created:** 2026-01-27

## Current State

### Unit Tests (CraveyTests)
- **15 test files**, **48 tests**, all passing ✅
- **1,617 lines** of test code
- **5,500 lines** of production code
- **Ratio:** ~29% test-to-production lines (decent for Swift)

### What's Tested
| Layer | Coverage | Files |
|-------|----------|-------|
| Domain/UseCases | ✅ Good | LogCravingUseCaseTests, ExportUserDataUseCaseTests |
| Presentation/ViewModels | ✅ Good | CravingLog, UsageLog, UsageList, Dashboard ViewModelTests |
| Integration | ✅ Good | CravingLog, UsageLog, UsageData, DeleteAllUserData, MapperCompatibility |
| Components | ⚠️ Partial | IntensitySlider, ROAPickerInput |
| App Startup | ✅ Good | DependencyContainerTests |

### What's NOT Tested
| Area | Status | Notes |
|------|--------|-------|
| **UI Tests** | ❌ Disabled | Swift 6 concurrency issues; files exist but not run in CI |
| **CravingListViewModel** | ❌ Missing | Only UsageListViewModel has tests |
| **SettingsViewModel** | ❌ Missing | Export + delete flows untested |
| **Repository layer** | ⚠️ Implicit | Tested via integration tests, no unit tests |
| **ChipSelector** | ❌ Missing | FlowLayout, selection logic |
| **TimestampPicker** | ❌ Missing | No component tests |

### UI Tests (CraveyUITests)
- **4 files** exist: `CraveyUITests.swift`, `UsageLogUITests.swift`, `Phase1ScreenshotTests.swift`, `UITestSupport.swift`
- **Status:** Disabled due to Swift 6 strict concurrency issues
- **Fix:** Need to add `@MainActor` annotations and resolve sendability issues

## Priority Improvements

### Tier 1: Critical Gaps
1. **CravingListViewModel tests** - Mirror UsageListViewModel tests
2. **SettingsViewModel tests** - Export and delete-all flows
3. **Enable UI tests** - Fix Swift 6 concurrency issues

### Tier 2: Nice to Have
4. **ChipSelector component tests** - Selection logic, accessibility
5. **Repository unit tests** - Currently only integration-tested
6. **Snapshot tests** - Visual regression testing

## Test Framework

Using **Swift Testing** (not XCTest):
- `@Test` macro
- `#expect` assertions
- `@Suite` grouping

## Running Tests

```bash
# Run all unit tests
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests | xcbeautify

# Run specific test file
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests/LogCravingUseCaseTests | xcbeautify
```

## Acceptance Criteria

- [ ] CravingListViewModel has test parity with UsageListViewModel
- [ ] SettingsViewModel export/delete flows have tests
- [ ] UI tests build and run without Swift 6 concurrency errors
- [ ] Test coverage summary added to CI output
