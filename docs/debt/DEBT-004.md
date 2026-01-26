# DEBT-004: Inconsistent nowProvider Injection

**Status:** OPEN
**Priority:** P4
**Files:**
- `Cravey/Presentation/ViewModels/DashboardViewModel.swift` (has nowProvider)
- `Cravey/Presentation/ViewModels/CravingLogViewModel.swift` (uses Date() directly)
- `Cravey/Presentation/ViewModels/UsageLogViewModel.swift` (uses Date() directly)

## Problem

DashboardViewModel injects `nowProvider` for testability, but other ViewModels use `Date()` directly, making them harder to test.

## Expected

Consistent approach to time-dependent logic across all ViewModels.

## Fix

Either inject `nowProvider` in all ViewModels, or remove from DashboardViewModel (less testable but consistent).
