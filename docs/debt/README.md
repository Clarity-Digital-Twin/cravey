# Technical Debt Tracker

**Last Updated:** 2026-01-27

## Open Debt

| ID | Priority | Description | File |
|----|----------|-------------|------|
| DEBT-006 | P4 | Version should use semver 0.x.x (pre-release) | `iOS.Info.plist.template` |
| DEBT-007 | P3 | Test coverage needs expansion | Multiple |
| DEBT-008 | P4 | Notes character limit enforcement inconsistency | ViewModels |
 
## Fixed (Recent)

- DEBT-001 - Fixed (shared timestamp validation utility)
- DEBT-002 - Fixed (FileStorageManager injectable actor; removed singleton)
- DEBT-003 - Fixed (shared export file date formatter)
- DEBT-004 - Fixed (consistent nowProvider injection)
- DEBT-005 - Fixed (removed unused app entrypoint UI code)

## Priority Definitions

- **P3** - Architecture concerns. Pay down incrementally.
- **P4** - Code quality. Fix opportunistically.
