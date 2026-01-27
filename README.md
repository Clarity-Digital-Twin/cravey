# Cravey - Cannabis Tracking & Cessation Support (iOS)

A modern, privacy-first **iOS 18+** app built with SwiftUI + SwiftData to help users log cravings and cannabis use, understand patterns, and stay compassionate during hard moments.

## Status

Pre-release. The objective quality gate is `bash scripts/verify.sh` (project generation, formatting, linting, invariants, simulator compile check, unit tests).

## Features (Implemented)

- **Craving logging**: Intensity (1–10), HAALT triggers, location presets, notes, timestamp
- **Usage logging**: ROA method + clinically-validated amount ranges, triggers, location, notes, timestamp
- **Progress dashboard**: Streaks, averages, top triggers, weekly summary
- **Settings**: Export data (CSV/JSON), delete all local data
- **Privacy**: Local-only storage (SwiftData CloudKit disabled), no analytics/tracking

## Planned / Scaffolded (Not Implemented Yet)

- **Motivational recordings** (audio/video via AVFoundation): models/entities exist; capture/playback UI + repository/use cases pending
- **Motivational messages**: model exists; selection UI/use cases pending
- **Onboarding**: welcome/tour flow pending

## Development

```bash
./setup-tools.sh
xcodegen generate
bash scripts/verify.sh
```

## Architecture

Clean Architecture + MVVM:
- `Cravey/Domain/` stays framework-free (no SwiftUI/SwiftData imports)
- `Cravey/Data/` implements persistence via SwiftData
- `Cravey/Presentation/` is SwiftUI + @Observable ViewModels

See `docs/GETTING_STARTED.md` and `docs/ARCHITECTURE.md` for details.

## App Configuration Templates

- iOS Info.plist template: `Config/iOS.Info.plist.template`
- macOS Info.plist template: `Config/macOS.Info.plist.template`
