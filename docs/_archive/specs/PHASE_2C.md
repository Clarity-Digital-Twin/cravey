# Phase 2C: Usage Logging - Form & Integration

> ⚠️ Archived: Historical phase doc. Not current SSOT.

**Version:** 1.0 (Spec-First Approach)
**Duration:** Day 2-3 (ViewModels + Views + Integration)
**Dependencies:** Phase 2A + 2B complete (data layer + picker validated)
**Status:** 📋 Ready to implement

---

## 🎯 Phase Goal

**Deliverable:** Complete, production-ready usage logging feature with **<10 second logging time** validated by UI tests.

**What We're Building:**
- UsageLogViewModel (form state management)
- UsageLogForm (full UI with ROA picker + optional fields)
- UsageListViewModel (fetch + display logic)
- UsageListView (usage history display)
- HomeView integration ("Log Usage" button + list display)
- End-to-end tests (integration + UI)

**What We're Reusing (From Phase 1):**
- ✅ ChipSelector (triggers + location)
- ✅ TimestampPicker (date/time selection)
- ✅ TriggerOptions (HAALT constants)
- ✅ LocationOptions (presets)
- ✅ DependencyContainer pattern (environment injection)

**Why This Approach:**
Data layer (2A) and picker (2B) are validated. This phase assembles the complete feature using proven components from Phase 1 and validated components from 2A/2B.

---

## 📋 SPEC VALIDATION (Read Before Coding)

### Tier 1 Requirements

**Source: MVP_PRODUCT_SPEC.md lines 146-184 + CLINICAL_CANNABIS_SPEC.md lines 216-243**

#### Form Requirements

**Required Fields** (top of form, <10 sec logging):
1. **ROA Method** - Picker (Bowls, Joints, Blunts, Vape, Dab, Edible)
2. **Amount** - ROAPickerInput (validated in Phase 2B, defaults to first valid option per ROA)
3. **Timestamp** - TimestampPicker (defaults to "now", editable with >7 days warning)

**Optional Fields** (below divider, "Details" section):
4. **Triggers** - ChipSelector (multi-select HAALT)
5. **Location** - ChipSelector (single-select presets, GPS deferred to Phase 2)
6. **Notes** - TextField (freeform, 500 char limit with counter at 400 chars)

#### UX Requirements

**Source: MVP_PRODUCT_SPEC.md lines 151-155**

**Form Pattern:**
- Single scrollable form (Apple Health/Calendar style)
- Core fields at top (NO scrolling needed for quick log)
- Optional fields below divider
- Cancel/Save toolbar buttons
- Success alert shows BEFORE dismiss

**Performance:**
- **<10 seconds** from tap "Log Usage" to success alert (MVP_PRODUCT_SPEC.md:151)
- Faster than craving logging (<5 sec) because more fields
- Quick log = Method + Amount + Save (3 taps)

#### Success Feedback

**Source: UX_FLOW_SPEC.md lines 396-405**

**Required Behavior:**
1. **Haptic feedback** - Success vibration on save
2. **Sheet dismissal** - Bottom sheet slides down (0.3s animation)
3. **Toast notification** - "Usage logged ✓" (2s auto-dismiss, top of screen)

**NOT an alert** - No "OK" button, immediate dismissal with haptic + toast

(Neutral, factual tone - no judgment about use)

---

## ✅ Acceptance Criteria (Definition of Done)

Before marking Phase 2 complete, ALL of the following must be true:

### Code Completion
- [ ] UsageLogViewModel created (@Observable, @MainActor)
- [ ] UsageLogForm created (reuses Phase 1 components)
- [ ] UsageListViewModel created (fetches usage via use case)
- [ ] UsageListView created (displays usage history)
- [ ] HomeView updated ("Log Usage" button + usage list)
- [ ] DependencyContainer factory method added (`makeUsageLogViewModel()`)

### Validation Tests
- [ ] **ViewModel Test 1:** `canSubmit` validates method + amount
- [ ] **ViewModel Test 2:** `logUsage()` triggers haptic + toast (not alert)
- [ ] **ViewModel Test 3:** Amount resets to first valid option when method changes
- [ ] **ViewModel Test 4:** Notes validation enforces 500 char limit
- [ ] **ViewModel Test 5:** Timestamp >7 days shows warning
- [ ] **List VM Test 1:** Fetches usage successfully
- [ ] **List VM Test 2:** Handles empty state
- [ ] **Integration Test 1:** End-to-end usage log (Form → VM → UC → Repo)
- [ ] **Integration Test 2:** Fetch and display usage from SwiftData
- [ ] **UI Test 1:** <10 sec validation (tap "Log Usage" → save)
- [ ] All 10 tests passing ✅

### Manual QA
- [ ] Log usage with all 6 ROAs (Bowls, Joints, Blunts, Vape, Dab, Edible)
- [ ] Verify amount picker updates when ROA changes
- [ ] Verify amount defaults to first valid option (0.5 for Bowls)
- [ ] Verify triggers multi-select works (reused ChipSelector)
- [ ] Verify location single-select works (reused ChipSelector)
- [ ] Verify timestamp defaults to "now" (reused TimestampPicker)
- [ ] Verify timestamp >7 days shows warning alert
- [ ] Verify notes character counter appears at 400 chars
- [ ] Verify notes cannot exceed 500 chars
- [ ] Verify haptic feedback on save (phone vibrates)
- [ ] Verify sheet dismisses immediately (no "OK" button)
- [ ] Verify toast "Usage logged ✓" appears at top (2s)
- [ ] Verify usage list auto-refreshes after logging
- [ ] Verify <10 sec logging time (stopwatch test)

### Build Status
- [ ] Zero compilation errors
- [ ] SwiftFormat applied to all new files
- [ ] No new SwiftLint violations

---

## 📝 Implementation Steps

### Step 1: Create UsageLogViewModel

**File:** `Cravey/Presentation/ViewModels/UsageLogViewModel.swift`

**Pattern:** Copy from CravingLogViewModel, adjust for usage fields

```swift
import Foundation
import Observation

@Observable
@MainActor
final class UsageLogViewModel {
    // Dependencies
    private let logUsageUseCase: LogUsageUseCase

    // Form fields (required)
    var timestamp: Date = Date()
    var selectedMethod: String = "Bowls" {
        didSet {
            // Auto-update amount to first valid option when method changes
            updateAmountForMethod()
        }
    }
    var amount: Double = 0.5  // Default to first valid option for Bowls (DATA_MODEL_SPEC:166)

    // Form fields (optional)
    var selectedTriggers: Set<String> = []
    var selectedLocation: String? = nil
    var notes: String = "" {
        didSet {
            // Enforce 500 char limit (DATA_MODEL_SPEC:122, UX_FLOW:391)
            if notes.count > 500 {
                notes = String(notes.prefix(500))
            }
        }
    }

    // UI state
    var showSuccessToast: Bool = false  // Toast instead of alert (UX_FLOW:396-405)
    var showTimestampWarning: Bool = false  // >7 days warning (DATA_MODEL_SPEC:117)
    var errorMessage: String? = nil
    var isLoading: Bool = false

    init(logUsageUseCase: LogUsageUseCase) {
        self.logUsageUseCase = logUsageUseCase
    }

    /// Validate form can be submitted
    var canSubmit: Bool {
        return !selectedMethod.isEmpty && amount > 0
    }

    /// Character count for notes (show counter at 400+ chars)
    var notesCharacterCount: Int {
        return notes.count
    }

    /// Show notes character counter (at 400+ chars per UX_FLOW:391)
    var shouldShowNotesCounter: Bool {
        return notes.count >= 400
    }

    /// Check if timestamp is >7 days old (DATA_MODEL_SPEC:117)
    var isTimestampOld: Bool {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return timestamp < sevenDaysAgo
    }

    /// Log usage via use case
    func logUsage() async {
        // Check for old timestamp warning
        if isTimestampOld && !showTimestampWarning {
            showTimestampWarning = true
            return  // Wait for user to confirm
        }

        guard canSubmit else { return }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await logUsageUseCase.execute(
                timestamp: timestamp,
                method: selectedMethod,
                amount: amount,
                triggers: Array(selectedTriggers),
                location: selectedLocation,
                notes: notes.isEmpty ? nil : notes
            )

            // Trigger haptic + toast (UX_FLOW:396-405)
            triggerSuccessFeedback()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Confirm old timestamp and proceed with logging
    func confirmOldTimestamp() async {
        showTimestampWarning = false
        await logUsage()  // Proceed with save
    }

    /// Trigger success feedback (haptic + toast per UX_FLOW:396-405)
    private func triggerSuccessFeedback() {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Show toast
        showSuccessToast = true
    }

    /// Reset amount to first valid option when method changes
    /// Called automatically via didSet on selectedMethod
    func updateAmountForMethod() {
        let validAmounts = ROAAmountRange.range(for: selectedMethod)
        if let firstAmount = validAmounts.first {
            amount = firstAmount
        }
    }

    /// Reset form to defaults (called after successful submit)
    func resetForm() {
        timestamp = Date()
        selectedMethod = "Bowls"
        amount = 0.5  // First valid option for Bowls
        selectedTriggers = []
        selectedLocation = nil
        notes = ""
        showTimestampWarning = false
    }
}
```

**Checkpoint:** Build succeeds, ViewModel compiles

---

### Step 2: Create UsageLogForm

**File:** `Cravey/Presentation/Views/Usage/UsageLogForm.swift`

**Pattern:** Copy from CravingLogForm, adjust for usage fields

**Reused Components:**
- ROAPickerInput (Phase 2B)
- TimestampPicker (Phase 1)
- ChipSelector (Phase 1)
- TriggerOptions (Phase 1)
- LocationOptions (Phase 1)

```swift
import SwiftUI
import UIKit  // For haptic feedback

struct UsageLogForm: View {
    @Bindable var viewModel: UsageLogViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // REQUIRED SECTION (Top - no scrolling needed for quick log)
                Section {
                    // ROA Method Picker
                    Picker("Method", selection: $viewModel.selectedMethod) {
                        Text("Bowls").tag("Bowls")
                        Text("Joints").tag("Joints")
                        Text("Blunts").tag("Blunts")
                        Text("Vape").tag("Vape")
                        Text("Dab").tag("Dab")
                        Text("Edible").tag("Edible")
                    }
                    .onChange(of: viewModel.selectedMethod) { _, _ in
                        viewModel.updateAmountForMethod()
                    }

                    // Amount Picker (ROA-aware, from Phase 2B)
                    ROAPickerInput(
                        selectedMethod: viewModel.selectedMethod,
                        amount: $viewModel.amount
                    )

                    // Timestamp (defaults to "now", from Phase 1)
                    TimestampPicker(date: $viewModel.timestamp)
                }

                // OPTIONAL SECTION (Below divider - Details)
                Section {
                    // Triggers (multi-select chips, from Phase 1)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Triggers (Optional)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        ChipSelector(
                            title: "",
                            options: TriggerOptions.all,
                            selectedValues: $viewModel.selectedTriggers,
                            multiSelect: true
                        )
                    }

                    // Location (single-select chips, from Phase 1)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location (Optional)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        ChipSelector(
                            title: "",
                            options: LocationOptions.presets,
                            selectedValues: Binding(
                                get: {
                                    if let location = viewModel.selectedLocation {
                                        return Set([location])
                                    }
                                    return []
                                },
                                set: { newValue in
                                    viewModel.selectedLocation = newValue.first
                                }
                            ),
                            multiSelect: false
                        )
                    }

                    // Notes (freeform text, 500 char limit)
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Notes (Optional)", text: $viewModel.notes, axis: .vertical)
                            .lineLimit(3...6)

                        // Character counter (appears at 400+ chars per UX_FLOW:391)
                        if viewModel.shouldShowNotesCounter {
                            Text("\(viewModel.notesCharacterCount)/500")
                                .font(.caption)
                                .foregroundStyle(viewModel.notesCharacterCount >= 500 ? .red : .secondary)
                        }
                    }
                }
            }
            .navigationTitle("Log Usage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.logUsage()
                        }
                    }
                    .disabled(!viewModel.canSubmit)
                }
            }
            // Timestamp warning (>7 days per DATA_MODEL_SPEC:117)
            .alert("Old Entry", isPresented: $viewModel.showTimestampWarning) {
                Button("Cancel", role: .cancel) {
                    viewModel.showTimestampWarning = false
                }
                Button("Save Anyway") {
                    Task {
                        await viewModel.confirmOldTimestamp()
                    }
                }
            } message: {
                Text("Memory may be less reliable for events >7 days ago. Continue?")
            }
            // Error alert
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            // Success toast (UX_FLOW:396-405)
            .onChange(of: viewModel.showSuccessToast) { _, show in
                if show {
                    // Dismiss sheet immediately (no "OK" button needed)
                    viewModel.resetForm()
                    dismiss()
                }
            }
        }
        // Toast overlay (appears after dismiss in parent view)
        .overlay(alignment: .top) {
            if viewModel.showSuccessToast {
                ToastView(message: "Usage logged ✓")
                    .padding(.top, 50)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut, value: viewModel.showSuccessToast)
                    .task {
                        try? await Task.sleep(for: .seconds(2))
                        viewModel.showSuccessToast = false
                    }
            }
        }
    }
}

// MARK: - Toast View

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.green.opacity(0.9))
            .clipShape(Capsule())
            .shadow(radius: 4)
    }
}

#Preview {
    let container = DependencyContainer()
    let viewModel = UsageLogViewModel(logUsageUseCase: container.logUsageUseCase)
    return UsageLogForm(viewModel: viewModel)
}
```

**Checkpoint:** Build succeeds, form renders in preview

---

### Step 3: Create UsageListViewModel

**File:** `Cravey/Presentation/ViewModels/UsageListViewModel.swift`

**Pattern:** Copy from CravingListViewModel, adjust for UsageEntity

```swift
import Foundation
import Observation

@Observable
@MainActor
final class UsageListViewModel {
    // Dependencies
    private let fetchUsageUseCase: FetchUsageUseCase

    // State
    var usageList: [UsageEntity] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    init(fetchUsageUseCase: FetchUsageUseCase) {
        self.fetchUsageUseCase = fetchUsageUseCase
    }

    /// Fetch all usage entries
    func fetchUsage() async {
        isLoading = true
        errorMessage = nil

        do {
            usageList = try await fetchUsageUseCase.execute()
        } catch {
            errorMessage = "Failed to load usage history"
        }

        isLoading = false
    }
}
```

**Checkpoint:** Build succeeds, ViewModel compiles

---

### Step 4: Create UsageListView

**File:** `Cravey/Presentation/Views/Usage/UsageListView.swift`

**Pattern:** Copy from CravingListView, adjust for usage display

```swift
import SwiftUI

struct UsageListView: View {
    @Bindable var viewModel: UsageListViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if viewModel.usageList.isEmpty {
                emptyStateView
            } else {
                usageListView
            }
        }
        .task {
            await viewModel.fetchUsage()
        }
        .refreshable {
            await viewModel.fetchUsage()
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Usage Logged",
            systemImage: "leaf.fill",
            description: Text("Your usage history will appear here")
        )
    }

    private var usageListView: some View {
        List {
            ForEach(viewModel.usageList, id: \.id) { usage in
                UsageRowView(usage: usage)
            }
        }
        .listStyle(.plain)
    }
}

struct UsageRowView: View {
    let usage: UsageEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Method + Amount (e.g., "2.5 bowls", "25mg")
                Text(ROAAmountRange.displayAmount(method: usage.method, amount: usage.amount))
                    .font(.headline)

                Spacer()

                // Timestamp (relative time)
                Text(usage.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Triggers (if any)
            if !usage.triggers.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "tag.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(usage.triggers.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Location (if any)
            if let location = usage.location {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(LocationOptions.displayLocation(location))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Notes (if any)
            if let notes = usage.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview("With Data") {
    let container = DependencyContainer()
    let viewModel = UsageListViewModel(fetchUsageUseCase: container.fetchUsageUseCase)

    // Mock data
    viewModel.usageList = [
        UsageEntity(
            timestamp: Date(),
            method: "Bowls",
            amount: 2.5,
            triggers: ["Anxious", "Bored"],
            location: "Home"
        ),
        UsageEntity(
            timestamp: Date().addingTimeInterval(-3600),
            method: "Edible",
            amount: 25.0,
            triggers: ["Social"],
            location: "Home",
            notes: "With friends"
        )
    ]

    return NavigationStack {
        UsageListView(viewModel: viewModel)
            .navigationTitle("Usage History")
    }
}

#Preview("Empty State") {
    let container = DependencyContainer()
    let viewModel = UsageListViewModel(fetchUsageUseCase: container.fetchUsageUseCase)

    return NavigationStack {
        UsageListView(viewModel: viewModel)
            .navigationTitle("Usage History")
    }
}
```

**Checkpoint:** Build succeeds, list renders in preview

---

### Step 5: Update HomeView

**Modify:** `Cravey/Presentation/Views/Home/HomeView.swift`

**Changes:**
1. Add `@State` for usage log sheet
2. Add usage list below craving list
3. Wire "Log Usage" button to sheet

```swift
import SwiftUI

struct HomeView: View {
    @Environment(DependencyContainer.self) private var container

    // Sheet state
    @State private var showCravingLogSheet = false
    @State private var showUsageLogSheet = false

    // Deferred ViewModel initialization (Phase 1 pattern)
    @State private var cravingLogViewModel: CravingLogViewModel?
    @State private var usageLogViewModel: UsageLogViewModel?

    // Refresh triggers
    @State private var cravingRefreshID = UUID()
    @State private var usageRefreshID = UUID()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Section 1: Cravings
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cravings")
                            .font(.headline)
                            .padding(.horizontal)

                        CravingListView(
                            viewModel: CravingListViewModel(
                                fetchCravingsUseCase: container.fetchCravingsUseCase
                            )
                        )
                        .id(cravingRefreshID)
                    }

                    Divider()
                        .padding(.horizontal)

                    // Section 2: Usage
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Usage")
                            .font(.headline)
                            .padding(.horizontal)

                        UsageListView(
                            viewModel: UsageListViewModel(
                                fetchUsageUseCase: container.fetchUsageUseCase
                            )
                        )
                        .id(usageRefreshID)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Log Craving") {
                            showCravingLogSheet = true
                        }

                        Button("Log Usage") {
                            showUsageLogSheet = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            // Craving Log Sheet (Phase 1)
            .sheet(isPresented: $showCravingLogSheet) {
                cravingLogViewModel = nil
                cravingRefreshID = UUID()  // Refresh list after dismiss
            } content: {
                if let viewModel = cravingLogViewModel {
                    CravingLogForm(viewModel: viewModel)
                } else {
                    Color.clear.task {
                        cravingLogViewModel = container.makeCravingLogViewModel()
                    }
                }
            }
            // Usage Log Sheet (Phase 2C)
            .sheet(isPresented: $showUsageLogSheet) {
                usageLogViewModel = nil
                usageRefreshID = UUID()  // Refresh list after dismiss
            } content: {
                if let viewModel = usageLogViewModel {
                    UsageLogForm(viewModel: viewModel)
                } else {
                    Color.clear.task {
                        usageLogViewModel = container.makeUsageLogViewModel()
                    }
                }
            }
        }
    }
}

#Preview {
    let container = DependencyContainer()
    return HomeView()
        .environment(container)
}
```

**Checkpoint:** Build succeeds, HomeView shows both lists

---

### Step 6: Update DependencyContainer

**Modify:** `Cravey/App/DependencyContainer.swift`

**Add factory method** (after `makeCravingLogViewModel()`, ~line 70):

```swift
/// Factory method for UsageLogViewModel
func makeUsageLogViewModel() -> UsageLogViewModel {
    return UsageLogViewModel(logUsageUseCase: logUsageUseCase)
}
```

**Checkpoint:** Build succeeds, factory method available

---

## 🧪 Validation Tests (Steps 7-8)

### Step 7: ViewModel Tests

**File:** `CraveyTests/Presentation/ViewModels/UsageLogViewModelTests.swift`

```swift
import Testing
@testable import Cravey

@Suite("UsageLogViewModel Tests (Phase 2C)")
@MainActor
struct UsageLogViewModelTests {

    // MARK: - Test 1: canSubmit Validation

    @Test("canSubmit should validate method and amount")
    func testCanSubmit() {
        let mockUseCase = MockLogUsageUseCase()
        let viewModel = UsageLogViewModel(logUsageUseCase: mockUseCase)

        // Valid state
        viewModel.selectedMethod = "Bowls"
        viewModel.amount = 2.5
        #expect(viewModel.canSubmit == true)

        // Invalid: zero amount
        viewModel.amount = 0
        #expect(viewModel.canSubmit == false)

        // Invalid: empty method (edge case)
        viewModel.selectedMethod = ""
        #expect(viewModel.canSubmit == false)
    }

    // MARK: - Test 2: logUsage Success

    @Test("logUsage should show success alert on success")
    func testLogUsageSuccess() async {
        let mockUseCase = MockLogUsageUseCase()
        let viewModel = UsageLogViewModel(logUsageUseCase: mockUseCase)

        viewModel.selectedMethod = "Vape"
        viewModel.amount = 5.0

        await viewModel.logUsage()

        #expect(viewModel.showSuccessAlert == true)
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - Test 3: updateAmountForMethod

    @Test("updateAmountForMethod should reset amount to first valid option")
    func testUpdateAmountForMethod() {
        let mockUseCase = MockLogUsageUseCase()
        let viewModel = UsageLogViewModel(logUsageUseCase: mockUseCase)

        // Change to Edible (first option is 5.0)
        viewModel.selectedMethod = "Edible"
        viewModel.updateAmountForMethod()

        #expect(viewModel.amount == 5.0)

        // Change to Vape (first option is 1.0)
        viewModel.selectedMethod = "Vape"
        viewModel.updateAmountForMethod()

        #expect(viewModel.amount == 1.0)
    }
}

// MARK: - Mocks

actor MockLogUsageUseCase: LogUsageUseCase {
    func execute(
        timestamp: Date,
        method: String,
        amount: Double,
        triggers: [String],
        location: String?,
        notes: String?
    ) async throws -> UsageEntity {
        return UsageEntity(
            timestamp: timestamp,
            method: method,
            amount: amount,
            triggers: triggers,
            location: location,
            notes: notes
        )
    }
}
```

**File:** `CraveyTests/Presentation/ViewModels/UsageListViewModelTests.swift`

```swift
import Testing
@testable import Cravey

@Suite("UsageListViewModel Tests (Phase 2C)")
@MainActor
struct UsageListViewModelTests {

    // MARK: - Test 4: Fetch Success

    @Test("fetchUsage should populate usageList")
    func testFetchSuccess() async {
        let mockUseCase = MockFetchUsageUseCase()
        let viewModel = UsageListViewModel(fetchUsageUseCase: mockUseCase)

        await viewModel.fetchUsage()

        #expect(viewModel.usageList.count == 2)
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - Test 5: Empty State

    @Test("fetchUsage should handle empty list")
    func testEmptyState() async {
        let mockUseCase = MockFetchUsageUseCase(returnEmpty: true)
        let viewModel = UsageListViewModel(fetchUsageUseCase: mockUseCase)

        await viewModel.fetchUsage()

        #expect(viewModel.usageList.isEmpty)
    }
}

// MARK: - Mocks

actor MockFetchUsageUseCase: FetchUsageUseCase {
    let returnEmpty: Bool

    init(returnEmpty: Bool = false) {
        self.returnEmpty = returnEmpty
    }

    func execute() async throws -> [UsageEntity] {
        if returnEmpty { return [] }

        return [
            UsageEntity(timestamp: Date(), method: "Bowls", amount: 2.5),
            UsageEntity(timestamp: Date().addingTimeInterval(-3600), method: "Edible", amount: 25.0)
        ]
    }

    func execute(since date: Date) async throws -> [UsageEntity] {
        return try await execute()
    }
}
```

**Run Tests:**

```bash
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests/UsageLogViewModelTests \
  -only-testing:CraveyTests/UsageListViewModelTests | xcbeautify
```

**Expected:** ✅ 5/5 ViewModel tests passing

---

### Step 8: Integration + UI Tests

**File:** `CraveyTests/Integration/UsageLogIntegrationTests.swift`

```swift
import Testing
import SwiftData
@testable import Cravey

@Suite("Usage Log Integration Tests (Phase 2C)")
struct UsageLogIntegrationTests {

    @Test("End-to-end usage log flow (Form → VM → UC → Repo → SwiftData)")
    @MainActor
    func testEndToEndFlow() async throws {
        // Setup in-memory SwiftData
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        // Create real dependencies
        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultLogUsageUseCase(repository: repository)
        let viewModel = UsageLogViewModel(logUsageUseCase: useCase)

        // Simulate form fill
        viewModel.selectedMethod = "Edible"
        viewModel.amount = 25.0
        viewModel.selectedTriggers = Set(["Anxious", "Bored"])
        viewModel.selectedLocation = "Home"
        viewModel.notes = "Integration test"

        // Log usage
        await viewModel.logUsage()

        // Verify VM state
        #expect(viewModel.showSuccessAlert == true)
        #expect(viewModel.errorMessage == nil)

        // Verify persisted to SwiftData
        let descriptor = FetchDescriptor<UsageModel>()
        let saved = try context.fetch(descriptor)
        #expect(saved.count == 1)
        #expect(saved.first?.method == "Edible")
        #expect(saved.first?.amount == 25.0)
    }

    @Test("Fetch and display usage from SwiftData")
    @MainActor
    func testFetchDisplay() async throws {
        // Setup
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        // Insert test data
        let model = UsageModel(timestamp: Date(), method: "Vape", amount: 5.0)
        context.insert(model)
        try context.save()

        // Fetch via VM
        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultFetchUsageUseCase(repository: repository)
        let viewModel = UsageListViewModel(fetchUsageUseCase: useCase)

        await viewModel.fetchUsage()

        // Verify
        #expect(viewModel.usageList.count == 1)
        #expect(viewModel.usageList.first?.method == "Vape")
    }
}
```

**File:** `CraveyUITests/UsageLogUITests.swift`

```swift
import XCTest

final class UsageLogUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testUsageLogUnder10Seconds() throws {
        let startTime = Date()

        // Navigate to Home tab
        let homeTab = app.tabBars.buttons["Home"]
        homeTab.tap()

        // Tap "+" menu
        let addButton = app.navigationBars.buttons.matching(identifier: "plus.circle.fill").firstMatch
        addButton.tap()

        // Tap "Log Usage"
        let logUsageButton = app.buttons["Log Usage"]
        logUsageButton.tap()

        // Wait for sheet
        let sheet = app.navigationBars["Log Usage"]
        XCTAssertTrue(sheet.waitForExistence(timeout: 2))

        // Quick log: default method (Bowls) + default amount + Save
        let saveButton = app.navigationBars.buttons["Save"]
        saveButton.tap()

        // Wait for success alert
        let successAlert = app.alerts["Success"]
        XCTAssertTrue(successAlert.waitForExistence(timeout: 2))

        let elapsed = Date().timeIntervalSince(startTime)
        XCTAssertLessThan(elapsed, 10.0, "Usage log should complete in <10 seconds (actual: \(elapsed)s)")

        // Dismiss alert
        successAlert.buttons["OK"].tap()
    }
}
```

**Run Tests:**

```bash
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests/UsageLogIntegrationTests \
  -only-testing:CraveyUITests/UsageLogUITests | xcbeautify
```

**Expected:** ✅ 3/3 tests passing (2 integration + 1 UI)

---

## ✅ Completion Checklist

### Files Created (4 files)
- [ ] `Presentation/ViewModels/UsageLogViewModel.swift`
- [ ] `Presentation/Views/Usage/UsageLogForm.swift`
- [ ] `Presentation/ViewModels/UsageListViewModel.swift`
- [ ] `Presentation/Views/Usage/UsageListView.swift`

### Files Modified (2 files)
- [ ] `Presentation/Views/Home/HomeView.swift` (added usage sheet + list)
- [ ] `App/DependencyContainer.swift` (added `makeUsageLogViewModel()`)

### Tests Created (3 files)
- [ ] `CraveyTests/Presentation/ViewModels/UsageLogViewModelTests.swift` (3 tests)
- [ ] `CraveyTests/Presentation/ViewModels/UsageListViewModelTests.swift` (2 tests)
- [ ] `CraveyTests/Integration/UsageLogIntegrationTests.swift` (2 tests)
- [ ] `CraveyUITests/UsageLogUITests.swift` (1 test)

### Validation
- [ ] All 8 tests passing ✅ (5 VM + 2 integration + 1 UI)
- [ ] Build succeeds with zero errors
- [ ] SwiftFormat applied to all new files
- [ ] No new SwiftLint violations

### Manual QA
- [ ] Log usage with all 6 ROAs (Bowls, Joints, Blunts, Vape, Dab, Edible)
- [ ] Amount picker updates when ROA changes
- [ ] Triggers multi-select works
- [ ] Location single-select works
- [ ] Timestamp defaults to "now"
- [ ] Success alert shows after Save
- [ ] "OK" on alert dismisses sheet
- [ ] Usage list auto-refreshes after logging
- [ ] <10 sec logging time validated (stopwatch)

### Spec Compliance
- [ ] Required fields match MVP_PRODUCT_SPEC.md:156-169 ✅
- [ ] Optional fields match MVP_PRODUCT_SPEC.md:171-177 ✅
- [ ] Notes 500 char limit enforced (DATA_MODEL_SPEC:122, UX_FLOW:391) ✅
- [ ] Timestamp >7 days warning implemented (DATA_MODEL_SPEC:117) ✅
- [ ] Success feedback = haptic + toast (UX_FLOW:396-405, NOT alert) ✅
- [ ] Default amount = first valid option (0.5 for Bowls) ✅
- [ ] <10 sec performance requirement met ✅

---

## 🔍 Scope Notes (Deferred Features)

**GPS "Current Location" Feature:**
- "Current Location" chip visible in LocationOptions (Phase 1 component)
- Tapping it does NOT trigger CoreLocation (same as Phase 1)
- GPS integration deferred to Phase 2 Week 2 (per Phase 1 scope decision)
- Placeholder text "Current Location" stored as string if selected
- See PHASE_1.md:32-34 for original deferral rationale

**Why Deferred:**
- Complexity: Requires CoreLocation permission flow + privacy prompt
- Phase 1 Week 1 scope: Get core logging working first
- Phase 2 adds this alongside other location features

**When Implemented:**
- Phase 2 Week 2 will add CoreLocation integration
- Privacy prompt: "Location data never leaves your device"
- GPS coordinates stored as "lat,long" string format

---

## 🎉 Phase 2 Complete!

**Deliverable:** Full usage logging feature with validated spec compliance

**What We Built:**
- Domain layer (entities, use cases, validation)
- Data layer (repository, mapper)
- Presentation layer (ViewModels, Views, components)
- Integration (HomeView wiring)
- Tests (14 total: 5 VM + 5 component + 2 integration + 2 UI from 2A/2B/2C combined)

**What We Validated:**
- All 6 ROAs accept correct amount ranges
- Dynamic picker updates when method changes
- HAALT triggers work (reused from Phase 1)
- Location presets work (reused from Phase 1)
- <10 second logging time met
- Auto-refresh after logging

**Total Files Created in Phase 2:** 14 files
- Phase 2A: 7 files (domain + data)
- Phase 2B: 1 file (ROA picker)
- Phase 2C: 6 files (ViewModels + Views)

**Total Tests Written in Phase 2:** 14 tests
- Phase 2A: 6 integration tests (data layer validation)
- Phase 2B: 5 component tests (ROA picker validation)
- Phase 2C: 3 VM tests + 2 integration + 1 UI test

---

## 🚀 What's Next: Phase 3

**Phase 3: Onboarding + Data Management (Weeks 3-4)**

Features:
- Welcome screen (first launch)
- App tour
- Export data (CSV)
- Delete all data (with confirmation)
- Settings polish

**See:** [PHASE_3.md](./PHASE_3.md)

---

**Status:** ✅ Phase 2 complete when all checkboxes marked
**Ready for:** Phase 3 (Onboarding + Data Management)

**[← Back to Phase 2B](./PHASE_2B.md)** | **[Phase 3 →](./PHASE_3.md)**
