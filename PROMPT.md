# Cravey – Ralph Wiggum Loop Prompt (Loop-Ready Gate)

## Mission
Make this repo reliably converge inside an automated AI loop by enforcing a single, objective quality gate: project generation, formatting, linting, and unit tests must all pass.

This prompt intentionally avoids anything that requires human judgment (UX “feels good”, manual simulator tapping, etc.).

---

## Hard Constraints (must not violate)
- **Privacy-first:** local-only data; no analytics; no tracking; no cloud sync; keep SwiftData `cloudKitDatabase: .none`.
- **Clean Architecture:** Presentation → Domain ← Data; Domain stays framework-free (no SwiftUI/SwiftData imports).
- **Swift 6 strict concurrency:** no concurrency escape hatches in Presentation; SwiftData access must be MainActor/ModelActor safe.
- **iOS 18+ minimum deployment target** (Mac Catalyst is allowed for CI testing).

---

## In Scope (this loop)
- Make **every claim of completion** provable by commands with non-zero exits on failure.
- Keep verification stable in headless/CI environments (prefer Mac Catalyst for tests; use an iOS Simulator compile check when available).
- Update only what is required to make the gate pass; log any follow-ups as bugs in `docs/bugs/`.

---

## Out of Scope / Cannot Be Done In A Loop
- App Store submission (certificates, provisioning profiles, TestFlight/App Store Connect).
- Designing app icons, marketing screenshots, or any subjective UI/UX evaluation.
- Any manual “open app and check” steps.

---

## Definition of Done (objectively verifiable)
The loop is complete **only when** the verification script exits 0:

```bash
bash scripts/verify.sh
```

### What `scripts/verify.sh` runs (for transparency)
- `xcodegen generate`
- `swiftformat --lint --swiftversion 6.0 .`
- `swiftlint lint --quiet`
- `xcodebuild build` for iOS Simulator (compile check; prefers `IOS_SIMULATOR_NAME=iPhone 17 Pro` with fallback)
- `xcodebuild test` for `CraveyTests` on **Mac Catalyst** with code signing disabled
- Static invariants:
  - `cloudKitDatabase: .none` present
  - No `import SwiftUI` / `import SwiftData` in `Cravey/Domain`

---

## Completion Output Contract
When (and only when) the Definition of Done passes, output exactly:

```
<promise>LOOP READY</promise>
```

---

## Convergence Guardrails (avoid infinite loops / false completion)
- **Never** claim completion unless `bash scripts/verify.sh` is green.
- Don’t “warn and continue” on a failed check; failed checks must stop the loop.
- Avoid unrelated refactors; if you find a non-blocking improvement, log it in `docs/bugs/` and stop.
- If tooling is missing, stop and output:

```
<blocker>MISSING TOOL: <name></blocker>
```

with the exact command name (e.g., `xcodegen`, `swiftformat`, `swiftlint`, `xcodebuild`).
