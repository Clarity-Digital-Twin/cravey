# Technical Debt Tracker

**Last Updated:** 2026-01-27

## Open Debt

| ID | Priority | Description | File |
|----|----------|-------------|------|
| DEBT-007 | **P2** | **UI tests + coverage gaps** | CraveyUITests, ViewModels |
| DEBT-009 | P3 | GPS “Current Location” spec not implemented | `LocationOptions.swift` |
| DEBT-010 | P3 | Home motivation card not repository-backed | `HomeView.swift`, MessageRepository |
| DEBT-011 | **P2** | **Recording deletion can leave orphan files** | RecordingRepository, FileStorageManager |
 
## Fixed (Recent)

- DEBT-001 - Fixed (shared timestamp validation utility)
- DEBT-002 - Fixed (FileStorageManager injectable actor; removed singleton)
- DEBT-003 - Fixed (shared export file date formatter)
- DEBT-004 - Fixed (consistent nowProvider injection)
- DEBT-005 - Fixed (removed unused app entrypoint UI code)
- DEBT-006 - Fixed (semver versioning in Info.plist template)
- DEBT-008 - Fixed (consistent notes limit enforcement)

## Priority Definitions

- **P2** - Important. Tests are the safety net; privacy/data hygiene.
- **P3** - Architecture concerns. Pay down incrementally.
- **P4** - Code quality. Fix opportunistically.
