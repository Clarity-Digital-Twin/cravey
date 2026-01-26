# Language & Clinical Terminology Debt

**Last Updated:** 2026-01-26
**Status:** OPEN - Must fix before public release

## Background

As of 2026, SAMHSA, NIDA, and major addiction medicine organizations (ASAM) have established clear guidelines for stigma-free language when discussing substance use disorders. Dr. Ray (the product owner) is an addiction psychiatrist and requires the app to follow these guidelines.

### Key Principles from SAMHSA/NIDA 2026 Guidelines

1. **Person-first language**: "person with a substance use disorder" not "addict"
2. **Avoid clean/dirty**: These terms are stigmatizing and moralistic
3. **Abstinence vs Sobriety**: Both acceptable, but "abstinent from substances" is clinically preferred
4. **Recovery-oriented**: Focus on progress, not judgment

### Preferred Terminology

| Avoid | Use Instead |
|-------|-------------|
| Clean | Abstinent, not using, substance-free |
| Dirty | Positive (for test), currently using |
| Addict | Person with substance use disorder |
| User | Person who uses substances |
| Clean time | Abstinence duration, time in recovery |
| Days clean | Days abstinent, days substance-free |

---

## LANG-001: "Days Clean" on Dashboard

**Status:** OPEN
**Priority:** CRITICAL
**Location:** `Cravey/Presentation/Views/Dashboard/DashboardView.swift`

### Current Implementation
```
Current Streak: 0 days clean
```

### Problem
"Clean" implies users are "dirty" when using substances. This is:
- Stigmatizing and moralistic
- Contrary to SAMHSA 2026 guidelines
- Potentially harmful to users in vulnerable moments
- Inconsistent with motivational interviewing principles

### Recommended Fix
```
Current Streak: 0 days substance-free
```
OR
```
Days Without Use: 0
```
OR (preferred by Dr. Ray)
```
Abstinence Streak: 0 days
```

### Files to Update
- `Cravey/Presentation/Views/Dashboard/DashboardView.swift`
- `Cravey/Presentation/Views/Dashboard/StreakCard.swift` (if exists)
- Any localization strings

---

## LANG-002: "Clean" in Specs and Code Comments

**Status:** OPEN
**Priority:** HIGH
**Location:** Multiple files

### Current Occurrences

Search for "clean" in codebase:
```bash
rg -i "clean" --type swift
rg -i "clean" docs/
```

### Files to Audit
1. `docs/master/CLINICAL_CANNABIS_SPEC.md` - Check for "clean" terminology
2. `docs/master/MVP_PRODUCT_SPEC.md` - Check product copy
3. `docs/master/UX_FLOW_SPEC.md` - Check UI strings
4. All ViewModels and Views for hardcoded strings

### Recommended Actions
1. Global find/replace "days clean" → "days substance-free" or "days abstinent"
2. Audit all user-facing strings
3. Update spec documents to use preferred terminology
4. Add terminology guidelines to CLAUDE.md

---

## LANG-003: Streak Nomenclature

**Status:** OPEN
**Priority:** HIGH
**Location:** `DashboardViewModel.swift`, `DashboardView.swift`

### Current Metrics
- "Current Streak" - Ambiguous (streak of what?)
- "Longest Streak" - Same issue

### Recommended Alternatives

**Option A: Abstinence-focused (clinical)**
- "Current Abstinence: X days"
- "Longest Abstinence: X days"

**Option B: Recovery-focused (supportive)**
- "Days in Recovery: X"
- "Personal Best: X days"

**Option C: Neutral/descriptive**
- "Days Since Last Use: X"
- "Longest Gap: X days"

### Decision Needed
Dr. Ray should pick preferred terminology based on clinical judgment and target user population.

---

## LANG-004: "Craving" vs "Urge" Terminology

**Status:** DEFERRED
**Priority:** LOW
**Note:** "Craving" is clinically accepted (DSM-5 criterion). No change needed.

---

## LANG-005: Fire/Flame Icon for Streak

**Status:** OPEN
**Priority:** MEDIUM
**Location:** `DashboardView.swift`

### Current Implementation
Uses 🔥 fire emoji for streak display.

### Concern
Fire/flame iconography could be triggering for some users or seem gamification-focused. Consider alternatives:

- ✨ Sparkle (celebration)
- 🌱 Seedling (growth)
- 💪 Flexed bicep (strength)
- Calendar icon (neutral)

### Decision Needed
Review with UX perspective - is gamification appropriate for cessation app?

---

## Implementation Checklist

- [ ] LANG-001: Replace "days clean" → "days substance-free"
- [ ] LANG-002: Audit all specs for "clean" terminology
- [ ] LANG-003: Decide on streak nomenclature
- [ ] LANG-005: Review fire emoji appropriateness
- [ ] Add "Stigma-Free Language" section to CLAUDE.md
- [ ] Create string constants file for consistent terminology

---

## References

- [NIDA Words Matter (2024)](https://nida.nih.gov/nidamed-medical-health-professionals/health-professions-education/words-matter-terms-to-use-avoid-when-talking-about-addiction)
- [SAMHSA Stigma & Language](https://www.samhsa.gov/substance-use/treatment/stigma-language)
- [OASAS Stigma Glossary](https://oasas.ny.gov/stigma-glossary)
- [ASAM Terminology Guidelines](https://www.asam.org/docs/default-source/default-document-library/nidamed_wordsmatter3_508.pdf)
