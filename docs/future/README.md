# Future Features

These specs are **deferred** (planning docs). The stabilization gate is currently green, but these features are not in scope unless explicitly prioritized.

**Do NOT implement** anything from these docs unless it is the active, agreed-upon workstream.

## Contents

| Document | Original Name | Feature |
|----------|--------------|---------|
| `ONBOARDING_SPEC.md` | PHASE_3 | WelcomeView, TourView |
| `RECORDINGS_SPEC.md` | PHASE_4 | AVFoundation, recording UI |
| `LAUNCH_SPEC.md` | PHASE_6 | TestFlight, App Store |

## Why Deferred

Even with a green build/test gate, adding new features should be deliberate:
- Keep `bash scripts/verify.sh` green at every step.
- Track any non-blocking improvements in `docs/bugs/` or `docs/debt/` instead of sneaking scope.
