# Bug Tracker

**Last Updated:** 2026-01-25
**Total Issues:** 44

## Quick Stats

| Priority | Count | Status |
|----------|-------|--------|
| P0 - Critical | 4 | 3 FIXED, 1 OPEN |
| P1 - Major | 10 | 6 FIXED, 4 OPEN |
| P2 - Minor | 9 | 8 FIXED, 1 CLOSED |
| P3 - Tech Debt | 9 | 7 FIXED, 2 DEFERRED |
| P4 - Code Quality | 12 | 8 FIXED, 2 CLOSED, 2 DEFERRED |

## Priority Definitions

- **P0 - Critical:** Crashes, data loss, security issues. Fix immediately.
- **P1 - Major:** Features broken, significant user impact. Fix this sprint.
- **P2 - Minor:** Edge cases, UI glitches, style issues. Fix when time allows.
- **P3 - Tech Debt:** Architecture violations, design issues. Pay down incrementally.
- **P4 - Code Quality:** Code smells, naming, minor improvements. Fix opportunistically.

## Files

- `P0_CRITICAL.md` - Crashes and blockers
- `P1_MAJOR.md` - Major functional issues
- `P2_MINOR.md` - Minor issues and style
- `P3_TECH_DEBT.md` - Architecture and design debt
- `P4_CODE_QUALITY.md` - Code quality improvements

## Top Priorities

### Must Fix Before Next Release
1. **BUG-023** - DependencyContainer fatalError on unrecoverable storage
2. **BUG-015** - First launch onboarding missing
3. **BUG-016** - Home tab UX mismatch (primary actions + Quick Play)
4. **BUG-017** - Dashboard spec gap (date filter + charts)
5. **BUG-018** - Recordings feature stubbed

### Should Fix Soon
1. **DEBT-003** - Deferred phase features (Quick Play, GPS location)
2. **DEBT-009** - File I/O on MainActor (recordings readiness)
3. **QUALITY-010** - Recording infra usage cleanup
4. **QUALITY-012** - Logger subsystem consistency

### Fixed Recently
- ✅ **BUG-014** - iOS Simulator builds blocked by SwiftLint script sandboxing
- ✅ **DEBT-008** - Verification script now compiles iOS Simulator
- ✅ **BUG-019** - Disabled interactive sheet dismiss during save
- ✅ **BUG-020** - Intensity color scale aligned to spec
- ✅ **BUG-021** - Dashboard top triggers include usage triggers
- ✅ **BUG-022** - Domain validation for future timestamps + notes length
- ✅ **BUG-001** - DependencyContainer fatalError on init failure
- ✅ **BUG-012** - “Delete All Data” deletes recordings/messages/files
- ✅ **DEBT-001** - SettingsViewModel Clean Architecture violation

## How to Use

1. Pick a bug from highest priority file
2. Create branch: `fix/BUG-XXX-short-description`
3. Fix the issue
4. Update bug status in the doc
5. PR with bug ID in title
