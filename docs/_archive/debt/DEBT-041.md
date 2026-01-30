# DEBT-041: Usage “method” is stringly-typed and duplicated across layers

**Priority:** P3 (Maintainability / type safety)
**Status:** ✅ RESOLVED
**Created:** 2026-01-30
**Resolved:** 2026-01-30

## Resolution

- Introduced `UsageMethod` enum as the single source of truth for ROA methods.
- Updated UI options and validation to derive from `UsageMethod` (while persisting `rawValue` strings for compatibility).

## Problem

The usage “method” (ROA) is represented as raw `String` values across Domain, Presentation, and Data. This causes duplication and mismatch risk:

- UI list: `["Bowls", "Joints", "Blunts", "Vape", "Dab", "Edible"]`
- Domain validation list: `ROAAmountRange.validMethods`
- Error message list: `UsageError.invalidMethod` string
- Models/entities/comments also embed the list as text.

## Location

- `Cravey/Presentation/Views/Usage/UsageLogForm.swift` (methods array)
- `Cravey/Domain/UseCases/ROAAmountRange.swift` (validMethods + ranges)
- `Cravey/Domain/UseCases/LogUsageUseCase.swift` (validation + error copy)
- `Cravey/Domain/Entities/UsageEntity.swift` (method as String)
- `Cravey/Data/Models/UsageModel.swift` (method as String)

## Why This Is Bad

- **Easy drift:** One place updates, another doesn’t.
- **Harder refactors:** Adding/removing a method touches multiple files and strings.
- **Less type safety:** Strings allow invalid values to slip through until runtime validation.

## Proposed Fix

Introduce a Domain enum:

- `enum UsageMethod: String, CaseIterable, Codable, Sendable { ... }`
- Provide:
  - `static var allCases` for UI options
  - `var amountOptions: [Double]` (or keep in ROAAmountRange but keyed by enum)
  - `var displayName` if needed

Persist as `rawValue` in SwiftData and exports.

## Acceptance Criteria

- [x] Single source of truth for valid methods.
- [x] UI options derive from Domain, not duplicated literals.
- [x] Validation uses enum values, not string containment.
- [x] Export remains schema-compatible and stable.
