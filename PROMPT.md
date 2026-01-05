# Cravey – Ralph Wiggum Loop Prompt (Convergent)

## Mission
Produce an iOS 18+ Cravey build that is **“APP STORE READY” by the objective definition below**.

**Important:** In this loop, “APP STORE READY” is a *technical* bar (build/tests/lint/assets). It does **not** include App Store Connect submission or human taste judgments.

## Hard Constraints (must not violate)
- **Privacy-first:** local-only data; no analytics; no tracking; no cloud sync; keep SwiftData `cloudKitDatabase: .none`.
- **Clean Architecture:** Presentation → Domain ← Data; Domain stays framework-free (no SwiftUI/SwiftData).
- **Motivational interviewing tone:** non-judgmental language (avoid “failure”, “streak broken”).

## Non-Goals (cannot be completed in an AI loop)
- App Store Connect setup, signing/provisioning/certificates, uploading builds, submitting for review.
- Marketing assets and human-judgment work (real icon design, screenshot selection, copywriting, legal privacy policy text).

## How to Iterate (to converge)
1. Run **Verification (full)** exactly as written.
2. Fix the *first* failing gate only (smallest coherent slice).
3. Add/adjust tests to prevent regressions.
4. Re-run the same failing gate until it passes.
5. Repeat until all gates pass, then output the completion signal.

## Current Baseline (repo truth)
- Working: Home tab (log + list cravings and usage) with SwiftData persistence and DI.
- Passing: `CraveyTests` via `xcodebuild test … -only-testing:CraveyTests`.
- Not done: `DashboardView` and `SettingsView` are placeholders.
- Stubs: `DependencyContainer` uses stub recording/message repositories.
- Formatting: `swiftformat --lint` currently fails (7/57 files).
- Linting: `swiftlint` reports 17 warnings (TODOs, function_parameter_count).
- UI tests: `CraveyUITests` currently fail (out-of-date selectors/expectations).
- Assets: `Cravey/Resources/Assets.xcassets/` directory does NOT exist - must be created with AppIcon, LaunchIcon, LaunchScreenBackground.

---

## Definition of Done (objective)
When **ALL** commands in **Verification (full)** and **Verification (hard checks)** succeed with exit code `0`, output:

```
<promise>APP STORE READY</promise>
```

---

## Verification (full)
Run exactly these commands (order matters):

```bash
set -euo pipefail

# Tooling (fail fast if the environment is missing prerequisites)
xcodebuild -version
xcodegen --version
swiftlint version
swiftformat --version
xcbeautify --version

# Project generation (project.yml is SSOT for the Xcode project)
xcodegen generate

# Formatting + lint
swiftformat --lint --swiftversion 6.0 .
swiftlint

# Unit + integration tests (Swift Testing in CraveyTests)
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests | xcbeautify

# UI tests (XCTest in CraveyUITests)
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyUITests | tee /tmp/cravey-uitests.log | xcbeautify
rg -n 'Executed [1-9][0-9]* tests' /tmp/cravey-uitests.log >/dev/null

# Release build must not emit iOS 18 deprecation warnings
xcodebuild -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -configuration Release \
  build | tee /tmp/cravey-release-build.log | xcbeautify
! rg -n 'deprecated in iOS 18\\.0' /tmp/cravey-release-build.log
```

## Verification (hard checks)
These must also succeed with exit code `0`:

```bash
set -euo pipefail

# No shipping-path stubs/placeholders
! rg -n 'StubRecordingRepository|StubMessageRepository' Cravey/App/DependencyContainer.swift
! rg -n 'Coming in Phase' Cravey/Presentation/Views/Dashboard/DashboardView.swift
! rg -n 'TODO:' Cravey/Presentation/Views/Dashboard/DashboardView.swift Cravey/Presentation/Views/Settings/SettingsView.swift

# App Store minimum assets referenced by Info.plist (must exist on disk)
test -d Cravey/Resources/Assets.xcassets/AppIcon.appiconset
test -f Cravey/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json
test -d Cravey/Resources/Assets.xcassets/LaunchIcon.imageset
test -d Cravey/Resources/Assets.xcassets/LaunchScreenBackground.colorset
```

---

## Functional Scope Required for Done (must be enforced by tests)
To prevent “false completion”, `CraveyUITests` must deterministically validate:
- App launches, tab bar is visible, and Home shows both empty states when there is no data.
- Log Craving flow completes and Home updates accordingly.
- Log Usage flow completes in <10 seconds and Home updates accordingly.
- Dashboard tab renders the 5 MVP metric cards (streaks, intensity trend, top triggers, weekly summary).
- Settings tab supports Export (JSON minimum) and Delete All Data (with confirmation), and delete clears Home lists.

**UI test stability rules:**
- Use explicit `accessibilityIdentifier`s; do not rely on SF Symbol names or localized strings.
- No screenshot tests required for completion.
- Avoid `sleep()`; prefer `waitForExistence(timeout:)` and predicates.

---

## Context / Reference (do not treat as acceptance criteria)
- Tier 1 specs: `docs/MVP_PRODUCT_SPEC.md`, `docs/UX_FLOW_SPEC.md`, `docs/CLINICAL_CANNABIS_SPEC.md`, `docs/DATA_MODEL_SPEC.md`
- Phase guides: `docs/phases/PHASE_3.md` (Settings/Data Management), `docs/phases/PHASE_5.md` (Dashboard)
- Architecture: `AGENTS.md`, `ARCHITECTURE.md`, `CLAUDE.md`
