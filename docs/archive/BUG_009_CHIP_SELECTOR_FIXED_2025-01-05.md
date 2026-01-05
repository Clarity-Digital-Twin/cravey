# BUG-009: ChipSelector Button Actions Triggered Incorrectly

**Status:** RESOLVED
**Severity:** P0 (Critical - Core UX broken)
**Date Reported:** 2025-12-10
**Environment:** iOS 18.x, iPhone 16/17 Pro Simulator, Swift 6.0, Xcode 16.x

---

## Symptoms

### Bug A: Multi-Select Chips - One Tap Selects ALL
- **Component:** `ChipSelector` with `multiSelect: true`
- **Location:** "What triggered this?" in CravingLogForm
- **Expected:** Tapping "Hungry" should toggle only "Hungry"
- **Actual:** Tapping ANY chip selects ALL chips simultaneously

### Bug B: Single-Select Chips - Only One Chip Responds
- **Component:** `OptionalSingleSelectChipSelector`
- **Location:** "Where are you?" in CravingLogForm
- **Expected:** Tapping any location chip should select it
- **Actual:** Only "Car" (last chip) responds to taps; others are unresponsive

---

## Root Cause Analysis

### Hypothesis 1: Custom Layout Protocol Hit-Testing Issue

The `FlowLayout` custom `Layout` implementation may be interfering with SwiftUI's hit-testing.

**Evidence:**
- Per [Hacking with Swift Forums](https://www.hackingwithswift.com/forums/swiftui/tap-button-in-hstack-activates-all-button-actions-ios-14-swiftui-2/2952): "When using multiple buttons in an HStack in SwiftUI 2, tapping on a single button causes ALL button actions to execute"
- Per [SwiftUI Lab](https://swiftui-lab.com/layout-protocol-part-1/): "sizeThatFits and placeSubviews are called multiple times by SwiftUI"
- Custom `Layout` protocol may not properly isolate button hit regions

**Code Location:** `ChipSelector.swift:132-182` (`FlowLayout` struct)

### Hypothesis 2: iOS 18 Button Gesture Regression

iOS 18 introduced gesture handling regressions affecting buttons.

**Evidence:**
- Per [Medium - Gaurav Tak](https://medium.com/@gauravkumarjaipur/swiftui-buttons-not-working-in-ios-18-heres-what-we-need-to-know-and-how-to-fix-it-3e5b2ea9357b):
  - "iOS 18 introduces regressions in gesture handling"
  - "Buttons not triggering .action, onTapGesture inconsistently firing"
  - "Taps being swallowed in ZStack, overlays, or views with transparent layers"
  - "Bug doesn't always appear in debug mode"

### Hypothesis 3: Button Style Interference

Default button styles may expand tap areas to encompass siblings.

**Evidence:**
- Per [Hacking with Swift Forums](https://www.hackingwithswift.com/forums/swiftui/button-s-on-click-event-being-applied-to-hstack-surrounding-it/2859): "Clicking anywhere in the HStack triggers the button click event"
- Solution often involves `.buttonStyle(.plain)` or `.buttonStyle(.borderless)`

---

## Current Implementation

```swift
// ChipButton (ChipSelector.swift:112-129)
struct ChipButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .contentShape(Capsule()) // Added for iOS 18
    }
}
```

**Problems Identified:**
1. No `.buttonStyle()` modifier - uses default style which may expand tap area
2. `.contentShape(Capsule())` is on the Button, but hit-testing may still fail in custom Layout
3. FlowLayout may not properly communicate hit regions to SwiftUI

---

## Proposed Fixes

### Fix 1: Add `.buttonStyle(.plain)` or `.buttonStyle(.borderless)`

```swift
Button(action: action) {
    // content
}
.buttonStyle(.plain) // Prevents tap area expansion
.contentShape(Capsule())
```

**Why:** Plain button style doesn't expand tap area to parent container.

### Fix 2: Replace Button with Text + `.onTapGesture`

```swift
Text(title)
    .font(.subheadline)
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
    .background(isSelected ? Color.accentColor : Color(.systemGray5))
    .foregroundColor(isSelected ? .white : .primary)
    .clipShape(Capsule())
    .contentShape(Capsule())
    .onTapGesture {
        action()
    }
```

**Why:** Avoids Button's problematic hit-testing entirely.

### Fix 3: Use `.highPriorityGesture()` for Explicit Tap Handling

```swift
Text(title)
    // styling...
    .highPriorityGesture(
        TapGesture()
            .onEnded { action() }
    )
```

**Why:** Per iOS 18 research, `.highPriorityGesture()` resolves gesture conflicts.

### Fix 4: Replace FlowLayout with Native Approach

Use iOS 16+ native wrapping with `ViewThatFits` or LazyVGrid instead of custom Layout.

```swift
LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
    ForEach(options, id: \.self) { option in
        ChipButton(...)
    }
}
```

**Why:** Native layouts have proper hit-testing built-in.

---

## Testing Plan

1. Apply Fix 1 (`.buttonStyle(.plain)`) and test
2. If still broken, apply Fix 2 (replace Button with onTapGesture)
3. If still broken, apply Fix 4 (replace FlowLayout with LazyVGrid)
4. Verify on real device (simulator may mask issues per research)

---

## References

- [SwiftUI Buttons Not Working in iOS 18](https://medium.com/@gauravkumarjaipur/swiftui-buttons-not-working-in-ios-18-heres-what-we-need-to-know-and-how-to-fix-it-3e5b2ea9357b)
- [HStack Button Activates All Actions](https://www.hackingwithswift.com/forums/swiftui/tap-button-in-hstack-activates-all-button-actions-ios-14-swiftui-2/2952)
- [Button Click Applied to HStack](https://www.hackingwithswift.com/forums/swiftui/button-s-on-click-event-being-applied-to-hstack-surrounding-it/2859)
- [SwiftUI Layout Protocol](https://swiftui-lab.com/layout-protocol-part-1/)
- [Apple WWDC22 - Compose Custom Layouts](https://developer.apple.com/videos/play/wwdc2022/10056/)

---

## Resolution

**TBD** - Implementing fixes now.
