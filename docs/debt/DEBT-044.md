# DEBT-044: RecordingModel filePath persistence is documented inconsistently (AGENTS/CLAUDE vs code)

**Priority:** P4 (Docs correctness / team velocity)
**Status:** OPEN
**Created:** 2026-01-30

## Problem

`AGENTS.md` and `CLAUDE.md` state:

- `filePath: String` - Relative path to file (**NOT stored in database**)

…but the SwiftData model persists `filePath` as a normal stored property:

- `Cravey/Data/Models/RecordingModel.swift` has `var filePath: String = "" // Relative path`

Other documentation sections also say file paths are stored as relative strings in SwiftData, which conflicts with the “NOT stored in database” bullet.

## Location

- `AGENTS.md` (RecordingModel section)
- `CLAUDE.md` (RecordingModel section)
- `Cravey/Data/Models/RecordingModel.swift`

## Why This Is Bad

- **Misleads future work:** Engineers may implement features assuming the DB doesn’t have file paths.
- **Slows reviews:** Reviewers can’t trust the docs as SSOT if these contradictions exist.

## Proposed Fix

- Decide the intended truth:
  - If the app should store relative paths in SwiftData (current behavior), update `AGENTS.md` + `CLAUDE.md` to match.
  - If the requirement is truly “do not store file paths in SwiftData”, then change the model to use `@Transient` and implement an alternative lookup mechanism (likely not worth the complexity).

## Acceptance Criteria

- [ ] Docs match implementation (or implementation updated to match docs).
- [ ] `AGENTS.md` and `CLAUDE.md` remain in sync.

