# DEBT-006: Version Should Use Proper Semver (0.x.x Pre-Release)

**Priority:** P4 (Polish)
**Status:** FIXED
**File:** `Config/iOS.Info.plist.template`
**Created:** 2026-01-27
**Fixed:** 2026-01-27

## Problem

Current version is `1.0 (1)` but the app is pre-release with major features incomplete:
- Recordings feature is stubbed (placeholder only)
- Onboarding flow not implemented
- UI tests not running in CI

Per [Semver 2.0.0](https://semver.org/), versions `0.x.x` indicate "initial development" where anything may change. Version `1.0.0` should signal a stable public release.

## Current State

```xml
<key>CFBundleShortVersionString</key>
<string>1.0</string>

<key>CFBundleVersion</key>
<string>1</string>
```

## Recommended Fix

```xml
<key>CFBundleShortVersionString</key>
<string>0.1.0</string>

<key>CFBundleVersion</key>
<string>1</string>
```

## Versioning Strategy

- **0.1.0** - Current state (craving + usage logging works)
- **0.2.0** - Recordings feature complete
- **0.3.0** - Onboarding flow complete
- **0.9.0** - Feature complete, ready for beta testing
- **1.0.0** - Public App Store release

## Acceptance Criteria

- [x] `CFBundleShortVersionString` set to `0.1.0`
- [x] Settings screen shows `0.1.0 (1)` (reads from bundle info)
- [x] Document version strategy in `AGENTS.md` / `CLAUDE.md`
