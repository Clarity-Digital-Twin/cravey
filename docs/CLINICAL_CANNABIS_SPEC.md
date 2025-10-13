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

### 1. **SMOKE - Bowls** (Pipes / Bongs)

**Three-Step Selection:**
1. **Size Picker:** Small / Large
2. **Amount Picker:** Half / Full
3. **Count Picker:** # of bowls (incrementing count)

**Examples:**
- 1 small bowl, half smoked
- 2 small bowls, full
- 1 large bowl, half smoked
- 3 large bowls, full

**Why This Works:**
- Matches user mental model ("I smoked 2 half bowls")
- Actionable for harm reduction (tracking "3 large full bowls" vs "1 small half bowl")
- Not overly precise (no "number of puffs" bullshit)
- Quick to log (<10 sec)
- Count allows tracking session intensity

---

### 2. **SMOKE - Joints**

**Two-Step Selection:**
1. **Size Picker:** Small / Large
2. **Amount Picker:** Half / Full

**Examples:**
- Small joint, half smoked
- Small joint, full
- Large joint, half smoked
- Large joint, full

**Clinical Note:**
- (To be validated) - Does joint size correlate with THC intake? Or too variable (depends on potency, packing)?
- (To be validated) - Is this granularity useful? Or should we just track "joints smoked" (count)?

---

### 3. **SMOKE - Blunts**

**Two-Step Selection:**
1. **Size Picker:** Small / Large
2. **Amount Picker:** Half / Full

**Examples:**
- Small blunt, half smoked
- Small blunt, full
- Large blunt, half smoked
- Large blunt, full

**Clinical Note:**
- (To be validated) - Blunts typically have more cannabis than joints. Does this distinction matter?
- (To be validated) - Should we track tobacco exposure from blunt wraps? (Out of scope for MVP?)

---

### 4. **VAPE - Pens / Cartridges**

**Two-Step Selection:**
1. **Pull Type:** Short / Long
2. **Count Picker:** # of pulls (incrementing count)

**Examples:**
- 3 short pulls
- 5 long pulls
- 10 short pulls

**Why This Works:**
- Matches user mental model ("I took 5 hits")
- Short vs long distinguishes intensity (long pulls = more THC)
- Simple incrementing counter
- Quick to log

**Clinical Note:**
- Vape cartridges vary wildly in THC % (300mg to 1000mg+)
- Tracking pull count may not correlate directly with THC intake
- But still useful for behavioral tracking (frequency patterns)

---

### 5. **DAB - Concentrates**

**Two-Step Selection:**
1. **Size Picker:** Small / Large
2. **Count Picker:** # of dabs (incrementing count)

**Examples:**
- 1 small dab
- 2 large dabs
- 3 small dabs

**Why This Works:**
- Matches user mental model ("I took 2 dabs")
- Size matters (large dab = significantly more THC than small)
- Count tracks session intensity
- Quick to log

**Clinical Note:**
- Dabs are high-potency (60-90% THC vs 15-25% flower)
- Clinical concern: Tolerance escalation with concentrate use
- Size + count gives rough intensity metric

---

### 6. **EDIBLE - (TO BRAINSTORM NEXT)**

**Questions to answer:**
- ❓ Track by **mg THC** (requires user to know dosage - often on packaging)
- ❓ Track by **count** (gummies, brownies, cookies) + optional mg field?
- ❓ Track by **qualitative** (Small dose / Medium dose / Large dose)?
- ❓ Edibles are tricky: delayed onset, variable potency, homemade vs commercial

---

## 🤔 Open Questions (To Brainstorm)

### Routes of Administration (ROA) - Complete?
- ✅ Smoke (Bowls, Joints, Blunts)
- ✅ **Vape** - # of pulls (short/long)
- ✅ **Dab** - Size (small/large) + count
- 🚧 **Edible** - TO BRAINSTORM NEXT
- ❓ **Other** - Tinctures, topicals, etc. (Relevant for MVP?)

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

**Initial Thoughts:**
- "Half bowl / full bowl" is way more intuitive than "number of puffs"
- Users in craving moments need FAST logging (<10 sec target)
- Granularity should support harm reduction insights (e.g., "You're using less per session")
- Don't track data that won't inform clinical decisions

---

## 🎯 What This Doc Will Inform

Once validated, this doc feeds into:
1. **UX_FLOW_SPEC.md** - How do users actually select these quantities?
2. **DATA_MODEL_SPEC.md** - What fields do we store in SwiftData?
3. **MVP_PRODUCT_SPEC.md** - May revise Appendix A (ROA amounts)

---

**Status:** IN PROGRESS - Keep brainstorming, Ray. Add notes as you think out loud.
