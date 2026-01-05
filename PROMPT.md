# Cravey App - Ralph Wiggum Loop Prompt

## Mission

Make the **Cravey** cannabis cessation support iOS app **fully functional, polished, and ready for App Store deployment**.

You are in a Ralph Wiggum loop. Each iteration, you will:
1. See this same prompt
2. Review your previous work in the codebase and git history
3. Pick the next highest-priority task
4. Implement it with tests
5. Verify: build succeeds, tests pass, linter clean

**When ALL acceptance criteria below are met, output:**
```
<promise>APP STORE READY</promise>
```

---

## Current State (Baseline)

### Working Features
- Craving logging (intensity 1-10, triggers, location, notes, timestamp)
- Usage logging (ROA method, amount, triggers, location, notes)
- Clean Architecture + MVVM (iOS 18+, Swift 6.2, SwiftData)
- Local-only privacy (no cloud sync)
- 32+ unit/integration tests passing

### Incomplete/Stubbed
- **DashboardView**: Placeholder text, no metrics/charts
- **SettingsView**: Placeholder, no data export/delete functionality
- **RecordingRepository**: Returns empty arrays (stub)
- **MessageRepository**: Returns empty arrays (stub)
- **AVFoundation Recording**: No capture/playback UI
- **GPS Location**: "Current Location" preset is static

### Known Issues
- 3 deprecated iOS 18 API calls in FileStorageManager.swift
- 17 SwiftLint warnings (TODO comments, function parameter counts)
- App icon missing (uses default)
- Launch screen is basic

---

## Acceptance Criteria for "APP STORE READY"

### 1. Core UI Polish
- [ ] All placeholder views replaced with functional implementations
- [ ] DashboardView shows real metrics (streak, craving trends, trigger breakdown)
- [ ] SettingsView has working Export Data and Delete All Data options
- [ ] Professional app icon (use SF Symbols or create programmatic icon)
- [ ] Polished launch screen with app branding
- [ ] Consistent typography, spacing, and color scheme throughout
- [ ] Proper empty states for all lists

### 2. Dashboard Metrics (Phase 5)
- [ ] Current clean days streak (days since last usage log)
- [ ] Longest abstinence streak (all-time record)
- [ ] Average craving intensity trend (7-day, 30-day)
- [ ] Top 3 triggers (pie chart or bar chart)
- [ ] Weekly summary card

### 3. Settings Functionality (Phase 3)
- [ ] Export all data as JSON (share sheet)
- [ ] Delete all data with confirmation
- [ ] App version and build number display
- [ ] Privacy policy link (even if placeholder URL)
- [ ] Rate app / feedback option

### 4. Code Quality
- [ ] Zero SwiftLint errors (warnings acceptable but minimize)
- [ ] All deprecated iOS 18 APIs replaced with modern equivalents
- [ ] No force unwraps in production code
- [ ] Consistent error handling throughout
- [ ] All TODO comments addressed or converted to GitHub issues

### 5. Testing
- [ ] All existing tests pass
- [ ] New features have corresponding tests
- [ ] UI builds without errors on iPhone 17 Pro simulator
- [ ] No runtime crashes in normal user flows

### 6. App Store Basics
- [ ] Valid bundle identifier
- [ ] App icon set (1024x1024 minimum)
- [ ] Launch screen configured
- [ ] Privacy usage descriptions in Info.plist (if needed)
- [ ] No obvious UI bugs visible to users

---

## Priority Order

**Iteration 1-3: Dashboard**
Implement DashboardView with real metrics using existing data from CravingRepository and UsageRepository.

**Iteration 4-5: Settings**
Implement SettingsView with export/delete functionality.

**Iteration 6-7: Code Quality**
Fix deprecated APIs, resolve linter warnings, clean up TODOs.

**Iteration 8-9: Polish**
App icon, launch screen, empty states, typography consistency.

**Iteration 10+: Testing & Validation**
Ensure all tests pass, verify all acceptance criteria.

---

## Technical Guidelines

### Architecture Rules
- Domain layer = Pure Swift (NO SwiftUI/SwiftData imports)
- All new features follow existing patterns
- Use `@Observable` (not `@ObservableObject`)
- Use `@State` for ViewModels (not `@StateObject`)
- Use `@Environment(DependencyContainer.self)` for DI

### File Locations
```
Cravey/Presentation/Views/Dashboard/  - Dashboard features
Cravey/Presentation/Views/Settings/   - Settings features
Cravey/Presentation/ViewModels/       - New ViewModels
Cravey/Domain/UseCases/               - New business logic
CraveyTests/                          - Tests for new features
```

### Build & Test Commands
```bash
# Regenerate project (if project.yml changes)
xcodegen generate

# Build
xcodebuild -scheme Cravey -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build | xcbeautify

# Test
xcodebuild test -scheme Cravey -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:CraveyTests | xcbeautify

# Lint
swiftlint

# Format
swiftformat .
```

### Verification Before Each Iteration Ends
1. `xcodebuild build` - Must succeed
2. `xcodebuild test` - All tests must pass
3. `swiftlint` - Review warnings, fix errors
4. `git status` - Commit progress with meaningful message

---

## Completion Signal

When **ALL** acceptance criteria checkboxes above can be marked as complete:

```
<promise>APP STORE READY</promise>
```

Until then, continue iterating. Pick the next uncompleted item and implement it.

---

## Context Files

Reference these for architecture patterns:
- `CLAUDE.md` - Full development context
- `docs/phases/PHASE_*.md` - Phase documentation
- `CODE_REVIEW_FINDINGS.md` - Recent fixes applied
- `BUG_SPEC_AUTHORITATIVE.md` - Bug specifications

---

**Remember:** You are in a loop. Each iteration sees your previous work. Build incrementally. Test continuously. Ship quality.
