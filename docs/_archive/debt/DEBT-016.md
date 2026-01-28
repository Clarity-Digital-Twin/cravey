# DEBT-016: Craving/Usage Form Details Section Declutter

**Priority:** P4 (Code Quality)
**Status:** OPEN
**Created:** 2026-01-28

## Problem

The Details section has verbose labels, confusing groupings, and left-aligned chips.

---

## Changes Summary

| Current | New |
|---------|-----|
| "What triggered this?" | "Triggers" |
| "Primary (HAALT)" | "Primary" |
| Primary: Hungry, Angry, Anxious, Lonely, Tired, Sad | Primary: Hungry, Angry, Lonely, Tired, Anxious, Bored, Sad |
| Secondary: Bored, Social, Habit, Paraphernalia | Secondary: Social, Habit, Paraphernalia |
| "Where are you?" | "Location" |
| Location: 📍 Current, Home, Work, Social, Outside, Car | Location: 📍 Current, Home, Work, Out, Other |
| Left-aligned chips | Centered chips |

**Rationale:**
- "Bored" is a feeling, belongs with Primary emotions
- "Social, Outside, Car" as locations are confusing - "Out" and "Other" are cleaner
- Centering chips looks more balanced

---

## Files to Modify

### 1. Trigger Options (Domain)

| File | Line | Change |
|------|------|--------|
| `Cravey/Domain/Entities/TriggerOptions.swift` | 8-15 | Primary: `["Hungry", "Angry", "Lonely", "Tired", "Anxious", "Bored", "Sad"]` |
| `Cravey/Domain/Entities/TriggerOptions.swift` | 18-23 | Secondary: `["Social", "Habit", "Paraphernalia"]` |

### 2. Location Options (Presentation)

| File | Line | Change |
|------|------|--------|
| `Cravey/Presentation/Views/Components/LocationOptions.swift` | 10-17 | Presets: `[currentLocationKey, "Home", "Work", "Out", "Other"]` |

### 3. Craving Form Labels

| File | Line | Current | New |
|------|------|---------|-----|
| `Cravey/Presentation/Views/Craving/CravingLogForm.swift` | 24 | `title: "What triggered this?"` | `title: "Triggers"` |
| `Cravey/Presentation/Views/Craving/CravingLogForm.swift` | 26 | `title: "Primary (HAALT)"` | `title: "Primary"` |
| `Cravey/Presentation/Views/Craving/CravingLogForm.swift` | 36 | `title: "Where are you?"` | `title: "Location"` |

### 4. Usage Form Labels (Same changes)

| File | Line | Current | New |
|------|------|---------|-----|
| `Cravey/Presentation/Views/Usage/UsageLogForm.swift` | 46 | `title: "What triggered this?"` | `title: "Triggers"` |
| `Cravey/Presentation/Views/Usage/UsageLogForm.swift` | 48 | `title: "Primary (HAALT)"` | `title: "Primary"` |
| `Cravey/Presentation/Views/Usage/UsageLogForm.swift` | 170 | `title: "Where are you?"` | `title: "Location"` |

### 5. ChipSelector Preview Code

| File | Line | Current | New |
|------|------|---------|-----|
| `Cravey/Presentation/Views/Components/ChipSelector.swift` | 252 | `title: "What triggered this?"` | `title: "Triggers"` |
| `Cravey/Presentation/Views/Components/ChipSelector.swift` | 270 | `title: "Where are you?"` | `title: "Location"` |

### 6. Tests

| File | Lines | Change |
|------|-------|--------|
| `CraveyTests/Domain/Services/LocationServiceTests.swift` | 48, 61-62 | Update any tests that reference "Home", "Work" (these stay) or removed options |
| `CraveyTests/Integration/UsageDataLayerTests.swift` | 214 | Verify `TriggerOptions.all` still works after reordering |

### 7. Chip Centering (ChipSelector Component)

| File | Change |
|------|--------|
| `Cravey/Presentation/Views/Components/ChipSelector.swift` | Add `.frame(maxWidth: .infinity)` or use `HStack` with `Spacer()` to center chip rows |

---

## Acceptance Criteria

- [ ] `TriggerOptions.swift` - Primary has 7 items (Hungry, Angry, Lonely, Tired, Anxious, Bored, Sad)
- [ ] `TriggerOptions.swift` - Secondary has 3 items (Social, Habit, Paraphernalia)
- [ ] `LocationOptions.swift` - Presets are (📍 Current, Home, Work, Out, Other)
- [ ] `CravingLogForm.swift` - Labels updated (Triggers, Primary, Location)
- [ ] `UsageLogForm.swift` - Labels updated (Triggers, Primary, Location)
- [ ] `ChipSelector.swift` - Preview code updated
- [ ] `ChipSelector.swift` - Chips are centered
- [ ] All tests pass
