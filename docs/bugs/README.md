# Bug Tracker

**Last Updated:** 2025-01-24
**Total Issues:** 24

## Quick Stats

| Priority | Count | Status |
|----------|-------|--------|
| P0 - Critical | 2 | 1 FIXED, 1 OPEN |
| P1 - Major | 4 | OPEN |
| P2 - Minor | 5 | OPEN |
| P3 - Tech Debt | 5 | OPEN |
| P4 - Code Quality | 8 | OPEN |

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
1. **BUG-001** - DependencyContainer fatalError (P0)
2. **DEBT-001** - SettingsViewModel Clean Architecture violation (P3 but high impact)

### Should Fix Soon
3. **BUG-003** - ModelContext thread safety documentation
4. **BUG-004** - Swallowed errors in seed data
5. **DEBT-005** - Streak logic documentation

### Fixed Recently
- ✅ **BUG-002** - DashboardView Swift 6 concurrency (Fixed 2025-01-24)

## How to Use

1. Pick a bug from highest priority file
2. Create branch: `fix/BUG-XXX-short-description`
3. Fix the issue
4. Update bug status in the doc
5. PR with bug ID in title
