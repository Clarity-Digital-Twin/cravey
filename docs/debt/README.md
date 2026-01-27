# Technical Debt Tracker

**Last Updated:** 2026-01-27

## Open Debt

| ID | Priority | Description | File |
|----|----------|-------------|------|
| DEBT-007 | **P2** | **UI tests not in gate** (ViewModel coverage closed) | CraveyUITests |
| DEBT-009 | P3 | GPS "Current Location" spec not implemented | `LocationOptions.swift` |
 
## Fixed (Recent)

- DEBT-001 - Fixed (shared timestamp validation utility)
- DEBT-002 - Fixed (FileStorageManager injectable actor; removed singleton)
- DEBT-003 - Fixed (shared export file date formatter)
- DEBT-004 - Fixed (consistent nowProvider injection)
- DEBT-005 - Fixed (removed unused app entrypoint UI code)
- DEBT-006 - Fixed (semver versioning in Info.plist template)
- DEBT-008 - Fixed (consistent notes limit enforcement)
- DEBT-010 - Fixed (Home motivation now repository-backed with timesShown tracking)
- DEBT-011 - Fixed (RecordingRepository.delete now deletes files + model)

## Priority Definitions

- **P2** - Important. Tests are the safety net; privacy/data hygiene.
- **P3** - Architecture concerns. Pay down incrementally.
- **P4** - Code quality. Fix opportunistically.
