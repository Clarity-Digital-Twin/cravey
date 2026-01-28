# Technical Debt Tracker

**Last Updated:** 2026-01-27

## Open Debt

| ID | Priority | Description | File |
|----|----------|-------------|------|
| (none) | - | All technical debt resolved! 🎉 | - |

## Fixed (Recent)

- DEBT-009 - Fixed (GPS "Current Location" feature with CoreLocation integration)
- DEBT-001 - Fixed (shared timestamp validation utility)
- DEBT-002 - Fixed (FileStorageManager injectable actor; removed singleton)
- DEBT-003 - Fixed (shared export file date formatter)
- DEBT-004 - Fixed (consistent nowProvider injection)
- DEBT-005 - Fixed (removed unused app entrypoint UI code)
- DEBT-006 - Fixed (semver versioning in Info.plist template)
- DEBT-007 - Fixed (UI tests passing; `--ui` flag added to verify.sh)
- DEBT-008 - Fixed (consistent notes limit enforcement)
- DEBT-010 - Fixed (Home motivation now repository-backed with timesShown tracking)
- DEBT-011 - Fixed (RecordingRepository.delete now deletes files + model)

## Priority Definitions

- **P2** - Important. Tests are the safety net; privacy/data hygiene.
- **P3** - Architecture concerns. Pay down incrementally.
- **P4** - Code quality. Fix opportunistically.
