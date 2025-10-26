# Cravey Documentation Checkpoint & Status

**Last Updated:** 2025-10-25
**Current Phase:** Planning & Validation (Pre-Implementation)

---

## 📊 Overall Status: 60% Complete (3/5 Planning Docs Done)

| Phase | Status | Progress |
|-------|--------|----------|
| **Phase 1: Planning & Validation** | 🚧 IN PROGRESS | 60% (3/5 docs) |
| **Phase 2: Implementation** | ⚪ Not Started | 0% |
| **Phase 3: Testing & Launch** | ⚪ Not Started | 0% |

---

## 📋 Documentation Roadmap

### ✅ COMPLETED

#### 1. `MVP_PRODUCT_SPEC.md` (v1.4) - **FULLY UPDATED** ✅
**Status:** ✅ Complete
**Last Updated:** 2025-10-25 (AI Chat removed, all UX flows complete)
**File:** `/docs/MVP_PRODUCT_SPEC.md`
**What It Defines:**
- Vision, target users, core problems solved
- 6 MVP features (Onboarding, Craving Logging, Usage Logging, Recordings, Dashboard, Data Management)
- **AI Chat REMOVED** (gimmicky, API cost unsustainable, recordings feature provides better support)
- Success criteria (Technical, User, Ethical)
- Out of scope items (UPDATED with all deferred features including AI chat)
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
- **AI chat REMOVED from MVP** (deferred indefinitely, recordings are better)
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
**File:** `/docs/CLINICAL_CANNABIS_SPEC.md`

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

#### 3. `UX_FLOW_SPEC.md` (v1.2) - **100% COMPLETE** ✅🔥
**Status:** ✅ Complete (7/7 flows)
**Last Updated:** 2025-10-25
**File:** `/docs/UX_FLOW_SPEC.md`

**Purpose:**
Map user journeys and screen flows to understand how the app FEELS to use.

**✅ ALL FLOWS COMPLETED:**

1. **✅ Flow 1: Onboarding** (2 screens)
2. **✅ Flow 2: Home Tab** (2 screens)
3. **✅ Flow 3: Craving Logging** (1 screen)
4. **✅ Flow 4: Usage Logging** (1 screen)
5. **✅ Flow 5: Recordings Tab** (10 screens)
   - Empty state, permissions, mode choice, recording screens, preview/save, library, playback, edit, delete
6. **✅ Flow 6: Progress Dashboard Tab** (1 screen)
   - Single scrollable feed with 11 metrics
   - Sticky date filters (7D/30D/90D/All)
   - Static charts for MVP (defer interactivity to v2)
   - Contextual insights even with sparse data (2 data points)
   - Show from Day 1 (no gating)
7. **✅ Flow 7: Settings Tab** (3 screens)
   - Main settings (simple iOS list pattern)
   - Export via Share Sheet (CSV/JSON)
   - Delete all data (single confirmation)
   - **AI chat removed** (not in Settings, not in MVP)

**Total Screens Designed:** 19 screens fully specified

**Major Design Decisions Locked:**
- ✅ Component library (8 reusable components defined)
- ✅ Crisis-optimized UX principles (large tap targets, minimal decisions)
- ✅ UX parity between craving/usage (same form pattern, learn once)
- ✅ Independent craving and usage flows (no forced linking)
- ✅ Upfront video/audio mode choice (prevents accidents)
- ✅ Simple record/stop (no pause, encourages re-recording authenticity)
- ✅ Optional title on recordings (auto-generated if blank)
- ✅ Native players for MVP (AVPlayerViewController, reliable)
- ✅ Chronological library (sorting deferred to v2)
- ✅ Dashboard shows from Day 1 (contextual insights even with 2 points)
- ✅ Single scrollable feed (Apple Health pattern, sticky filters)
- ✅ Static charts for MVP (defer interactivity to v2)
- ✅ Share Sheet for export (native, flexible)
- ✅ Single confirmation for delete (iOS standard)
- ✅ **AI Chat REMOVED** (gimmicky, recordings are better)
- ✅ Swipe-to-delete + long-press-to-edit pattern
- ✅ Progressive disclosure (required → divider → optional)
- ✅ Haptic feedback + toast confirmations

**Why It's Done:**
- Every user decision point mapped
- UX ambiguities caught before coding
- Visual thinking revealed gaps
- **Ready to implement SwiftUI views**

**Output:**
- 19 screens designed across 7 flows
- Decision trees for edge cases (permissions, empty states)
- Feeds directly into SwiftUI view implementation
- **100% UX specification complete** 🎉

---

### 🚧 IN PROGRESS / NEXT UP

#### 4. `DATA_MODEL_SPEC.md` - **NEXT TO CREATE**
**Status:** 🔴 Not Started
**Priority:** HIGH (blocks implementation)

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
   - Phase 3 (Weeks 9-12): Polish & Testing (UI/UX refinements, performance optimization)
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
✅ MVP_PRODUCT_SPEC.md (v1.4) - AI Chat removed, 100% complete
    ↓
✅ CLINICAL_CANNABIS_SPEC.md (100% complete) - BOTH LOGGING FLOWS VALIDATED 🔥🔥🔥
    ↓
✅ UX_FLOW_SPEC.md (v1.2, 100% complete) - ALL 7 FLOWS DESIGNED (19 screens) 🎉
    ↓
🔴 DATA_MODEL_SPEC.md ← YOU ARE HERE (next to create)
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
4. 🔴 **Technical spec** (how do we build it?) ← DATA_MODEL_SPEC.md
5. 🔴 **Implementation plan** (in what order?) ← TECHNICAL_IMPLEMENTATION.md
6. ⚪ Start coding (with confidence)

**This is called "Domain-Driven Design"** - the domain expert (you) validates the model before engineers build it.

---

## 📝 Next Actions

### When You Return to This Project:

1. **Read this file** (`CHECKPOINT_STATUS.md`)
2. **Check the "YOU ARE HERE" marker** (currently: Ready for DATA_MODEL_SPEC.md)
3. **Choose your path:**
   - **Option A (Recommended):** Create DATA_MODEL_SPEC.md (define SwiftData schemas, relationships, persistence)
   - **Option B:** Scan completed planning docs for any gaps
   - **Option C:** Jump to TECHNICAL_IMPLEMENTATION.md (map features to code)
4. **Update this file** when you complete a doc (move ✅, update "YOU ARE HERE")

---

## 🚀 Immediate Next Step: Create DATA_MODEL_SPEC.md

**✅ ALL PLANNING DOCS COMPLETE (4/4).** UX_FLOW_SPEC.md 100% done (19 screens across 7 flows). 🎉

**Next: DATA_MODEL_SPEC.md**
- Define exact SwiftData model schemas (`CravingModel`, `UsageModel`, `RecordingModel`, `MotivationalMessageModel`)
- Map relationships (Craving ↔ Recording, delete rules from Appendix B)
- Validate against UX flows (all fields needed for 19 screens)
- Define persistence layer (ModelContainer setup, CloudKit `.none`)
- Performance constraints (<5 sec craving log, <10 sec usage log, 90+ day chart rendering)

**Why this matters:**
- Technical source of truth for implementation
- Ensures SwiftData relationships match product spec
- Catches data integrity issues before coding
- Copy-paste ready code examples for implementation

---

## 📞 How to Use This Doc

- **Reference:** Check "YOU ARE HERE" when you return to the project
- **Update:** Mark docs ✅ when complete, move the "YOU ARE HERE" marker
- **Brainstorm:** Use "What It Should Define" sections as writing prompts
- **Validate:** Ensure each doc feeds into the next (dependencies)

---

**Status:** CHECKPOINT FILE ACTIVE - Update as you complete docs 🚀
