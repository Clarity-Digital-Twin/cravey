# Cravey Documentation Checkpoint & Status

**Last Updated:** 2025-10-18
**Current Phase:** Planning & Validation (Pre-Implementation)

---

## 📊 Overall Status: 90% Complete (3/4 Planning Docs Done)

| Phase | Status | Progress |
|-------|--------|----------|
| **Phase 1: Planning & Validation** | 🟡 In Progress | 90% (3/4 docs) |
| **Phase 2: Implementation** | ⚪ Not Started | 0% |
| **Phase 3: Testing & Launch** | ⚪ Not Started | 0% |

---

## 📋 Documentation Roadmap

### ✅ COMPLETED

#### 1. `MVP_PRODUCT_SPEC.md` (v1.3) - **FULLY UPDATED** ✅
**Status:** ✅ Complete
**Last Updated:** 2025-10-18 (Comprehensive update with all validated UX/dashboard decisions)
**What It Defines:**
- Vision, target users, core problems solved
- 7 MVP features (Onboarding, Craving Logging, Usage Logging, Recordings, Dashboard, AI Chat, Data Management)
- Success criteria (Technical, User, Ethical)
- Out of scope items (UPDATED with all deferred features)
- **Appendix A:** ROA amounts, HAALT trigger categories, location presets (FULLY VALIDATED)
- **Appendix B:** Data relationship & deletion rules

**Key Decisions Made:**
- iOS 18+ only (initial release)
- Local-only storage (SwiftData with `.none` CloudKit)
- <10 sec for both craving and usage logging
- **CRITICAL:** Craving and usage logging are INDEPENDENT (no forced link)
- **UX Parity:** Both flows use same UI pattern (single scrollable form, Apple HIG)
- 6 ROA categories with validated picker ranges (Bowls/Joints/Blunts: 0.5→5.0, Vape: 1→10, Dab: 1→5, Edible: 5→100mg)
- HAALT-based triggers (Hungry/Angry/Anxious/Lonely/Tired/Sad + Bored/Social/Habit/Paraphernalia)
- Location tracking for BOTH craving & usage (GPS + 6 presets)
- **11 validated dashboard metrics** (summary card, amount trends, trigger/location/time/ROA breakdowns, streaks, craving intensity)
- **Goal tracking DEFERRED to post-MVP** (focus on polished logging first)
- **THC potency tracking SKIPPED** (false precision, clinically useless)
- **Medical vs recreational distinction SKIPPED** (triggers capture "why" without stigma)
- Permission denial fallbacks documented
- Delete behavior for all relationships defined

**Why It's Done:**
- Provides north star for all other docs
- Defines product-level "what" before technical "how"
- 100% aligned with clinically validated tracking model
- All UX decisions documented with clinical rationale

---

#### 2. `CLINICAL_CANNABIS_SPEC.md` - **100% COMPLETE** ✅🔥
**Status:** ✅ All Clinical Validations Done
**Last Updated:** 2025-10-18
**Owner:** Ray (Domain Expert - Psychiatrist/Addiction Medicine)

**What It Defines:**
- ROA categories & amounts with UX-ready picker wheel ranges
- Craving intensity scale (1-10 slider with clinical interpretation)
- **CRITICAL INSIGHT:** Independent flows (craving logging ≠ usage logging)
- **Complete Craving Logging UX flow** (intensity, timestamp, triggers, location, notes)
- **Complete Usage Logging UX flow** (ROA, amount, timestamp, triggers, location, notes)
- HAALT-based trigger chips (multi-select, evidence-based)
- Location presets with GPS (single-select, privacy-first)
- UI pattern: Single scrollable form (Apple HIG) for both flows
- **Dashboard metrics validated** (11 metrics for MVP, 3 deferred to post-MVP)
- **Scope decisions resolved** (THC potency, medical/rec distinction, goal tracking)

**Key Decisions Made:**
- UX parity between craving & usage logging (learn once, use everywhere)
- Location tracking for BOTH flows (environmental cues = relapse prevention)
- Editable timestamps with >7 day warning (supports backdating for missed logs)
- 500 char limit on notes (focused reflection, not journaling)
- Removed "Mood After" from usage logging (redundant with triggers)
- Picker wheel consistency across all ROAs (simpler UX, less code)
- Dashboard focuses on patterns over time (trends, not single data points)
- Visual simplicity (pie/line/bar charts) for quick insights

**Why It's Done:**
- ALL core logging flows clinically validated and build-ready
- ALL dashboard metrics validated with clinical rationale
- ALL open questions resolved (THC potency, medical/rec, goals = deferred/skipped)
- Feeds into UX_FLOW_SPEC.md (wireframes) and DATA_MODEL_SPEC.md (SwiftData schemas)
- Domain expert validation 100% complete - ready for implementation

---

### 🚧 IN PROGRESS / NEXT UP

#### 3. `UX_FLOW_SPEC.md` - **AFTER CLINICAL SPEC**
**Status:** 🔴 Not Started
**Priority:** HIGH (blocks UI implementation)

**Purpose:**
Map user journeys and screen flows to understand how the app FEELS to use.

**What It Should Define:**
1. **Onboarding Flow**
   - Welcome screen → Permissions (contextual) → Tour (optional) → Home
   - What if user denies camera? Denies mic? Denies both?
   - **Note:** Goal setting removed for MVP (deferred to v1.1)

2. **Craving Logging Flow**
   - Home → "Log Craving" button → Quick form (<10 sec)
   - Required: Intensity (1-10 slider), Timestamp (auto "now", editable)
   - Optional: Trigger (HAALT chips), Location (GPS + presets), Notes
   - Return to home with feedback message
   - **Note:** Independent from usage logging (no "outcome" field)

3. **Usage Logging Flow**
   - Home → "Log Usage" → Form (<10 sec)
   - Required: ROA selection, Amount (picker wheel), Timestamp (auto "now", editable)
   - Optional: Trigger (HAALT chips), Location (GPS + presets), Notes
   - Save → Return to home
   - **Note:** Mood field removed (redundant with triggers)

4. **Recording Flow**
   - Home → "Recordings" → Record new (camera/mic permissions required)
   - If denied → "Enable in Settings" message
   - Record (max 2 min) → Title → Category → Save
   - Play during craving → Home → "Recordings" → Select → Play

5. **Dashboard Flow**
   - Home → "Progress" tab
   - If <7 days: Empty state ("Keep logging!")
   - If 7+ days: Charts (usage frequency, craving patterns, resistance rate, ROA breakdown)
   - Date range filter (7/30/90/All Time)
   - Progress stats cards

6. **AI Chat Flow (Optional)**
   - Settings → AI Support → Enter API key
   - Validation (OpenAI vs. Anthropic format)
   - Keychain save with biometric prompt
   - Home → "Chat" → Text input → Ephemeral session
   - Error states (invalid key, rate limit, quota)

7. **Data Management Flow**
   - Settings → Data Management → Export (CSV/JSON)
   - Settings → Data Management → Advanced → Delete All (confirmation)
   - In-app delete: Swipe-to-delete on logs, long-press on recordings

**Why This Matters:**
- Forces you to think through every user decision point
- Catches UX ambiguities before coding
- Example: "What happens if user denies location permission but taps 'Current Location'?" (Fallback: Show alert, require manual selection from presets)

**How to Write It:**
- Casual wireframe descriptions (not pixel-perfect designs)
- Focus on STATE CHANGES: "User taps X → Screen shows Y → If Z, then..."
- Call out empty states, error states, loading states
- Can use ASCII diagrams or just bullet points

**Output:**
- Screen-by-screen flows
- Decision trees (if/then logic for user paths)
- Identifies missing UI states
- Feeds into VIEW implementations (SwiftUI screens)

---

#### 4. `DATA_MODEL_SPEC.md` - **AFTER CLINICAL & UX SPECS**
**Status:** 🔴 Not Started
**Priority:** MEDIUM (technical foundation)

**Purpose:**
Define exact SwiftData schemas, relationships, and persistence logic.

**What It Should Define:**
1. **SwiftData Models**
   - `CravingModel` - All fields, types, optionality
   - `UsageModel` - All fields, types, optionality
   - `RecordingModel` - All fields, types, optionality
   - `MotivationalMessageModel` (if needed for v1)
   - **Note:** `UserGoalModel` deferred to post-MVP (v1.1)

2. **Relationships**
   - Craving ↔ Recording (many-to-one, `.nullify` delete rule)
   - **Craving and Usage are INDEPENDENT** (no relationship, separate logs)
   - Validation of Appendix B delete rules

3. **Performance Constraints**
   - <5 sec craving log (what query optimizations?)
   - <10 sec usage log (what indexes needed?)
   - Chart rendering with 90+ days of data (fetch limits?)

4. **CloudKit Configuration**
   - `ModelConfiguration(cloudKitDatabase: .none)` - Explicitly disabled
   - Confirm no iCloud sync

5. **Clean Architecture Mapping**
   - Which layer owns each model? (Data layer)
   - How do Domain entities map to Data models? (Mappers)
   - Repository protocols (already exist in CLAUDE.md)

**Why This Matters:**
- Technical source of truth for implementation
- Ensures SwiftData relationships match product spec
- Catches data integrity issues before coding

**How to Write It:**
- Technical doc (code examples, Swift types)
- References CLAUDE.md for existing patterns
- Uses decisions from CLINICAL_CANNABIS_SPEC.md
- Uses flows from UX_FLOW_SPEC.md

**Output:**
- Exact SwiftData model definitions
- Relationship delete rules in code
- Migration strategy (if schema changes)
- Feeds into implementation (copy-paste ready)

---

#### 5. `TECHNICAL_IMPLEMENTATION.md` - **FINAL PLANNING DOC**
**Status:** 🔴 Not Started
**Priority:** LOW (implementation roadmap)

**Purpose:**
Map features to code (repos, use cases, views) and define build order.

**What It Should Define:**
1. **Architecture Layers**
   - Domain: Entities, Use Cases, Repository Protocols
   - Data: Models, Repositories, Mappers, Storage
   - Presentation: Views, ViewModels
   - App: DependencyContainer, CraveyApp.swift

2. **Implementation Order** (16-week plan from MVP spec)
   - Phase 1 (Weeks 1-4): Craving, Usage, Onboarding, Data Management
   - Phase 2 (Weeks 5-8): Recordings, Dashboard
   - Phase 3 (Weeks 9-12): AI Chat, Polish
   - Phase 4 (Weeks 13-16): TestFlight, Launch

3. **Module Boundaries**
   - Which features are independent? (can be built in parallel)
   - Which features depend on others? (must be sequential)

4. **Testing Strategy**
   - Unit tests (Use Cases, Mappers)
   - Integration tests (Repositories)
   - UI tests (Critical flows: <5 sec craving log)

5. **Tooling & Scripts**
   - Build commands (xcodegen, xcodebuild, xcbeautify)
   - Test commands (unit vs. UI)
   - Linting/formatting (swiftlint, swiftformat)

**Why This Matters:**
- Guides daily coding decisions
- Prevents "what do I build next?" paralysis
- Ensures Clean Architecture is maintained

**How to Write It:**
- Technical implementation guide
- References CLAUDE.md for existing structure
- Task breakdown (can feed into GitHub Issues/Projects)

**Output:**
- Feature → Code mapping
- Build order (prioritized backlog)
- Testing checklist
- Ready to start coding

---

## 🎯 Current Position: You Are Here

```
✅ MVP_PRODUCT_SPEC.md (v1.2) - UPDATED with fully validated UX data
    ↓
✅ CLINICAL_CANNABIS_SPEC.md (100% complete) - BOTH LOGGING FLOWS VALIDATED 🔥🔥🔥
    ↓
🔴 UX_FLOW_SPEC.md ← YOU ARE HERE (next to create)
    ↓
🔴 DATA_MODEL_SPEC.md
    ↓
🔴 TECHNICAL_IMPLEMENTATION.md
    ↓
🚀 START CODING (Phase 1)
```

---

## 🧠 Why This Order Makes Sense

### Traditional (Wrong) Order:
1. ❌ Write technical specs first
2. ❌ Start coding
3. ❌ Realize product model is wrong
4. ❌ Refactor everything

### Your (Correct) Order:
1. ✅ **Product spec** (what are we building?)
2. ✅ **Clinical validation** (is the model correct?)
3. ✅ **UX flows** (how does it feel to use?)
4. ✅ **Technical spec** (how do we build it?)
5. ✅ **Implementation plan** (in what order?)
6. ✅ Start coding (with confidence)

**This is called "Domain-Driven Design"** - the domain expert (you) validates the model before engineers build it.

---

## 📝 Next Actions

### When You Return to This Project:

1. **Read this file** (`CHECKPOINT_STATUS.md`)
2. **Check the "YOU ARE HERE" marker** (currently: UX_FLOW_SPEC.md)
3. **Choose your path:**
   - **Option A (Recommended):** Create UX_FLOW_SPEC.md (wireframe screen-by-screen flows)
   - **Option B:** Scan for remaining unanswered questions across all docs
   - **Option C:** Jump to DATA_MODEL_SPEC.md (define SwiftData schemas)
4. **Update this file** when you complete a doc (move ✅, update "YOU ARE HERE")

---

## 🚀 Immediate Next Step: Create UX_FLOW_SPEC.md

**✅ CLINICAL_CANNABIS_SPEC.md is 100% COMPLETE.** Both logging flows fully validated. 🔥🔥🔥

**Next: UX_FLOW_SPEC.md**
- Document screen-by-screen wireframe flows
- Map user journeys (onboarding, craving logging, usage logging, recordings, dashboard)
- Define navigation patterns, button placements, error states
- Translate clinical validation into tangible UI mockups

**Why this matters:**
- Visual thinking reveals UX gaps that text specs miss
- Helps you "feel" the app before building it
- Unblocks UI implementation (SwiftUI views)

---

## 📞 How to Use This Doc

- **Reference:** Check "YOU ARE HERE" when you return to the project
- **Update:** Mark docs ✅ when complete, move the "YOU ARE HERE" marker
- **Brainstorm:** Use "What It Should Define" sections as writing prompts
- **Validate:** Ensure each doc feeds into the next (dependencies)

---

**Status:** CHECKPOINT FILE ACTIVE - Update as you complete docs 🚀
