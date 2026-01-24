# Stabilization Specification

**Version:** 1.0
**Status:** ACTIVE - P0 Priority
**Goal:** Make existing features 100% robust before adding anything new

---

## Current State (What Exists)

### Working Features
| Feature | Files | Status |
|---------|-------|--------|
| Craving Logging | CravingLogForm, CravingLogViewModel | Works |
| Usage Logging | UsageLogForm, UsageLogViewModel | Works |
| Dashboard | DashboardView, DashboardViewModel | Works but has bugs |
| Settings | SettingsView, SettingsViewModel | Works |
| Home Screen | HomeView, lists | Works |

### Known Issues

#### P0 - Swift 6 Concurrency Violations

**DashboardView.swift - `reduceMotion` in Sendable closure**
```
Lines 120-121, 189-190, 245-246, 309-310
Main actor-isolated property 'reduceMotion' can not be referenced from a Sendable closure
```

**Root Cause:** `@Environment(\.accessibilityReduceMotion)` is main-actor isolated, but `.scrollTransition { }` takes a `@Sendable` closure.

**Fix:** Capture `reduceMotion` value BEFORE the closure:
```swift
// BEFORE (broken)
.scrollTransition { content, phase in
    content.opacity(reduceMotion ? 1 : ...)  // ❌ Accessing @Environment in Sendable
}

// AFTER (fixed)
let isReduceMotion = reduceMotion  // Capture outside
.scrollTransition { content, phase in
    content.opacity(isReduceMotion ? 1 : ...)  // ✅ Using captured value
}
```

**Files to fix:**
- `DashboardView.swift` - 4 card components (MetricCard, IntensityTrendCard, TopTriggersCard, WeeklySummaryCard)

#### P1 - SwiftLint Violations (16 total)

| File | Issue | Priority |
|------|-------|----------|
| ModelContainerSetup.swift:14,37,64 | Trailing comma | Low |
| MotivationalMessageEntity.swift:115 | Trailing comma | Low |
| LogUsageUseCase.swift:5 | 6 params (exceeds 5) | Medium |
| LocationOptions.swift:8 | TODO not resolved | Low |
| TriggerOptions.swift:14,22 | Trailing comma | Low |
| HomeView.swift:28 | TODO not resolved | Low |
| UsageListView.swift:263 | Trailing comma | Low |
| UsageLogForm.swift:185 | 6 params (exceeds 5) | Medium |
| Tests (various) | Style issues | Low |

#### P2 - UI Test Concurrency Issues

**CraveyUITests/*** - Swift 6 `@MainActor` isolation in setUp()
```
XCUIApplication() initializer is main-actor isolated
```

**Fix:** Mark test class or setUp with `@MainActor`

---

## What NOT to Do

1. ❌ Add new features (recordings, onboarding)
2. ❌ Refactor architecture
3. ❌ Add new dependencies
4. ❌ Change data models
5. ❌ "Improve" working code

---

## Acceptance Criteria

### Must Have (Stabilization Complete)
- [ ] Zero Swift 6 concurrency errors in DashboardView
- [ ] `xcodebuild build` succeeds with zero errors
- [ ] All 32 unit tests pass
- [ ] App launches without crash
- [ ] All existing features still work

### Nice to Have
- [ ] SwiftLint trailing comma warnings fixed
- [ ] UI Tests re-enabled and passing

---

## File Audit Checklist

Run this to find issues:
```bash
# Build with all warnings
xcodebuild -scheme Cravey -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep -E "error:|warning:" | grep -v SwiftLint

# Run tests
xcodebuild test -scheme Cravey -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:CraveyTests 2>&1 | xcbeautify
```

---

## Implementation Order

1. Fix DashboardView.swift concurrency bugs (P0)
2. Run full test suite, verify nothing broke
3. (Optional) Fix trailing commas via swiftformat
4. Commit with clear message
