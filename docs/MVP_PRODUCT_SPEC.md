# Cravey MVP Product Specification

**Version:** 1.0
**Last Updated:** 2025-10-12
**Status:** Draft - Awaiting Review & Convergence

---

## Vision

**Cravey is a private, judgment-free iOS app that helps cannabis users understand their relationship with cannabis—whether they want to monitor use, reduce consumption, quit entirely, practice harm reduction, or simply track metrics for self-awareness.**

---

## Target User

**Primary Persona:**
Someone who uses cannabis and wants to:
- **Monitor their use** - Track patterns and understand habits
- **Cut down** - Reduce frequency or amount consumed
- **Stop completely** - Quit cannabis use
- **Harm reduction** - Maintain use at a specific, intentional level
- **Track metrics** - Data-driven self-awareness without judgment

**Shared Characteristics:**
- Values **privacy** - Doesn't want data shared with companies or cloud services
- Wants **self-compassion** - No shame, no streaks that "break," no punishment language
- May be in **vulnerable moments** - Needs fast, simple UI during cravings
- Wants **evidence-based support** - MI (Motivational Interviewing) principles, not lecturing
- May be tech-savvy enough to use their own AI API key for coaching

---

## Core Problems Solved

1. **Hard to track cannabis use without judgment or data privacy concerns**
   → Most apps require cloud accounts or sell data. Users want local-only tracking.

2. **Hard to resist cravings in the moment**
   → Users want to record motivational content when sober (video/audio messages to their future self) and replay during cravings.

3. **Hard to see patterns and progress over time**
   → Users want visual metrics (charts, trends) to understand their usage behavior.

4. **Hard to access non-judgmental support**
   → Users want an MI-trained AI coach available 24/7, but without sharing data with the app maker.

---

## MVP Features (v1.0)

### 1. Cannabis Usage Logging
**User Story:**
*"I want to quickly log when and how I use cannabis so I can see patterns over time."*

**Functionality:**
- **Fast input form** - Log in <10 seconds
- **Data captured:**
  - **Date/Time** - Auto-populated, editable
  - **Amount** - Relative scale (half bowl, full bowl, small joint, large joint, short hit, long hit, small dab, large dab, edible dose)
  - **ROA (Route of Administration):**
    - Joint
    - Blunt
    - Bowl
    - Bong
    - Concentrate Pen (vape)
    - Dab Rig
    - Edible
    - Other (custom)
  - **Location** - Optional, only if user grants permission
  - **Trigger/Context** - Optional notes (e.g., "stress," "social," "boredom")
  - **Mood Before/After** - Optional 1-10 scale

**Why It Matters:**
Understanding *when*, *how*, and *why* they use helps users identify patterns and make informed decisions about their consumption.

---

### 2. Pre-Recorded Motivational Content
**User Story:**
*"I want to record a video or voice message to my future self when I'm sober, so I can watch/listen during a craving."*

**Functionality:**
- **Record Video/Audio Messages** - When NOT experiencing a craving
  - Title the recording (e.g., "Why I'm Taking a Break," "Remember Your Goals")
  - Add notes/context
- **Replay During Cravings** - Easy access during vulnerable moments
  - Large, clear "Play" button
  - Organized by purpose (motivational, milestone, reflection)
- **Privacy** - All recordings stored locally on device (never uploaded)

**Why It Matters:**
Hearing your own voice/seeing your own face when you're clear-headed is more powerful than generic motivational quotes. Creates a personal accountability loop.

---

### 3. Usage Metrics Dashboard
**User Story:**
*"I want to see my usage trends over time so I can understand my progress."*

**Functionality:**
- **Visual Charts** (Swift Charts)
  - Daily/weekly/monthly usage frequency
  - Amount consumed over time
  - ROA breakdown (e.g., "80% joints, 20% edibles")
  - Time-of-day patterns (e.g., "Most use is 7-10pm")
- **Progress Indicators**
  - Days since last use (if quitting)
  - Reduction % (if cutting down)
  - Longest streak (if applicable)
  - Total sessions logged

**Why It Matters:**
Seeing patterns helps users make intentional changes. Visual feedback motivates continued progress.

---

### 4. Optional AI Support (Bring Your Own API Key)
**User Story:**
*"I want to chat with an MI-trained coach without sharing my data with the app developer."*

**Functionality:**
- **User Provides API Key** - OpenAI or Anthropic (user's own account)
- **System Prompt** - Pre-configured as MI (Motivational Interviewing) expert for cannabis cravings
  - Non-judgmental
  - Reflective listening
  - Open-ended questions
  - Supports user autonomy
- **Local Storage Only** - Conversations stored on device, never sent to Cravey servers
- **Optional Feature** - Users can skip this if they don't want AI support

**Why It Matters:**
24/7 access to evidence-based support without sacrificing privacy. Users control their own API costs and data.

---

## Out of Scope for MVP

### Not Included in v1.0:
- **Cloud sync** - 100% local-only for privacy
- **Social features** - No sharing, no community forums
- **Prescription tracking** - Medical cannabis features (future consideration)
- **macOS version** - iOS-only first (macOS planned for future)
- **Pre-populated motivational quotes** - User-generated content only (may add later)
- **Integration with other apps** - No HealthKit, no calendar sync (future consideration)

---

## Success Criteria

An MVP is successful if:

1. **User can log cannabis use in <10 seconds** - Minimal friction during logging
2. **User can record and replay motivational content** - Video/audio recording works reliably
3. **User can view usage trends over 30+ days** - Charts display meaningful patterns
4. **User can chat with AI coach (BYOK)** - API integration works with user's key
5. **All data stays on device** - Zero network calls except user's own API
6. **App feels supportive, not judgmental** - Language reflects MI principles

---

## Privacy & Ethics Commitments

1. **No Data Collection** - App never sends usage data to any server (except user's own AI API)
2. **No Analytics** - No Firebase, no Mixpanel, no tracking SDKs
3. **No Ads** - Never monetized via ads or data sales
4. **Local-Only Storage** - SwiftData with CloudKit disabled (`.none`)
5. **Motivational Interviewing Language** - No shame, no punishment, no "failure" framing

---

## User Experience Principles

1. **Fast & Simple** - Users may be in crisis. Large buttons, clear CTAs, minimal steps.
2. **Private by Default** - No account creation, no login, no cloud sync.
3. **Compassionate Language** - "You're doing great" not "You failed."
4. **Data Transparency** - Users can export/delete all data anytime.
5. **Accessible** - High contrast, VoiceOver support, Dynamic Type.

---

## Technical Constraints (High-Level)

- **Platform:** iOS 18+ only (initial release)
- **Architecture:** Clean Architecture + MVVM
- **Storage:** SwiftData (local-only)
- **UI:** SwiftUI
- **Recording:** AVFoundation
- **Charts:** Swift Charts
- **AI:** User's own API key (OpenAI/Anthropic)

---

## Next Steps

1. **Review & Critique** - Use AI agent to validate completeness, clarity, and alignment with user needs
2. **Converge on Final Version** - Incorporate feedback and lock in v1.0 spec
3. **Create Data Model Spec** - Define exact logging schema (ROA details, amounts, triggers)
4. **Create UX Flow Spec** - Wireframe user journeys, interaction patterns
5. **Create Technical Implementation Plan** - Map features to SwiftUI views, use cases, repositories

---

**Status:** Ready for Review 🚀
