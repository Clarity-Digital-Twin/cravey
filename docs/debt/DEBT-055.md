# DEBT-055: CravingLogForm UI Overhaul

**Created:** 2026-01-31
**Priority:** P2 (Important - UX consistency)
**Status:** Open

## Summary

Restructure CravingLogForm for visual clarity and consistency with UsageLogForm. Steve Jobs minimal - less words, cleaner separation.

## Current State

```
┌─────────────────────────────┐
│ [Timestamp] [Time]          │  ← No header
│ Intensity + slider          │
│ 5 - Moderate (left-aligned) │
└─────────────────────────────┘

Details (Optional)            ← Cluttered mashup
┌─────────────────────────────┐
│ Triggers                    │
│   Primary: [chips...]       │
│   Secondary: [chips...]     │
│ ─────────────────────────── │
│ Location                    │
│   [chips...]                │
│ ─────────────────────────── │
│ Notes                       │
│   [text field]              │
└─────────────────────────────┘
```

**Problems:**
1. "5 - Moderate" is left-aligned (should be centered)
2. Trigger order: Anxious, Bored, Sad (should be: Sad, Anxious, Bored)
3. "Details (Optional)" section is visually dense - everything crammed together
4. "(Optional)" is unnecessary - if they don't want to fill it, they won't

## Target State

```
┌─────────────────────────────┐
│ [Timestamp] [Time]          │  ← Required section (no header)
│ Intensity              😐   │
│ [====●=====]                │
│       5 - Moderate          │  ← CENTERED
└─────────────────────────────┘

Triggers                       ← Clean, no "(Optional)"
┌─────────────────────────────┐
│ Primary: [HALT chips...]    │
│ [Sad] [Anxious] [Bored]     │  ← Reordered
│ Secondary: [chips...]       │
└─────────────────────────────┘

Location
┌─────────────────────────────┐
│ [📍 Current] [Home] [Work]  │
│ [Out] [Other]               │
└─────────────────────────────┘

Notes
┌─────────────────────────────┐
│ [text field]                │
└─────────────────────────────┘
```

## Changes Required

### 1. IntensitySlider.swift (line 39)
Center the intensity label:
```swift
Text(Self.formatLabel(for: Int(value)))
    .font(.subheadline)
    .foregroundStyle(.secondary)
    .frame(maxWidth: .infinity)  // ADD: Centers text
```

### 2. TriggerOptions.swift (lines 6-14)
Reorder bottom row to: Sad, Anxious, Bored
```swift
static let primary: [String] = [
    "Hungry",
    "Angry",
    "Lonely",
    "Tired",
    "Sad",      // Moved from end
    "Anxious",
    "Bored",
]
```

### 3. CravingLogForm.swift - Restructure sections
Break "Details (Optional)" into separate sections:

```swift
// REQUIRED SECTION (no header)
Section {
    TimestampPicker(date: $viewModel.timestamp)
    IntensitySlider(value: $viewModel.intensity)
}

// TRIGGERS SECTION
Section("Triggers") {
    ChipSelector(
        title: nil,  // No title - section header provides context
        groups: [...],
        ...
    )
}

// LOCATION SECTION
Section("Location") {
    LocationSelector(viewModel: viewModel, showTitle: false)
}

// NOTES SECTION
Section("Notes") {
    TextField("", text: $viewModel.notes, axis: .vertical)
        .lineLimit(3 ... 5)
    // Character counter if needed
}
```

### 4. ChipSelector.swift
Make `title` optional (nullable):
```swift
let title: String?  // Changed from String

// In body, conditionally render:
if let title {
    Text(title)
        .font(.subheadline)
        .foregroundStyle(.secondary)
}
```

### 5. LocationSelector.swift
Add `showTitle` parameter (default true for backwards compat):
```swift
struct LocationSelector<...>: View {
    @Bindable var viewModel: ViewModel
    var showTitle: Bool = true

    var body: some View {
        OptionalSingleSelectChipSelector(
            title: showTitle ? "Location" : nil,
            ...
        )
    }
}
```

### 6. OptionalSingleSelectChipSelector (in ChipSelector.swift)
Make `title` optional to match ChipSelector.

## Files to Modify

1. `Cravey/Presentation/Views/Components/IntensitySlider.swift`
2. `Cravey/Domain/Entities/TriggerOptions.swift`
3. `Cravey/Presentation/Views/Craving/CravingLogForm.swift`
4. `Cravey/Presentation/Views/Components/ChipSelector.swift`
5. `Cravey/Presentation/Views/Components/LocationSelector.swift`

## Verification

1. Open CravingLogForm
2. Verify "5 - Moderate" is centered under slider
3. Verify triggers: Row 1 = [Hungry, Angry, Lonely, Tired], Row 2 = [Sad, Anxious, Bored]
4. Verify 4 separate sections: Required (no header), Triggers, Location, Notes
5. Verify NO "(Optional)" text anywhere
6. Run `scripts/verify.sh` - all tests pass

## Future Work

After CravingLogForm is clean, apply same pattern to UsageLogForm:
- Remove redundant labels ("Triggers (Optional)" header + "Triggers" inside)
- Remove "(Optional)" from all section headers
