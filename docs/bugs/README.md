# Bug Tracker

**Last Updated:** 2026-01-24
**Total Issues:** 30

## Quick Stats

| Priority | Count | Status |
|----------|-------|--------|
| P0 - Critical | 2 | 2 FIXED |
| P1 - Major | 6 | 6 FIXED |
| P2 - Minor | 5 | 5 CLOSED/FIXED |
| P3 - Tech Debt | 7 | 6 FIXED, 1 DEFERRED |
| P4 - Code Quality | 10 | 9 CLOSED/FIXED, 1 DEFERRED |

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
✅ No open P0/P1 issues.

### Should Fix Soon
1. **DEBT-003** - Link TODOs to future specs (deferred)
2. **QUALITY-010** - Recording infra usage cleanup (deferred)

### Fixed Recently
- ✅ **BUG-001** - DependencyContainer fatalError on init failure
- ✅ **BUG-012** - “Delete All Data” deletes recordings/messages/files
- ✅ **DEBT-001** - SettingsViewModel Clean Architecture violation

## How to Use

1. Pick a bug from highest priority file
2. Create branch: `fix/BUG-XXX-short-description`
3. Fix the issue
4. Update bug status in the doc
5. PR with bug ID in title
