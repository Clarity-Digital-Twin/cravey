# Cravey Documentation Checkpoint & Status

**Last Updated:** 2025-10-12
**Current Phase:** Planning & Validation (Pre-Implementation)

---

## 📊 Overall Status: 25% Complete (1/4 Planning Docs Done)

| Phase | Status | Progress |
|-------|--------|----------|
| **Phase 1: Planning & Validation** | 🟡 In Progress | 25% (1/4 docs) |
| **Phase 2: Implementation** | ⚪ Not Started | 0% |
| **Phase 3: Testing & Launch** | ⚪ Not Started | 0% |

---

## 📋 Documentation Roadmap

### ✅ COMPLETED

#### 1. `MVP_PRODUCT_SPEC.md` (v1.1) - **LOCKED**
**Status:** ✅ Complete
**Last Updated:** 2025-10-12
**What It Defines:**
- Vision, target users, core problems solved
- 6 MVP features (Onboarding, Craving Logging, Usage Logging, Recordings, Dashboard, AI Chat, Data Management)
- Success criteria (Technical, User, Ethical)
- Out of scope items
- **Appendix A:** ROA amounts & trigger categories
- **Appendix B:** Data relationship & deletion rules

**Key Decisions Made:**
- iOS 18+ only (initial release)
- Local-only storage (SwiftData with `.none` CloudKit)
- <5 sec craving log, <10 sec usage log
- 5 ROA categories (Smoke/Vape/Dab/Edible/Other)
- Permission denial fallbacks documented
- Delete behavior for all relationships defined

**Why It's Done:**
- Provides north star for all other docs
- Defines product-level "what" before technical "how"
- Ready for clinical validation and UX mapping

---

### 🚧 IN PROGRESS / NEXT UP

#### 2. `CLINICAL_CANNABIS_SPEC.md` - **NEXT TO CREATE**
**Status:** 🔴 Not Started
**Priority:** HIGH (blocks accurate implementation)
**Owner:** Ray (Domain Expert - Psychiatrist/Addiction Medicine)

**Purpose:**
Validate clinical accuracy of cannabis tracking model BEFORE building it.

**What It Should Define:**
1. **ROA Categories** - Are Smoke/Vape/Dab/Edible/Other clinically meaningful?
2. **Amount Granularity** - Is "Half bowl / Full bowl" useful for harm reduction? Or do we need grams, mg THC, etc.?
3. **Frequency Tracking** - What timeframes matter clinically? (Daily, weekly, per-session?)
4. **Craving Intensity** - Is 1-10 scale validated? Or should it be 0-5, qualitative (Low/Med/High)?
5. **Outcome Categories** - Is Resisted/Deciding/Used sufficient? Or too simplistic?
6. **Trigger Categories** - Are Stress/Boredom/Social/Anxiety/Habit/Paraphernalia complete? Missing any?
7. **THC Potency** - Should we track this? (Clinical concern: high-potency concentrates)
8. **Medical vs. Recreational** - Does this distinction matter for MVP?

**Why This Matters:**
- You're the domain expert - your clinical judgment validates the model
- Prevents building technically perfect but clinically useless features
- Example: "Number of puffs" sounds quantitative but has no clinical utility
- Example: "Half bowl vs. full bowl" matches user mental model and is actionable

**How to Write It:**
- This is a brainstorming doc, not a formal spec
- Write from clinical perspective: "What actually matters for harm reduction?"
- Challenge existing decisions in MVP_PRODUCT_SPEC.md
- Casual tone OK - you're validating with expertise, not writing for stakeholders

**Output:**
- Validates or revises Appendix A (ROA amounts)
- May add new fields (e.g., THC potency tracking)
- May remove fields (e.g., "Duration" for cravings might be clinically meaningless)
- Feeds into DATA_MODEL_SPEC.md (so we build the right thing)

---

#### 3. `UX_FLOW_SPEC.md` - **AFTER CLINICAL SPEC**
**Status:** 🔴 Not Started
**Priority:** HIGH (blocks UI implementation)

**Purpose:**
Map user journeys and screen flows to understand how the app FEELS to use.

**What It Should Define:**
1. **Onboarding Flow**
   - Welcome screen → Goal selection → Permissions → Tour → Home
   - What if user denies camera? Denies mic? Denies both?

2. **Craving Logging Flow**
   - Home → "Log Craving" button → Quick form (<5 sec)
   - Outcome = "Used" → "Log what you used?" prompt → Dismiss vs. Continue
   - Return to home with feedback message

3. **Usage Logging Flow**
   - Home → "Log Usage" → Form (<10 sec)
   - ROA selection → Amount selection (context-aware)
   - Optional fields (trigger, mood, notes)
   - Save → Return to home

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
- Example: "What happens if user logs craving with 'Used' outcome but dismisses the usage prompt?" (Answered in v1.1: craving saved, no usage log)

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
   - `UserGoalModel` - Track goal changes over time

2. **Relationships**
   - Craving ↔ Recording (many-to-one, `.nullify` delete rule)
   - Usage ↔ Craving (one-to-one optional, prompt on delete)
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
✅ MVP_PRODUCT_SPEC.md (v1.1)
    ↓
🔴 CLINICAL_CANNABIS_SPEC.md ← YOU ARE HERE (about to start)
    ↓
🔴 UX_FLOW_SPEC.md
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
2. **Check the "YOU ARE HERE" marker** (currently: CLINICAL_CANNABIS_SPEC.md)
3. **Open the "NEXT TO CREATE" section** (currently: CLINICAL_CANNABIS_SPEC.md)
4. **Start brainstorming/writing** that doc
5. **Update this file** when you complete a doc (move ✅, update "YOU ARE HERE")

---

## 🚀 Immediate Next Step: Clinical Validation

**Your instinct was correct:** You need to validate the cannabis tracking model with your clinical expertise BEFORE building it.

**Create `CLINICAL_CANNABIS_SPEC.md` now** to answer:
- Is "Half bowl / Full bowl" clinically useful?
- Should we track THC potency?
- Is 1-10 craving intensity validated?
- Are the trigger categories complete?

**Why this matters:** You'd waste weeks building a technically perfect app that tracks clinically meaningless data.

---

## 📞 How to Use This Doc

- **Reference:** Check "YOU ARE HERE" when you return to the project
- **Update:** Mark docs ✅ when complete, move the "YOU ARE HERE" marker
- **Brainstorm:** Use "What It Should Define" sections as writing prompts
- **Validate:** Ensure each doc feeds into the next (dependencies)

---

**Status:** CHECKPOINT FILE ACTIVE - Update as you complete docs 🚀
