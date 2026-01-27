# DEBT-005: Dead / Unused UI Code in CraveyApp

**Status:** OPEN
**Priority:** P4
**File:** `Cravey/App/CraveyApp.swift:144`

## Problem

`CraveyApp.swift` contains UI types that are not referenced by the shipping app flow:
- `PlaceholderContentView` is not used by the `TabView` composition.
- The `#if os(macOS)` Settings scene and related macOS-only views are not part of the iOS-only release plan.

This increases maintenance burden and creates confusion when auditing “what is actually used”.

## Current Code

`Cravey/App/CraveyApp.swift` defines `PlaceholderContentView` and macOS-only settings views in the same file as the real app composition root.

## Expected

The app entry point should contain only the real composition root and code that is executed for the supported platforms.

## Fix

- Remove `PlaceholderContentView` if it is no longer needed.
- Move macOS-only settings views into a dedicated file behind `#if os(macOS)` (or remove until macOS is explicitly supported).
