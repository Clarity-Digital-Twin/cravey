# Cravey Implementation Phases - Overview

> ⚠️ Archived: Superseded planning doc. Not current SSOT.

**Version:** 2.0
**Last Updated:** 2025-01-05
**Status:** 🎯 PHASE 3/4 NEXT (Onboarding + Recordings)

---

## 📊 Current Implementation Status

| Phase | Description | Status | Notes |
|-------|-------------|--------|-------|
| PHASE_1 | Craving Logging | ✅ **COMPLETE** | Archived |
| PHASE_2 | Usage Logging | ✅ **COMPLETE** | Archived |
| PHASE_3 | Onboarding + Data Management | ⚠️ **PARTIAL** | Settings done, Onboarding NOT started |
| PHASE_4 | Recordings | ❌ **NOT STARTED** | Data models only, no UI |
| PHASE_5 | Dashboard | ✅ **COMPLETE** | Archived |
| PHASE_6 | Polish, Testing & Launch | 🔄 **IN PROGRESS** | UI/UX polish done, launch prep pending |

---

## ✅ What's Built (As of 2025-01-05)

### Core Features Working:
- **Craving Logging** - Full form with intensity, triggers, location, notes
- **Usage Logging** - Full form with ROA picker, amounts, triggers
- **Dashboard** - 5 metric cards (streak, intensity trends, triggers, weekly summary)
- **Settings** - Export data, delete all data
- **Home Screen** - Lists cravings + usage, toast notifications

### Technical Foundation:
- Clean Architecture (Domain → Data → Presentation)
- SwiftData persistence (local-only, no CloudKit)
- iOS 18+ modern APIs (sensoryFeedback, symbolEffect, scrollTransition)
- 32 unit tests passing

---

## 🔜 What's NOT Built Yet

### PHASE_3: Onboarding (Missing)
- WelcomeView
- TourView (60-second app tour)
- First-launch detection

### PHASE_4: Recordings (Missing)
- AudioRecordingCoordinator (AVAudioRecorder)
- VideoRecordingCoordinator (AVCaptureSession)
- Recording library UI
- Audio/video playback
- Quick Play section on Home
- Thumbnail generation

### PHASE_6: Launch Prep (Pending)
- TestFlight setup
- App Store assets (screenshots, description)
- Privacy policy
- Support page

---

## 📦 Phase Navigation

### Active Phases:
- **[PHASE_3: Onboarding + Data Management](./PHASE_3.md)** - Onboarding NOT done
- **[PHASE_4: Recordings](./PHASE_4.md)** - NOT started
- **[PHASE_6: Polish, Testing & Launch](./PHASE_6.md)** - UI polish done, launch pending

### Archived (Completed):
- `docs/archive/PHASE_1_IMPLEMENTED_2025-01-05.md` - Craving Logging
- `docs/archive/PHASE_2_IMPLEMENTED_2025-01-05.md` - Usage Logging
- `docs/archive/PHASE_5_IMPLEMENTED_2025-01-05.md` - Dashboard

---

## 🎯 Recommended Next Steps

1. **Swipe-to-Delete** - Home screen needs delete functionality (see PROMPT.md)
2. **Home Screen Title** - Change from "Home" to something meaningful
3. **Onboarding** - Build WelcomeView + TourView (PHASE_3)
4. **Recordings** - Build AVFoundation integration (PHASE_4)

---

## 📚 Reference Documents

- **[CLAUDE.md](../../CLAUDE.md)** - Architecture & development context
- **[PROMPT.md](../../PROMPT.md)** - Current Ralph Wiggum loop task
- **[MVP_PRODUCT_SPEC.md](../MVP_PRODUCT_SPEC.md)** - Feature requirements
- **[TECHNICAL_IMPLEMENTATION.md](../TECHNICAL_IMPLEMENTATION.md)** - Master spec
