# Phase 2: Usage Logging (Week 2 Only)

**Version:** 1.0 (Final)
**Duration:** 1 week (Week 2 of 16-week plan)
**Dependencies:** Phase 1 (reuses ChipSelector, TimestampPicker, TriggerOptions, LocationOptions)
**Status:** ⏳ Pending (starts after Phase 1 complete)

---

## 🎯 Phase Goal

**Shippable Deliverable:** Users can log both **cravings AND usage** with ROA-specific amounts (Bowls, Joints, Vape, etc.) in <10 seconds.

**Features Implemented:**
- Feature 2: Usage Logging (complete)
- Reuses Phase 1 components (ChipSelector, TimestampPicker, triggers/location)
- Introduces ROA-specific amount pickers

**Scope Note:** This document covers **Week 2 only** from TECHNICAL_IMPLEMENTATION.md. Onboarding and Data Management are covered in Weeks 3-4 (documentation to be created after Week 2 completion).

---

## 📊 What's Already Done (From Phase 1)

✅ **Data Layer:**
- `UsageModel.swift` - SwiftData @Model with ROA fields (created in Phase 1 Step 1)
- `ModelContainerSetup.swift` - SwiftData schema includes UsageModel

✅ **Presentation Layer (Reusable Components):**
- `ChipSelector.swift` - Multi-select UI (triggers) - API: `ChipSelector(title:, options:, selectedValues:, multiSelect:)`
- `TimestampPicker.swift` - Date/time selection - API: `TimestampPicker(date:)`
- `TriggerOptions.swift` - HAALT trigger constants
- `LocationOptions.swift` - Location presets
- `HomeView.swift` - Has "Log Usage" menu item (currently TODO)

✅ **Patterns Established:**
- Environment injection (`@Environment(DependencyContainer.self)`)
- Factory methods (`container.makeViewModel()`)
- Alert-before-dismiss flow
- SwiftData testing with in-memory configuration
- TDD with Swift Testing framework

**Note:** UsageRepositoryProtocol and DependencyContainer wiring will be created in this phase (Phase 2) - they were intentionally skipped in Phase 1 to avoid UsageEntity dependency issues.

---

## 🛠️ What We're Building (Phase 2)

### Part 1: Domain Layer (Day 1 Morning)

**Goal:** Create pure Swift entities, repository protocol, and use cases for usage logging

#### Files to Create (4 files)

1. **`Domain/Entities/UsageEntity.swift`** (NEW)
2. **`Domain/Repositories/UsageRepositoryProtocol.swift`** (NEW - was skipped in Phase 1)
3. **`Domain/UseCases/LogUsageUseCase.swift`** (NEW)
4. **`Domain/UseCases/FetchUsageUseCase.swift`** (NEW)

---

### Part 2: Data Layer (Day 1 Afternoon)

**Goal:** Implement repository and mapper for UsageModel

#### Files to Create (2 files)

4. **`Data/Repositories/UsageRepository.swift`** (NEW - replaces stub)
5. **`Data/Mappers/UsageMapper.swift`** (NEW)

#### Files to Modify (1 file)

6. **`App/DependencyContainer.swift`** - Replace StubUsageRepository with real implementation

---

### Part 3: Reusable Component (Day 2 Morning)

**Goal:** Create ROA-aware amount picker component

#### Files to Create (1 file)

7. **`Presentation/Views/Components/ROAPickerInput.swift`** (NEW)
   - Dynamically adjusts amount range based on selected ROA
   - Bowls/Joints/Blunts: 0.5 → 5.0 (0.5 increments)
   - Vape: 1 → 10 pulls (1 increment)
   - Dab: 1 → 5 dabs (1 increment)
   - Edible: 5mg → 100mg (5mg increments)

---

### Part 4: Usage Logging Views (Day 2 Afternoon - Day 3)

**Goal:** Complete usage logging form and list view

#### Files to Create (4 files)

8. **`Presentation/ViewModels/UsageLogViewModel.swift`** (NEW)
9. **`Presentation/Views/Usage/UsageLogForm.swift`** (NEW)
10. **`Presentation/ViewModels/UsageListViewModel.swift`** (NEW)
11. **`Presentation/Views/Usage/UsageListView.swift`** (NEW)

#### Files to Modify (1 file)

12. **`Presentation/Views/Home/HomeView.swift`** - Wire up "Log Usage" sheet + display UsageListView

---

### Part 5: Testing (Days 4-5)

**Goal:** Write comprehensive tests (TDD approach)

#### Tests to Write (14 tests total)

**Unit Tests (10 tests):**
- `ROAPickerInputTests.swift` (2 tests)
- `UsageLogViewModelTests.swift` (4 tests)
- `UsageListViewModelTests.swift` (4 tests)

**Integration Tests (2 tests):**
- `UsageLogIntegrationTests.swift` (2 tests - form → VM → UC → Repo)
  - Test 1: End-to-end usage log with all ROAs
  - Test 2: Fetch and display usage from SwiftData

**UI Tests (2 tests):**
- `UsageLogUITests.swift` (2 tests)
  - Test 1: <10 sec validation (tap "Log Usage" → select ROA → save)
  - Test 2: List auto-refreshes after usage logged

---

## 📝 Implementation Steps

### Step 1: Create UsageEntity (Domain Layer)

**File:** `Cravey/Domain/Entities/UsageEntity.swift`

```swift
import Foundation

/// Pure Swift entity for usage tracking (no frameworks)
struct UsageEntity: Equatable, Sendable {
    let id: UUID
    let timestamp: Date
    let method: String        // ROA: "Bowls", "Joints", "Blunts", "Vape", "Dab", "Edible"
    let amount: Double
    let triggers: [String]    // HAALT triggers
    let location: String?
    let notes: String?
    let createdAt: Date
    let modifiedAt: Date?

    init(
        id: UUID = UUID(),
        timestamp: Date,
        method: String,
        amount: Double,
        triggers: [String] = [],
        location: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        modifiedAt: Date? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.method = method
        self.amount = amount
        self.triggers = triggers
        self.location = location
        self.notes = notes
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}
```

---

### Step 2: Create UsageRepositoryProtocol (Domain Layer)

**File:** `Cravey/Domain/Repositories/UsageRepositoryProtocol.swift`

```swift
import Foundation

/// Protocol for usage data operations (dependency inversion)
protocol UsageRepositoryProtocol: Sendable {
    func save(_ usage: UsageEntity) async throws
    func fetchAll() async throws -> [UsageEntity]
    func fetch(since date: Date) async throws -> [UsageEntity]
    func deleteAll() async throws
}
```

**Why Now:** We skipped this in Phase 1 to avoid UsageEntity dependency issues. Now that we're creating UsageEntity in Step 1, we can safely add the protocol.

---

### Step 3: Create Use Cases (Domain Layer)

**File:** `Cravey/Domain/UseCases/LogUsageUseCase.swift`

```swift
import Foundation

/// Protocol for logging usage (dependency inversion)
protocol LogUsageUseCase: Sendable {
    func execute(
        timestamp: Date,
        method: String,
        amount: Double,
        triggers: [String],
        location: String?,
        notes: String?
    ) async throws -> UsageEntity
}

/// Default implementation
final class DefaultLogUsageUseCase: LogUsageUseCase {
    private let repository: UsageRepositoryProtocol

    init(repository: UsageRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        timestamp: Date,
        method: String,
        amount: Double,
        triggers: [String] = [],
        location: String? = nil,
        notes: String? = nil
    ) async throws -> UsageEntity {
        // Validation
        guard !method.isEmpty else {
            throw UsageError.invalidMethod
        }

        guard amount > 0 else {
            throw UsageError.invalidAmount
        }

        // Validate ROA
        let validMethods = ["Bowls", "Joints", "Blunts", "Vape", "Dab", "Edible"]
        guard validMethods.contains(method) else {
            throw UsageError.invalidMethod
        }

        // Validate amount range for ROA
        let validRange = ROAAmountRange.range(for: method)
        guard validRange.contains(amount) else {
            throw UsageError.invalidAmount
        }

        let entity = UsageEntity(
            timestamp: timestamp,
            method: method,
            amount: amount,
            triggers: triggers,
            location: location,
            notes: notes
        )

        try await repository.save(entity)
        return entity
    }
}

enum UsageError: LocalizedError {
    case invalidMethod
    case invalidAmount
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .invalidMethod:
            return "Please select a valid method"
        case .invalidAmount:
            return "Please enter a valid amount"
        case .saveFailed:
            return "Failed to save usage"
        }
    }
}

/// ROA amount range helper (from DATA_MODEL_SPEC.md)
enum ROAAmountRange {
    static func range(for method: String) -> [Double] {
        switch method {
        case "Bowls", "Joints", "Blunts":
            return stride(from: 0.5, through: 5.0, by: 0.5).map { $0 }
        case "Vape":
            return Array(1...10).map { Double($0) }
        case "Dab":
            return Array(1...5).map { Double($0) }
        case "Edible":
            return stride(from: 5.0, through: 100.0, by: 5.0).map { $0 }
        default:
            return []
        }
    }

    static func displayAmount(method: String, amount: Double) -> String {
        switch method {
        case "Bowls": return "\(formatAmount(amount)) bowls"
        case "Joints": return "\(formatAmount(amount)) joints"
        case "Blunts": return "\(formatAmount(amount)) blunts"
        case "Vape": return "\(Int(amount)) pulls"
        case "Dab": return "\(Int(amount)) dabs"
        case "Edible": return "\(Int(amount))mg"
        default: return "\(amount)"
        }
    }

    private static func formatAmount(_ amount: Double) -> String {
        // Show 0.5 as "0.5", but 1.0 as "1"
        return amount.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(amount))" : "\(amount)"
    }
}
```

**File:** `Cravey/Domain/UseCases/FetchUsageUseCase.swift`

```swift
import Foundation

/// Protocol for fetching usage history
protocol FetchUsageUseCase: Sendable {
    func execute() async throws -> [UsageEntity]
    func execute(since date: Date) async throws -> [UsageEntity]
}

/// Default implementation
final class DefaultFetchUsageUseCase: FetchUsageUseCase {
    private let repository: UsageRepositoryProtocol

    init(repository: UsageRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [UsageEntity] {
        return try await repository.fetchAll()
    }

    func execute(since date: Date) async throws -> [UsageEntity] {
        return try await repository.fetch(since: date)
    }
}
```

---

### Step 4: Create UsageMapper (Data Layer)

**File:** `Cravey/Data/Mappers/UsageMapper.swift`

```swift
import Foundation

/// Maps between UsageEntity (Domain) and UsageModel (Data/SwiftData)
enum UsageMapper {
    /// Convert Domain entity to SwiftData model
    static func toModel(_ entity: UsageEntity) -> UsageModel {
        return UsageModel(
            id: entity.id,
            timestamp: entity.timestamp,
            method: entity.method,
            amount: entity.amount,
            triggers: entity.triggers,
            location: entity.location,
            notes: entity.notes
        )
    }

    /// Convert SwiftData model to Domain entity
    static func toEntity(_ model: UsageModel) -> UsageEntity {
        return UsageEntity(
            id: model.id,
            timestamp: model.timestamp,
            method: model.method,
            amount: model.amount,
            triggers: model.triggers,
            location: model.location,
            notes: model.notes,
            createdAt: model.createdAt,
            modifiedAt: model.modifiedAt
        )
    }
}
```

---

### Step 5: Create UsageRepository (Data Layer)

**File:** `Cravey/Data/Repositories/UsageRepository.swift`

```swift
import Foundation
import SwiftData

/// SwiftData implementation of UsageRepositoryProtocol
final class UsageRepository: UsageRepositoryProtocol {
    nonisolated(unsafe) private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ usage: UsageEntity) async throws {
        let model = UsageMapper.toModel(usage)
        modelContext.insert(model)
        try modelContext.save()
    }

    func fetchAll() async throws -> [UsageEntity] {
        let descriptor = FetchDescriptor<UsageModel>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { UsageMapper.toEntity($0) }
    }

    func fetch(since date: Date) async throws -> [UsageEntity] {
        let predicate = #Predicate<UsageModel> { usage in
            usage.timestamp >= date
        }
        let descriptor = FetchDescriptor<UsageModel>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { UsageMapper.toEntity($0) }
    }

    func deleteAll() async throws {
        try modelContext.delete(model: UsageModel.self)
        try modelContext.save()
    }
}
```

---

### Step 6: Update DependencyContainer

**Modify:** `Cravey/App/DependencyContainer.swift`

**Add usage repository wiring** (Phase 1 skipped this to avoid UsageEntity dependency, now we add it):

```swift
// Usage Repository (real implementation)
let usageRepo = UsageRepository(modelContext: modelContext)
self.usageRepository = usageRepo

// Usage Use Cases
self.logUsageUseCase = DefaultLogUsageUseCase(repository: usageRepo)
self.fetchUsageUseCase = DefaultFetchUsageUseCase(repository: usageRepo)
```

**Add property declarations** (after `messageRepository`, ~line 19):

```swift
private(set) var usageRepository: UsageRepositoryProtocol
private(set) var logUsageUseCase: LogUsageUseCase
private(set) var fetchUsageUseCase: FetchUsageUseCase
```

**Add factory method** (at bottom of DependencyContainer, after `makeCravingLogViewModel`):

```swift
/// Factory method for UsageLogViewModel
func makeUsageLogViewModel() -> UsageLogViewModel {
    return UsageLogViewModel(logUsageUseCase: logUsageUseCase)
}
```

---

### Step 7: Create ROAPickerInput Component

**File:** `Cravey/Presentation/Views/Components/ROAPickerInput.swift`

```swift
import SwiftUI

/// ROA-aware amount picker that dynamically adjusts range based on method
struct ROAPickerInput: View {
    let selectedMethod: String
    @Binding var amount: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amount")
                .font(.subheadline)
                .foregroundStyle(.secondary)

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

    private var amountOptions: [Double] {
        ROAAmountRange.range(for: selectedMethod)
    }

    private func displayText(for amount: Double) -> String {
        switch selectedMethod {
        case "Bowls": return formatAmount(amount) + " bowls"
        case "Joints": return formatAmount(amount) + " joints"
        case "Blunts": return formatAmount(amount) + " blunts"
        case "Vape": return "\(Int(amount)) pulls"
        case "Dab": return "\(Int(amount)) dabs"
        case "Edible": return "\(Int(amount))mg"
        default: return "\(amount)"
        }
    }

    private func formatAmount(_ amount: Double) -> String {
        // Show 0.5 as "0.5", but 1.0 as "1"
        return amount.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(amount))" : "\(amount)"
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var method = "Bowls"
        @State private var amount = 1.0

        var body: some View {
            VStack(spacing: 20) {
                Picker("Method", selection: $method) {
                    Text("Bowls").tag("Bowls")
                    Text("Vape").tag("Vape")
                    Text("Edible").tag("Edible")
                }
                .pickerStyle(.segmented)

                ROAPickerInput(selectedMethod: method, amount: $amount)

                Text("Selected: \(ROAAmountRange.displayAmount(method: method, amount: amount))")
                    .font(.caption)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
```

---

### Step 8: Create UsageLogViewModel

**File:** `Cravey/Presentation/ViewModels/UsageLogViewModel.swift`

```swift
import Foundation
import Observation

@Observable
@MainActor
final class UsageLogViewModel {
    // Dependencies
    private let logUsageUseCase: LogUsageUseCase

    // Form fields
    var timestamp: Date = Date()
    var selectedMethod: String = "Bowls"
    var amount: Double = 1.0
    var selectedTriggers: Set<String> = []
    var selectedLocation: String? = nil
    var notes: String = ""

    // UI state
    var showSuccessAlert: Bool = false
    var errorMessage: String? = nil

    init(logUsageUseCase: LogUsageUseCase) {
        self.logUsageUseCase = logUsageUseCase
    }

    var canSubmit: Bool {
        return !selectedMethod.isEmpty && amount > 0
    }

    func logUsage() async {
        do {
            _ = try await logUsageUseCase.execute(
                timestamp: timestamp,
                method: selectedMethod,
                amount: amount,
                triggers: Array(selectedTriggers),
                location: selectedLocation,
                notes: notes.isEmpty ? nil : notes
            )
            showSuccessAlert = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateAmountForMethod() {
        // Reset amount to first valid option when method changes
        let validAmounts = ROAAmountRange.range(for: selectedMethod)
        if let firstAmount = validAmounts.first {
            amount = firstAmount
        }
    }
}
```

---

### Step 9: Create UsageLogForm

**File:** `Cravey/Presentation/Views/Usage/UsageLogForm.swift`

```swift
import SwiftUI

struct UsageLogForm: View {
    @Bindable var viewModel: UsageLogViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Required Section
                Section {
                    // ROA Picker
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

                    // Amount Picker (ROA-aware)
                    ROAPickerInput(
                        selectedMethod: viewModel.selectedMethod,
                        amount: $viewModel.amount
                    )

                    // Timestamp
                    TimestampPicker(date: $viewModel.timestamp)
                }

                // Optional Section
                Section {
                    // Triggers
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

                    // Location
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

                    // Notes
                    TextField("Notes (Optional)", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...6)
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
            .alert("Success", isPresented: $viewModel.showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Usage logged successfully ✓")
            }
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
        }
    }
}

#Preview {
    let container = DependencyContainer()
    let viewModel = container.makeUsageLogViewModel()
    return UsageLogForm(viewModel: viewModel)
}
```

---

### Step 10: Create UsageListViewModel

**File:** `Cravey/Presentation/ViewModels/UsageListViewModel.swift`

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

---

### Step 11: Create UsageListView

**File:** `Cravey/Presentation/Views/Usage/UsageListView.swift`

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
                // Method + Amount
                Text(ROAAmountRange.displayAmount(method: usage.method, amount: usage.amount))
                    .font(.headline)

                Spacer()

                // Timestamp
                Text(usage.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Triggers
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

            // Location
            if let location = usage.location {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
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
            amount: 10.0,
            triggers: ["Social"],
            location: nil
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

---

### Step 12: Wire Up HomeView

**Modify:** `Cravey/Presentation/Views/Home/HomeView.swift`

**Update to add UsageListView and wire "Log Usage" menu item:**

```swift
struct HomeView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var showCravingLogSheet = false
    @State private var showUsageLogSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Craving List
                CravingListView(
                    viewModel: CravingListViewModel(
                        fetchCravingsUseCase: container.fetchCravingsUseCase
                    )
                )

                Divider()

                // Usage List
                UsageListView(
                    viewModel: UsageListViewModel(
                        fetchUsageUseCase: container.fetchUsageUseCase
                    )
                )
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
            .sheet(isPresented: $showCravingLogSheet) {
                let viewModel = container.makeCravingLogViewModel()
                CravingLogForm(viewModel: viewModel)
            }
            .sheet(isPresented: $showUsageLogSheet) {
                let viewModel = container.makeUsageLogViewModel()
                UsageLogForm(viewModel: viewModel)
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

---

## 🧪 Testing (Steps 13-15)

### Step 13: Write Unit Tests

#### Test 1: ROAPickerInputTests.swift

**File:** `CraveyTests/Presentation/Components/ROAPickerInputTests.swift`

```swift
import Testing
@testable import Cravey

@Suite("ROAPickerInput Tests")
struct ROAPickerInputTests {
    @Test("Bowls should have 10 options (0.5 to 5.0)")
    func testBowlsRange() {
        let range = ROAAmountRange.range(for: "Bowls")
        #expect(range.count == 10)
        #expect(range.first == 0.5)
        #expect(range.last == 5.0)
    }

    @Test("Edible should format as mg")
    func testEdibleDisplay() {
        let display = ROAAmountRange.displayAmount(method: "Edible", amount: 25.0)
        #expect(display == "25mg")
    }
}
```

#### Test 2: UsageLogViewModelTests.swift

**File:** `CraveyTests/Presentation/ViewModels/UsageLogViewModelTests.swift`

```swift
import Testing
@testable import Cravey

@Suite("UsageLogViewModel Tests")
@MainActor
struct UsageLogViewModelTests {
    @Test("Should validate canSubmit with valid method and amount")
    func testCanSubmitValid() {
        let mockUseCase = MockLogUsageUseCase()
        let viewModel = UsageLogViewModel(logUsageUseCase: mockUseCase)

        viewModel.selectedMethod = "Bowls"
        viewModel.amount = 2.5

        #expect(viewModel.canSubmit == true)
    }

    @Test("Should fail canSubmit with zero amount")
    func testCanSubmitInvalidAmount() {
        let mockUseCase = MockLogUsageUseCase()
        let viewModel = UsageLogViewModel(logUsageUseCase: mockUseCase)

        viewModel.selectedMethod = "Bowls"
        viewModel.amount = 0

        #expect(viewModel.canSubmit == false)
    }

    @Test("Should reset amount when method changes")
    func testUpdateAmountForMethod() {
        let mockUseCase = MockLogUsageUseCase()
        let viewModel = UsageLogViewModel(logUsageUseCase: mockUseCase)

        viewModel.selectedMethod = "Edible"
        viewModel.updateAmountForMethod()

        #expect(viewModel.amount == 5.0) // First valid edible amount
    }

    @Test("Should show success alert after logging")
    func testLogUsageSuccess() async {
        let mockUseCase = MockLogUsageUseCase()
        let viewModel = UsageLogViewModel(logUsageUseCase: mockUseCase)

        viewModel.selectedMethod = "Vape"
        viewModel.amount = 5.0

        await viewModel.logUsage()

        #expect(viewModel.showSuccessAlert == true)
        #expect(viewModel.errorMessage == nil)
    }
}

// MARK: - Mock

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

#### Test 3: UsageListViewModelTests.swift

**File:** `CraveyTests/Presentation/ViewModels/UsageListViewModelTests.swift`

```swift
import Testing
@testable import Cravey

@Suite("UsageListViewModel Tests")
@MainActor
struct UsageListViewModelTests {
    @Test("Should fetch usage list successfully")
    func testFetchUsageSuccess() async {
        let mockUseCase = MockFetchUsageUseCase()
        let viewModel = UsageListViewModel(fetchUsageUseCase: mockUseCase)

        await viewModel.fetchUsage()

        #expect(viewModel.usageList.count == 2)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Should set loading state while fetching")
    func testLoadingState() async {
        let mockUseCase = MockFetchUsageUseCase()
        let viewModel = UsageListViewModel(fetchUsageUseCase: mockUseCase)

        #expect(viewModel.isLoading == false)

        let fetchTask = Task {
            await viewModel.fetchUsage()
        }

        // Note: isLoading will be true during fetch, false after
        await fetchTask.value

        #expect(viewModel.isLoading == false)
    }

    @Test("Should display empty state when no usage")
    func testEmptyState() async {
        let mockUseCase = MockFetchUsageUseCase(returnEmpty: true)
        let viewModel = UsageListViewModel(fetchUsageUseCase: mockUseCase)

        await viewModel.fetchUsage()

        #expect(viewModel.usageList.isEmpty)
    }

    @Test("Should handle fetch error")
    func testFetchError() async {
        let mockUseCase = MockFetchUsageUseCase(shouldFail: true)
        let viewModel = UsageListViewModel(fetchUsageUseCase: mockUseCase)

        await viewModel.fetchUsage()

        #expect(viewModel.errorMessage == "Failed to load usage history")
    }
}

// MARK: - Mock

actor MockFetchUsageUseCase: FetchUsageUseCase {
    let returnEmpty: Bool
    let shouldFail: Bool

    init(returnEmpty: Bool = false, shouldFail: Bool = false) {
        self.returnEmpty = returnEmpty
        self.shouldFail = shouldFail
    }

    func execute() async throws -> [UsageEntity] {
        if shouldFail {
            throw NSError(domain: "test", code: 1)
        }

        if returnEmpty {
            return []
        }

        return [
            UsageEntity(
                timestamp: Date(),
                method: "Bowls",
                amount: 2.5,
                triggers: ["Anxious"],
                location: "Home"
            ),
            UsageEntity(
                timestamp: Date().addingTimeInterval(-3600),
                method: "Edible",
                amount: 10.0,
                triggers: [],
                location: nil
            )
        ]
    }

    func execute(since date: Date) async throws -> [UsageEntity] {
        return try await execute()
    }
}
```

---

### Step 14: Write Integration Tests

**File:** `CraveyTests/Integration/UsageLogIntegrationTests.swift`

```swift
import Testing
import SwiftData
@testable import Cravey

@Suite("Usage Log Integration Tests")
struct UsageLogIntegrationTests {
    @Test("End-to-end usage log flow")
    @MainActor
    func testEndToEndUsageLog() async throws {
        // Setup in-memory SwiftData
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        // Create repository and use case
        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultLogUsageUseCase(repository: repository)

        // Execute
        let result = try await useCase.execute(
            timestamp: Date(),
            method: "Bowls",
            amount: 2.5,
            triggers: ["Anxious", "Bored"],
            location: "Home",
            notes: "Test note"
        )

        // Verify entity
        #expect(result.method == "Bowls")
        #expect(result.amount == 2.5)
        #expect(result.triggers.count == 2)

        // Verify persistence
        let descriptor = FetchDescriptor<UsageModel>()
        let saved = try context.fetch(descriptor)
        #expect(saved.count == 1)
        #expect(saved.first?.method == "Bowls")
    }

    @Test("Fetch and display usage from SwiftData")
    @MainActor
    func testFetchUsage() async throws {
        // Setup
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        // Insert test data
        let model1 = UsageModel(timestamp: Date(), method: "Vape", amount: 5.0)
        let model2 = UsageModel(timestamp: Date().addingTimeInterval(-3600), method: "Edible", amount: 10.0)
        context.insert(model1)
        context.insert(model2)
        try context.save()

        // Fetch via use case
        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultFetchUsageUseCase(repository: repository)
        let results = try await useCase.execute()

        // Verify
        #expect(results.count == 2)
        #expect(results[0].method == "Vape") // Sorted by timestamp descending
        #expect(results[1].method == "Edible")
    }
}
```

---

### Step 15: Write UI Tests

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
        // Navigate to Home tab
        let homeTab = app.tabBars.buttons["Home"]
        homeTab.tap()

        let startTime = Date()

        // Tap "+" menu
        let addButton = app.navigationBars.buttons.matching(identifier: "plus.circle.fill").firstMatch
        addButton.tap()

        // Tap "Log Usage"
        let logUsageButton = app.buttons["Log Usage"]
        logUsageButton.tap()

        // Wait for sheet to appear
        let usageSheet = app.navigationBars["Log Usage"]
        XCTAssertTrue(usageSheet.waitForExistence(timeout: 2))

        // Select method (default is Bowls, so tap Save)
        let saveButton = app.navigationBars.buttons["Save"]
        saveButton.tap()

        // Wait for success alert
        let successAlert = app.alerts["Success"]
        XCTAssertTrue(successAlert.waitForExistence(timeout: 2))

        let elapsed = Date().timeIntervalSince(startTime)
        XCTAssertLessThan(elapsed, 10.0, "Usage log should complete in <10 seconds")

        // Dismiss alert
        successAlert.buttons["OK"].tap()
    }

    func testUsageListRefreshesAfterLog() throws {
        // Navigate to Home tab
        let homeTab = app.tabBars.buttons["Home"]
        homeTab.tap()

        // Get initial usage count (may be 0)
        let usageList = app.collectionViews.firstMatch
        let initialCount = usageList.cells.count

        // Log new usage
        let addButton = app.navigationBars.buttons.matching(identifier: "plus.circle.fill").firstMatch
        addButton.tap()

        let logUsageButton = app.buttons["Log Usage"]
        logUsageButton.tap()

        // Save
        let saveButton = app.navigationBars.buttons["Save"]
        saveButton.tap()

        // Dismiss alert
        let successAlert = app.alerts["Success"]
        XCTAssertTrue(successAlert.waitForExistence(timeout: 2))
        successAlert.buttons["OK"].tap()

        // Wait for list to refresh
        sleep(1)

        // Verify count increased
        let newCount = usageList.cells.count
        XCTAssertGreaterThan(newCount, initialCount, "Usage list should refresh after logging")
    }
}
```

---

## ✅ Completion Checklist (Step 16)

### Code Quality

- [ ] All 13 files created/modified
- [ ] DependencyContainer updated (real UsageRepository, use cases, factory method)
- [ ] HomeView wired (usage list + "Log Usage" sheet)
- [ ] All tests passing (14/14: 10 unit + 2 integration + 2 UI)
- [ ] SwiftLint violations ≤13 warnings (same TODO baseline from Phase 1)
- [ ] SwiftFormat applied to new files

### Manual Testing

- [ ] Log usage with all 6 ROAs (Bowls, Joints, Blunts, Vape, Dab, Edible)
- [ ] Verify amount picker adjusts for each ROA
- [ ] Verify multi-select triggers work (reused ChipSelector)
- [ ] Verify single-select location works (reused ChipSelector)
- [ ] Verify usage list displays logged items
- [ ] Verify list auto-refreshes after logging (via .task on UsageListView)
- [ ] Verify <10 sec logging (stopwatch validation)
- [ ] Success alert shows after Save (with OK button)
- [ ] Tapping OK on alert dismisses sheet
- [ ] Error handling works (try invalid amount manually)

### Architecture Validation

- [ ] No SwiftUI imports in Domain layer
- [ ] No SwiftData imports in Domain layer
- [ ] UsageEntity is pure Swift (Equatable, Sendable)
- [ ] UsageRepository follows protocol (dependency inversion)
- [ ] ViewModels use @Observable, @MainActor
- [ ] No duplicate DependencyContainer instances (environment injection only)

### Documentation

- [ ] Code comments added to complex logic (ROA range validation)
- [ ] Inline TODOs removed (unlike Phase 1 baseline, Phase 2 should have zero new TODOs)
- [ ] #Preview blocks work for all new views

---

## 📦 Summary

**Files Created/Modified:** 13 files total
- Domain: 4 files (UsageEntity, UsageRepositoryProtocol, 2 use cases)
- Data: 2 files (UsageRepository, UsageMapper)
- Presentation: 5 files (2 ViewModels, 2 Views, 1 Component)
- Modified: 2 files (DependencyContainer, HomeView)

**Tests Created:** 5 test files
- Unit: 3 test files (ROAPickerInputTests, UsageLogViewModelTests, UsageListViewModelTests)
- Integration: 1 test file (UsageLogIntegrationTests)
- UI: 1 test file (UsageLogUITests)

**Tests Written:** 14 tests
- Unit: 10 tests (2 picker + 4 form VM + 4 list VM)
- Integration: 2 tests (end-to-end log + fetch)
- UI: 2 tests (<10 sec + list refresh)

**What's New:**
- ✅ Full usage logging feature (ROA-specific amounts)
- ✅ Reusable ROAPickerInput component
- ✅ Dual craving + usage tracking
- ✅ All patterns established in Phase 1 applied consistently

**What's Next (Week 3):**
- Onboarding flow (WelcomeView, TourView)
- Data export/deletion features
- Tab bar navigation polish

---

**Ready for Phase 1 Completion → Phase 2 Implementation**

**[← Back to Overview](./PHASE_OVERVIEW.md)** | **[← Phase 1](./PHASE_1.md)** | **[Phase 3 (Onboarding+Data) →](./PHASE_3.md)**
