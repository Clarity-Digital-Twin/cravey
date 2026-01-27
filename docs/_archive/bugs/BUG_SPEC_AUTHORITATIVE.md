# Authoritative Bug Specification - Cravey iOS App

> ⚠️ Archived: Historical bug tracker. The current bug tracker lives in `docs/bugs/`.

**Date:** 2025-12-10
**Status:** ✅ ALL BUGS FIXED (2025-12-10)
**Sources:** Manual QA + Code Analysis + External Audit (Gemini CLI)

---

## Resolution Summary

All 7 actionable bugs have been fixed. BUG-005 (SwiftData concurrency) was documented as acceptable.

| Bug ID | Fix Applied | Test Status |
|--------|-------------|-------------|
| BUG-001 | Removed NavigationStack from UsageListView | ✅ 32/32 tests pass |
| BUG-002 | Added `.contentShape(Capsule())` to ChipButton | ✅ Build succeeds |
| BUG-003 | Created `SingleSelectChipSelector` component | ✅ No Set allocation |
| BUG-004 | Used `OptionalSingleSelectChipSelector` + `selectedLocation: String?` | ✅ Aligned with BUG-003 |
| BUG-005 | Documented as acceptable (all callers are @MainActor) | N/A |
| BUG-006 | Added `shouldShowNotesCounter` computed property | ✅ Matches UsageLogForm |
| BUG-007 | Added "Recent Cravings" / "Recent Usage" section headers | ✅ UX improved |
| BUG-008 | Aligned ViewModel color scheme with CravingListView | ✅ Consistent UI |

---

## Executive Summary

This document consolidates findings from two independent audits into a single source of truth. Each bug has been validated by reading the actual source code. **8 bugs confirmed**, prioritized for fix order.

---

## Validated Bug List

### BUG-001: Nested NavigationStack in UsageListView [P0 - CRITICAL]

**Status:** CONFIRMED
**File:** `Cravey/Presentation/Views/Usage/UsageListView.swift`
**Lines:** 9-37

**Evidence:**

```swift
// UsageListView.swift:9-10
struct UsageListView: View {
    var body: some View {
        NavigationStack {  // <-- BUG: Nested inside HomeView's NavigationStack
```

```swift
// HomeView.swift:24-25
var body: some View {
    NavigationStack {  // <-- Parent NavigationStack
        VStack {
            CravingListView(...)
            UsageListView(...)  // <-- Has its own NavigationStack
```

**Impact:**

- Navigation title shows "Usage History" instead of "Home"
- iOS 18 nested NavigationStack causes undefined behavior
- Potential double-push bugs ([Apple Forums](https://developer.apple.com/forums/thread/759542))

**Fix:** Remove `NavigationStack` wrapper from `UsageListView.swift` (lines 10 and 37)

---

### BUG-002: ChipButton Missing .contentShape() [P0 - CRITICAL]

**Status:** CONFIRMED
**File:** `Cravey/Presentation/Views/Components/ChipSelector.swift`
**Lines:** 50-66

**Evidence:**

```swift
// ChipSelector.swift:50-66
struct ChipButton: View {
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(...)
                .clipShape(Capsule())
        }
        // MISSING: .contentShape(Capsule())
    }
}
```

**Impact:**

- Taps on chip padding don't register (only text area responds)
- iOS 18 documented regression ([Medium](https://medium.com/@gauravkumarjaipur/swiftui-buttons-not-working-in-ios-18-heres-what-we-need-to-know-and-how-to-fix-it-3e5b2ea9357b))
- User reports difficulty selecting triggers and methods

**Fix:** Add `.contentShape(Capsule())` after the Button closure

---

### BUG-003: ROA Method Selector Creates Set Every Render [P1 - HIGH]

**Status:** CONFIRMED
**File:** `Cravey/Presentation/Views/Usage/UsageLogForm.swift`
**Lines:** 29-37

**Evidence:**

```swift
// UsageLogForm.swift:32-34
selectedValues: Binding(
    get: { [viewModel.selectedMethod] },  // Creates new Set EVERY render
    set: { viewModel.selectedMethod = $0.first ?? "Bowls" }
),
```

**Impact:**

- Memory allocation on every SwiftUI view update
- SwiftUI may lose track of selection state
- Contributes to tap responsiveness issues

**Fix:** Create dedicated `SingleSelectChipSelector` component OR store as `Set<String>` in ViewModel

**Note:** Same pattern exists in `CravingLogForm.swift:33-39` for location selector - both need fixing.

---

### BUG-004: CravingLogForm Location Selector Same Anti-Pattern [P1 - HIGH]

**Status:** CONFIRMED (MISSED BY EXTERNAL AUDIT)
**File:** `Cravey/Presentation/Views/Craving/CravingLogForm.swift`
**Lines:** 33-41

**Evidence:**

```swift
// CravingLogForm.swift:33-39
selectedValues: Binding(
    get: {
        viewModel.location.isEmpty ? [] : Set([viewModel.location])  // Creates Set every render
    },
    set: {
        viewModel.location = $0.first ?? ""
    }
),
```

**Impact:** Same as BUG-003

**Fix:** Same as BUG-003

---

### BUG-005: SwiftData Concurrency Risk with nonisolated(unsafe) [P1 - HIGH]

**Status:** CONFIRMED - ACCEPTABLE WITH CURRENT ARCHITECTURE
**Files:**

- `Cravey/Data/Repositories/CravingRepository.swift:6`
- `Cravey/Data/Repositories/UsageRepository.swift:6`

**Evidence:**

```swift
// CravingRepository.swift:6
private nonisolated(unsafe) let modelContext: ModelContext
```

**Analysis:**

The external audit flagged this as a risk. After validation:

1. **ViewModels are `@MainActor`** - All ViewModels that call Use Cases are marked `@MainActor`:
   - `CravingLogViewModel.swift:8`: `@MainActor`
   - `UsageLogViewModel.swift:8`: `@MainActor`
   - `CravingListViewModel.swift:8`: `@MainActor`
   - `UsageListViewModel.swift:7`: `@MainActor`

2. **Use Cases are NOT isolated** - `DefaultLogCravingUseCase` and `DefaultLogUsageUseCase` are not `@MainActor`, but they are only called from `@MainActor` contexts (ViewModels).

3. **Risk:** If anyone ever calls a Use Case from a background task, it will crash.

**Verdict:** ACCEPTABLE for now. The current call chain is safe:

```text
View (@MainActor) → ViewModel (@MainActor) → UseCase → Repository (nonisolated(unsafe))
```

**Future Mitigation:** Consider `@ModelActor` pattern for v2.0

---

### BUG-006: CravingLogForm Character Counter Always Visible [P2 - MEDIUM]

**Status:** CONFIRMED
**File:** `Cravey/Presentation/Views/Craving/CravingLogForm.swift`
**Lines:** 48-53

**Evidence:**

```swift
// CravingLogForm.swift:48-53
HStack {
    Spacer()
    Text(viewModel.notesCharacterCount)  // Always shows "0/500"
        .font(.caption)
        .foregroundColor(viewModel.notesExceedsLimit ? .red : .secondary)
}
```

vs `UsageLogForm.swift:76-82`:

```swift
// UsageLogForm.swift:76-82
if viewModel.shouldShowNotesCounter {  // Only shows at 400+ chars
    HStack {
        Spacer()
        Text("\(viewModel.notesCharacterCount)/500")
```

**Impact:** UX inconsistency between forms

**Fix:** Add conditional `if viewModel.notes.count >= 400` wrapper in CravingLogForm

---

### BUG-007: Missing Section Headers on HomeView [P2 - MEDIUM]

**Status:** CONFIRMED
**File:** `Cravey/Presentation/Views/Home/HomeView.swift`
**Lines:** 26-47

**Evidence:**

```swift
// HomeView.swift:26-47
VStack(spacing: 0) {
    // TODO: Quick Play section

    if let viewModel = cravingListViewModel {
        CravingListView(viewModel: viewModel)  // No "Cravings" header
    }

    if let viewModel = usageListViewModel {
        UsageListView(viewModel: viewModel)   // No "Usage" header
    }
}
```

**Impact:** Users cannot distinguish between craving and usage entries

**Fix:** Add section headers with "Cravings" and "Usage History" labels

---

### BUG-008: Intensity Badge Color Range Mismatch [P3 - LOW]

**Status:** OBSERVED - DESIGN DECISION
**File:** `Cravey/Presentation/Views/Craving/CravingListView.swift`
**Lines:** 71-79

**Evidence:**

```swift
// CravingListView.swift:71-79
private func intensityColor(for intensity: Int) -> Color {
    switch intensity {
    case 1 ... 3: return .green
    case 4 ... 6: return .yellow   // Intensity 5 shows yellow
    case 7 ... 8: return .orange
    case 9 ... 10: return .red
    default: return .gray
    }
}
```

vs `CravingLogViewModel.swift:107-114`:

```swift
var intensityColor: String {
    switch Int(intensity) {
    case 1 ... 3: return "green"
    case 4 ... 6: return "orange"  // Different! Uses orange for 4-6
    case 7 ... 10: return "red"
    default: return "gray"
    }
}
```

**Impact:** Minor inconsistency, low impact

**Fix:** Align color schemes between list view and ViewModel

---

## Issues NOT Confirmed (Disputed)

### External Audit Issue C: Loading State Logic

**Claim:** Full-screen loading spinner is jarring when embedded

**Verdict:** NOT A BUG

**Evidence:** `CravingListView.swift:10-11` shows a simple `ProgressView()` which is appropriate for embedded views. The `UsageListView` loading state is more elaborate but still acceptable.

**Recommendation:** No action needed for MVP

---

### External Audit Bug #3: FlowLayout Gesture Blocking

**Claim:** FlowLayout custom Layout may block gestures

**Verdict:** SUSPECTED - LIKELY SYMPTOM OF BUG-002

**Evidence:** No direct evidence of FlowLayout causing issues. The tap problems are better explained by BUG-002 (missing `.contentShape()`).

**Recommendation:** Fix BUG-002 first, then reassess

---

## Prioritized Fix Order

### P0 - Critical (Fix Immediately)

| Bug | Description | Effort | File |
|-----|-------------|--------|------|
| BUG-001 | Nested NavigationStack | 2 min | UsageListView.swift |
| BUG-002 | ChipButton contentShape | 5 min | ChipSelector.swift |

### P1 - High (Fix Before Testing)

| Bug | Description | Effort | File |
|-----|-------------|--------|------|
| BUG-003 | ROA selector binding | 15 min | UsageLogForm.swift |
| BUG-004 | Location selector binding | 15 min | CravingLogForm.swift |
| BUG-005 | Concurrency risk | N/A | Acceptable, document only |

### P2 - Medium (Fix Before App Store)

| Bug | Description | Effort | File |
|-----|-------------|--------|------|
| BUG-006 | Counter visibility | 5 min | CravingLogForm.swift |
| BUG-007 | Section headers | 10 min | HomeView.swift |

### P3 - Low (Technical Debt)

| Bug | Description | Effort | File |
|-----|-------------|--------|------|
| BUG-008 | Color scheme alignment | 5 min | CravingListView.swift |

---

## Total Estimated Fix Time

- **P0 Fixes:** ~7 minutes
- **P1 Fixes:** ~30 minutes
- **P2 Fixes:** ~15 minutes
- **P3 Fixes:** ~5 minutes

**Total:** ~1 hour

---

## Validation Complete

This document represents the authoritative bug specification. All claims have been validated by reading actual source code. The external audit was helpful but contained one missed issue (BUG-004) and one non-issue (Loading State Logic).

**Ready for implementation.**
