# Phase 2B: Usage Logging - ROA Picker Component

**Version:** 1.0 (Spec-First Approach)
**Duration:** Half day (Component only)
**Dependencies:** Phase 2A complete (ROAAmountRange helper available)
**Status:** 📋 Ready to implement

---

## 🎯 Phase Goal

**Deliverable:** Single reusable `ROAPickerInput` component with **validated dynamic amount ranges** for all 6 ROAs.

**What We're Building:**
- ROAPickerInput component (SwiftUI)
- Component unit tests (validates all 6 ROAs)
- Preview validation (visual QA for all methods)

**What We're NOT Building (Yet):**
- NO full form
- NO ViewModel
- NO integration with HomeView

**Why This Approach:**
The ROA picker is the most complex UI component in Phase 2 (6 methods, dynamic ranges, display formatting). Validate it in isolation BEFORE integrating into the full form to avoid rework.

---

## 📋 SPEC VALIDATION (Read Before Coding)

### Tier 1 Requirements

**Source: CLINICAL_CANNABIS_SPEC.md lines 220-224 + DATA_MODEL_SPEC.md lines 132-166**

#### ROA Methods (6 total)

Must support these exact strings (case-sensitive):
```swift
["Bowls", "Joints", "Blunts", "Vape", "Dab", "Edible"]
```

#### Amount Picker Requirements (by ROA)

| ROA | Range | Increment | Picker Options | Display Format | Source |
|-----|-------|-----------|----------------|----------------|--------|
| **Bowls** | 0.5 → 5.0 | 0.5 | 10 options | "1 bowls", "2.5 bowls" | CLINICAL:221 |
| **Joints** | 0.5 → 5.0 | 0.5 | 10 options | "1 joints", "2.5 joints" | CLINICAL:221 |
| **Blunts** | 0.5 → 5.0 | 0.5 | 10 options | "1 blunts", "2.5 blunts" | CLINICAL:221 |
| **Vape** | 1 → 10 | 1 | 10 options | "1 pulls", "10 pulls" | CLINICAL:222 |
| **Dab** | 1 → 5 | 1 | 5 options | "1 dabs", "5 dabs" | CLINICAL:222 |
| **Edible** | 5 → 100 | 5 | 20 options | "5mg", "100mg" | CLINICAL:222 |

#### Display Formatting Rules

**Source: DATA_MODEL_SPEC.md lines 155-165**

**Decimal Formatting:**
- `1.0` → Display as `"1"` (no decimal)
- `2.5` → Display as `"2.5"` (show decimal)

**Unit Formatting:**
- Bowls/Joints/Blunts: Append ` bowls`, ` joints`, ` blunts`
- Vape: Append ` pulls`
- Dab: Append ` dabs`
- Edible: Append `mg` (NO space)

**Examples:**
```swift
displayAmount(method: "Bowls", amount: 1.0)   // → "1 bowls"
displayAmount(method: "Bowls", amount: 2.5)   // → "2.5 bowls"
displayAmount(method: "Vape", amount: 5.0)    // → "5 pulls"
displayAmount(method: "Edible", amount: 25.0) // → "25mg"
```

#### UI Behavior Requirements

**Source: CLINICAL_CANNABIS_SPEC.md lines 220-224**

1. **Dynamic Range Update:**
   - When user changes ROA method (e.g., Bowls → Vape), picker options MUST update immediately
   - Selected amount MUST reset to first valid option for new method
   - Example: User has "2.5 bowls" selected, switches to Vape → reset to "1 pulls"

2. **Picker Style:**
   - Use `.pickerStyle(.wheel)` for iOS familiarity
   - Height: 120pt (3-4 visible options at once)
   - NO inline style (takes too much vertical space)

3. **Visual Hierarchy:**
   - Label: "Amount" (secondary font, consistent with other form labels)
   - Picker: Primary focus

---

## ✅ Acceptance Criteria (Definition of Done)

Before proceeding to Phase 2C, ALL of the following must be true:

### Code Completion
- [ ] ROAPickerInput.swift created (reusable SwiftUI component)
- [ ] Supports all 6 ROA methods
- [ ] Dynamic amount range updates when method changes
- [ ] Correct display formatting for all ROAs

### Validation Tests
- [ ] **Test 1:** Bowls range has 10 options (0.5 → 5.0)
- [ ] **Test 2:** Vape range has 10 options (1 → 10)
- [ ] **Test 3:** Dab range has 5 options (1 → 5)
- [ ] **Test 4:** Edible range has 20 options (5 → 100)
- [ ] **Test 5:** Display formatting correct for all 6 ROAs
- [ ] All 5 tests passing ✅

### Preview Validation (Manual QA)
- [ ] Preview shows picker for each ROA method
- [ ] Picker wheel scrolls smoothly
- [ ] Amount updates when method changes in preview
- [ ] Display text matches spec formatting

### Build Status
- [ ] Zero compilation errors
- [ ] Zero SwiftLint violations
- [ ] SwiftFormat applied

---

## 📝 Implementation Steps

### Step 1: Create ROAPickerInput Component

**File:** `Cravey/Presentation/Views/Components/ROAPickerInput.swift`

**Dependencies:**
- Requires `ROAAmountRange` helper (created in Phase 2A Step 3)

```swift
import SwiftUI

/// ROA-aware amount picker that dynamically adjusts range based on selected method
/// Source: CLINICAL_CANNABIS_SPEC.md lines 220-224
struct ROAPickerInput: View {
    /// The currently selected ROA method (e.g., "Bowls", "Vape")
    let selectedMethod: String

    /// The selected amount (binding to parent's state)
    @Binding var amount: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            Text("Amount")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Picker (wheel style for fast selection)
            Picker("Amount", selection: $amount) {
                ForEach(amountOptions, id: \.self) { value in
                    Text(displayText(for: value))
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
        }
    }

    // MARK: - Private Helpers

    /// Get valid amount options for current method
    /// Uses ROAAmountRange helper from Phase 2A
    private var amountOptions: [Double] {
        return ROAAmountRange.range(for: selectedMethod)
    }

    /// Format amount for display in picker
    /// Source: DATA_MODEL_SPEC.md lines 155-165
    private func displayText(for amount: Double) -> String {
        return ROAAmountRange.displayAmount(method: selectedMethod, amount: amount)
    }
}

// MARK: - Previews

#Preview("Bowls (10 options)") {
    struct PreviewWrapper: View {
        @State private var amount = 1.0

        var body: some View {
            VStack(spacing: 20) {
                Text("Selected: \(ROAAmountRange.displayAmount(method: "Bowls", amount: amount))")
                    .font(.headline)

                ROAPickerInput(selectedMethod: "Bowls", amount: $amount)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Vape (10 options)") {
    struct PreviewWrapper: View {
        @State private var amount = 1.0

        var body: some View {
            VStack(spacing: 20) {
                Text("Selected: \(ROAAmountRange.displayAmount(method: "Vape", amount: amount))")
                    .font(.headline)

                ROAPickerInput(selectedMethod: "Vape", amount: $amount)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Edible (20 options)") {
    struct PreviewWrapper: View {
        @State private var amount = 5.0

        var body: some View {
            VStack(spacing: 20) {
                Text("Selected: \(ROAAmountRange.displayAmount(method: "Edible", amount: amount))")
                    .font(.headline)

                ROAPickerInput(selectedMethod: "Edible", amount: $amount)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Dynamic Method Switching") {
    struct PreviewWrapper: View {
        @State private var method = "Bowls"
        @State private var amount = 1.0

        var body: some View {
            VStack(spacing: 20) {
                // Method selector
                Picker("Method", selection: $method) {
                    Text("Bowls").tag("Bowls")
                    Text("Vape").tag("Vape")
                    Text("Edible").tag("Edible")
                }
                .pickerStyle(.segmented)
                .onChange(of: method) { _, newMethod in
                    // Reset amount to first valid option when method changes
                    if let firstAmount = ROAAmountRange.range(for: newMethod).first {
                        amount = firstAmount
                    }
                }

                // Amount picker (updates dynamically)
                ROAPickerInput(selectedMethod: method, amount: $amount)

                // Display selected
                Text("Selected: \(ROAAmountRange.displayAmount(method: method, amount: amount))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
```

**Checkpoint:** Build succeeds, component compiles, previews render

---

### Step 2: Manual Preview Validation

**Open Xcode Canvas and verify ALL 4 previews:**

**Preview 1: "Bowls (10 options)"**
- [ ] Picker shows "0.5 bowls" through "5 bowls"
- [ ] Exactly 10 options visible when scrolling
- [ ] Selected amount displays as "1 bowls" (not "1.0 bowls")

**Preview 2: "Vape (10 options)"**
- [ ] Picker shows "1 pulls" through "10 pulls"
- [ ] Exactly 10 options visible when scrolling
- [ ] Selected amount displays as "5 pulls" (integer, no decimal)

**Preview 3: "Edible (20 options)"**
- [ ] Picker shows "5mg" through "100mg"
- [ ] Exactly 20 options visible when scrolling
- [ ] Selected amount displays as "25mg" (NO space before "mg")

**Preview 4: "Dynamic Method Switching"**
- [ ] Segmented control allows switching between Bowls/Vape/Edible
- [ ] Picker options update immediately when method changes
- [ ] Amount resets to first valid option when method changes
- [ ] Display text updates to match new method

**If any preview fails:** Fix component before writing tests

---

## 🧪 Validation Tests (Step 3)

**File:** `CraveyTests/Presentation/Components/ROAPickerInputTests.swift`

**Purpose:** Validate spec compliance for all 6 ROAs

```swift
import Testing
@testable import Cravey

@Suite("ROAPickerInput Tests (Phase 2B)")
struct ROAPickerInputTests {

    // MARK: - Test 1: Bowls Range

    @Test("Bowls should have 10 options (0.5 → 5.0, increment 0.5)")
    func testBowlsRange() {
        let range = ROAAmountRange.range(for: "Bowls")

        // Verify count
        #expect(range.count == 10)

        // Verify min/max
        #expect(range.first == 0.5)
        #expect(range.last == 5.0)

        // Verify increments
        #expect(range.contains(1.0))
        #expect(range.contains(2.5))
        #expect(range.contains(4.5))
    }

    // MARK: - Test 2: Vape Range

    @Test("Vape should have 10 options (1 → 10, increment 1)")
    func testVapeRange() {
        let range = ROAAmountRange.range(for: "Vape")

        // Verify count
        #expect(range.count == 10)

        // Verify min/max
        #expect(range.first == 1.0)
        #expect(range.last == 10.0)

        // Verify increments (all integers)
        #expect(range.contains(5.0))
        #expect(range.contains(10.0))
    }

    // MARK: - Test 3: Dab Range

    @Test("Dab should have 5 options (1 → 5, increment 1)")
    func testDabRange() {
        let range = ROAAmountRange.range(for: "Dab")

        // Verify count (smallest range)
        #expect(range.count == 5)

        // Verify min/max
        #expect(range.first == 1.0)
        #expect(range.last == 5.0)
    }

    // MARK: - Test 4: Edible Range

    @Test("Edible should have 20 options (5mg → 100mg, increment 5mg)")
    func testEdibleRange() {
        let range = ROAAmountRange.range(for: "Edible")

        // Verify count (largest range)
        #expect(range.count == 20)

        // Verify min/max
        #expect(range.first == 5.0)
        #expect(range.last == 100.0)

        // Verify increments
        #expect(range.contains(25.0))
        #expect(range.contains(50.0))
        #expect(range.contains(75.0))
    }

    // MARK: - Test 5: Display Formatting

    @Test("Display formatting should match spec for all ROAs")
    func testDisplayFormatting() {
        // Bowls: integer without decimal
        #expect(ROAAmountRange.displayAmount(method: "Bowls", amount: 1.0) == "1 bowls")

        // Bowls: decimal shown
        #expect(ROAAmountRange.displayAmount(method: "Bowls", amount: 2.5) == "2.5 bowls")

        // Vape: integer pulls
        #expect(ROAAmountRange.displayAmount(method: "Vape", amount: 5.0) == "5 pulls")

        // Dab: integer dabs
        #expect(ROAAmountRange.displayAmount(method: "Dab", amount: 3.0) == "3 dabs")

        // Edible: mg format (NO space)
        #expect(ROAAmountRange.displayAmount(method: "Edible", amount: 25.0) == "25mg")
    }
}
```

**Run Tests:**

```bash
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests/ROAPickerInputTests | xcbeautify
```

**Expected:** ✅ 5/5 tests passing

**If tests fail:** Fix ROAAmountRange helper (Phase 2A) or component

---

## ✅ Completion Checklist

### Files Created (1 file)
- [ ] `Presentation/Views/Components/ROAPickerInput.swift`

### Tests Created (1 file)
- [ ] `CraveyTests/Presentation/Components/ROAPickerInputTests.swift` (5 tests)

### Validation
- [ ] All 5 component tests passing ✅
- [ ] All 4 previews render correctly in Xcode Canvas
- [ ] Dynamic method switching works in preview
- [ ] Display formatting matches spec for all 6 ROAs
- [ ] Build succeeds with zero errors
- [ ] SwiftFormat applied
- [ ] No new SwiftLint violations

### Spec Compliance
- [ ] Bowls range: 10 options (0.5 → 5.0, increment 0.5) ✅
- [ ] Joints range: 10 options (0.5 → 5.0, increment 0.5) ✅
- [ ] Blunts range: 10 options (0.5 → 5.0, increment 0.5) ✅
- [ ] Vape range: 10 options (1 → 10, increment 1) ✅
- [ ] Dab range: 5 options (1 → 5, increment 1) ✅
- [ ] Edible range: 20 options (5 → 100, increment 5) ✅
- [ ] Display formatting matches DATA_MODEL_SPEC.md lines 155-165 ✅

---

## 🚀 What's Next: Phase 2C

**Phase 2C Goal:** Build full UsageLogForm and integrate into HomeView

**Why Separate:** With data layer (2A) and picker component (2B) validated, we can now assemble the complete feature with confidence. No surprises, no rework.

**Files to Create in 2C:**
- `Presentation/ViewModels/UsageLogViewModel.swift`
- `Presentation/Views/Usage/UsageLogForm.swift`
- `Presentation/ViewModels/UsageListViewModel.swift`
- `Presentation/Views/Usage/UsageListView.swift`
- Modify `Presentation/Views/Home/HomeView.swift` (wire up "Log Usage")
- Integration tests + UI tests

**Checkpoint:** Full end-to-end usage logging working, <10 sec validated

---

**Status:** ✅ Phase 2B complete when all checkboxes marked
**Ready for:** Phase 2C (Form & Integration)

**[← Back to Phase 2A](./PHASE_2A.md)** | **[Phase 2C (Form & Integration) →](./PHASE_2C.md)**
