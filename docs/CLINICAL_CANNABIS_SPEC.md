# Clinical Cannabis Tracking Specification

**Author:** Ray (Psychiatrist / Addiction Medicine)
**Last Updated:** 2025-10-12
**Status:** 🚧 Brainstorming / Draft
**Purpose:** Validate clinical accuracy of cannabis tracking model BEFORE implementation

---

## 🧠 Domain Expert Validation

This doc is where the domain expert (you) validates that the tracking model is clinically useful for harm reduction. Not what's technically easy to build - what actually matters for patient care.

**Key Question:** What granularity of tracking helps people reduce harm without being burdensome?

---

## 📊 Cannabis Quantity Tracking (Routes of Administration)

**✅ VALIDATED MODEL - Simple Incrementing Counts (Clinically Useful, Fast to Log)**

### 1. **SMOKE - Bowls** (Pipes / Bongs)

**Tracking Method:**
- **Incrementing by 0.5** (0.5, 1, 1.5, 2, 2.5, 3...)

**Examples:**
- 0.5 bowls = half bowl
- 1 bowl = full bowl
- 1.5 bowls = one and a half bowls
- 2 bowls = two full bowls

**Why This Works:**
- Matches user mental model ("I smoked half a bowl" = 0.5)
- Simple number incrementing
- Actionable for harm reduction (track "3 bowls" vs "0.5 bowls")
- Quick to log (<5 sec)

---

### 2. **SMOKE - Joints**

**Tracking Method:**
- **Incrementing by 0.5** (0.5, 1, 1.5, 2, 2.5, 3...)

**Examples:**
- 0.5 joints = half joint
- 1 joint = full joint
- 1.5 joints = one and a half joints
- 2 joints = two full joints

**Why This Works:**
- Same pattern as bowls - simple, fast, intuitive
- Half joints are common (sharing, rationing)

---

### 3. **SMOKE - Blunts**

**Tracking Method:**
- **Incrementing by 0.5** (0.5, 1, 1.5, 2, 2.5, 3...)

**Examples:**
- 0.5 blunts = half blunt
- 1 blunt = full blunt
- 1.5 blunts = one and a half blunts

**Why This Works:**
- Consistent with bowls/joints pattern
- Blunts often contain more cannabis than joints, but user knows their own context

**Clinical Note:**
- Blunts use tobacco wraps (nicotine exposure) - track this separately? Out of scope for MVP.

---

### 4. **VAPE - Pens / Cartridges**

**Tracking Method:**
- **Incrementing by 1** (1, 2, 3, 4, 5... pulls)

**Examples:**
- 1 pull
- 3 pulls
- 10 pulls

**Why This Works:**
- Simple whole number counting
- No short/long distinction (too pedantic, hard to track accurately)
- Users can easily count hits
- Quick to log

**Clinical Note:**
- Vape cartridges vary wildly in THC % (300mg to 1000mg+)
- Pull count may not correlate directly with THC intake
- But useful for behavioral tracking (frequency patterns, escalation over time)

---

### 5. **DAB - Concentrates**

**Tracking Method:**
- **Incrementing by 1** (1, 2, 3, 4... dabs)

**Examples:**
- 1 dab
- 2 dabs
- 3 dabs

**Why This Works:**
- Simple whole number counting
- No small/large distinction (half dabs are weird, users just count dabs)
- Quick to log

**Clinical Note:**
- Dabs are high-potency (60-90% THC vs 15-25% flower)
- **Clinical concern:** Tolerance escalation with concentrate use
- Count alone is sufficient for behavioral tracking

---

### 6. **EDIBLE - Gummies / Brownies / Drinks**

**Tracking Method:**
- **Incrementing by 10mg THC** (10mg, 20mg, 30mg, 40mg, 50mg...)

**Examples:**
- 10mg = one standard gummy
- 20mg = two gummies or one strong gummy
- 50mg = higher dose

**Why This Works:**
- Dispensaries standardize at 10mg doses
- Users can read packaging
- Matches real-world dosing (5mg = microdose, 10mg = standard, 25mg+ = strong)
- Quick to log if they know dosage

**Clinical Note:**
- Edibles have delayed onset (1-3 hours)
- **Clinical concern:** Overdosing from impatience ("not feeling it yet, eat more")
- Tracking mg helps identify dose patterns and tolerance

**Edge Case:**
- If user doesn't know dosage: Allow "Unknown" or freeform text (e.g., "half brownie")

---

## 🤔 Open Questions (To Brainstorm)

### Routes of Administration (ROA) - Complete?
- ✅ **Smoke (Bowls)** - Incrementing by 0.5 (0.5, 1, 1.5, 2...)
- ✅ **Smoke (Joints)** - Incrementing by 0.5 (0.5, 1, 1.5, 2...)
- ✅ **Smoke (Blunts)** - Incrementing by 0.5 (0.5, 1, 1.5, 2...)
- ✅ **Vape** - Incrementing by 1 (1, 2, 3, 4... pulls)
- ✅ **Dab** - Incrementing by 1 (1, 2, 3... dabs)
- ✅ **Edible** - Incrementing by 10mg (10mg, 20mg, 30mg...)
- ❓ **Other** - Tinctures, topicals, etc. (Relevant for MVP? Likely out of scope)

### Craving Intensity Scale
- ❓ Is **1-10 scale** validated? (Currently in MVP spec)
- ❓ Or should it be **0-5**? (Less cognitive load)
- ❓ Or **qualitative** (Low / Medium / High / Overwhelming)?

### Craving Outcome Categories
- ✅ **Resisted** - Did not use
- ✅ **Deciding** - Still in process
- ✅ **Used** - Gave in to craving
- ❓ Are these sufficient? Or too simplistic?
- ❓ Should we add **"Used Less Than Intended"**? (Harm reduction win)

### Trigger Categories
**Currently in MVP spec:**
- Stress, Boredom, Social, Anxiety, Habit, Paraphernalia

**Questions:**
- ❓ Missing any major triggers? (Pain? Insomnia? PTSD symptoms?)
- ❓ Too many options = analysis paralysis?
- ❓ Should we allow multiple trigger selection? (Stress + Anxiety)

### THC Potency Tracking
- ❓ Should we track **THC %** or **mg THC**?
- ❓ Clinical concern: High-potency concentrates (dabs) vs flower
- ❓ Is this MVP or post-MVP?
- ❓ Too burdensome for users to track?

### Medical vs. Recreational Distinction
- ❓ Does this matter for harm reduction?
- ❓ Or is "why you use" captured well enough by triggers/goals?

### Frequency Metrics
- ❓ What timeframes matter clinically?
  - Daily usage count?
  - Weekly patterns?
  - Time of day patterns? (Morning use = different concern than evening?)
  - Consecutive days of use? (Tolerance/dependence indicator)

---

## 📝 Clinical Notes (Brainstorming Space)

*(Keep adding thoughts here as you brainstorm)*

**✅ ROA Tracking Model Validated (2025-10-12):**
- Simple incrementing counts match user mental models
- **Bowls/Joints/Blunts:** 0.5 increments (captures "half" vs "full")
- **Vapes/Dabs:** Whole number increments (1, 2, 3...)
- **Edibles:** 10mg increments (standard dispensary dosing)
- No overly pedantic distinctions (no "short/long pulls", no "small/large dabs")
- Fast to log (<5 sec target)
- Supports harm reduction insights ("using 0.5 bowls vs 3 bowls")
- Don't track data that won't inform clinical decisions

**Key Principle:**
- Users in vulnerable moments need FAST, SIMPLE logging
- "Half bowl / full bowl" >> "number of puffs" (clinically useless)
- Granularity supports behavioral tracking without being burdensome

---

## 🎯 What This Doc Will Inform

Once validated, this doc feeds into:
1. **UX_FLOW_SPEC.md** - How do users actually select these quantities?
2. **DATA_MODEL_SPEC.md** - What fields do we store in SwiftData?
3. **MVP_PRODUCT_SPEC.md** - May revise Appendix A (ROA amounts)

---

**Status:** IN PROGRESS - Keep brainstorming, Ray. Add notes as you think out loud.
