# Phase 1: Foundation + Craving Logging (Week 1 Only)

**Version:** 2.0 (Aligned with 16-week master timeline)
**Last Updated:** 2025-10-31
**Duration:** 1 week (Week 1 of 16-week plan)
**Dependencies:** None (baseline code exists)
**Status:** 🎯 **START HERE**

---

## 🎯 Phase Goal

**Shippable Deliverable:** Users can launch the app, log cravings in <5 seconds, and view craving history.

**Features Implemented:**
- Feature 1: Craving Logging (complete)
- Foundation: UsageModel schema (data model only, UI in Week 2)
- Tab Bar shell (Home, Dashboard, Settings empty states)

**Scope Note:** This document covers **Week 1 only** from TECHNICAL_IMPLEMENTATION.md. Usage Logging (Week 2), Onboarding + Data Management (Weeks 3-4), Recordings (Weeks 5-6), and Dashboard (Weeks 7-8) are documented in PHASE_2 through PHASE_5. See [PHASE_OVERVIEW.md](./PHASE_OVERVIEW.md) for complete timeline.

---

## 📊 What's Already Done (Baseline)

✅ **Domain Layer:**
- `CravingEntity.swift` - Multi-trigger support (`triggers: [String]`)
- `LogCravingUseCase.swift` - Validates intensity, saves craving
- `FetchCravingsUseCase.swift` - Fetches all cravings
- `CravingRepositoryProtocol.swift` - Protocol definition

✅ **Data Layer:**
- `CravingModel.swift` - SwiftData @Model with `triggers: [String]`
- `CravingMapper.swift` - Entity ↔ Model conversion
- `CravingRepository.swift` - SwiftData implementation
- `FileStorageManager.swift` - File I/O (recordings)
- `ModelContainerSetup.swift` - SwiftData container config

✅ **Presentation Layer:**
- `CravingLogViewModel.swift` - Stateful ViewModel with `selectedTriggers: Set<String>`

✅ **Tests:**
- `LogCravingUseCaseTests.swift` - 2/2 passing
- `CravingLogViewModelTests.swift` - 2/2 passing

✅ **Build Status:**
- All tests passing (4/4)
- No compile errors
- 13 SwiftLint TODO warnings (expected, will resolve during Phase 1 implementation)

---

## 🛠️ What We're Building (Phase 1)

### Part 1: Foundation (Day 1 Morning)

**Goal:** Complete data model schema, set up empty UI shell

#### Files to Create/Modify (2 files)

1. **Create `Data/Models/UsageModel.swift`** (NEW - data model only, repository in Phase 2)
2. **Modify `Data/Storage/ModelContainerSetup.swift`** (add UsageModel to schema)

#### Files to Create (Tab Bar Shell) (3 files)

3. **Create `Presentation/Views/Home/HomeView.swift`** (empty state)
4. **Create `Presentation/Views/Dashboard/DashboardView.swift`** (empty state)
5. **Create `Presentation/Views/Settings/SettingsView.swift`** (empty state)
6. **Modify `App/CraveyApp.swift`** (wire TabView)

---

### Part 2: Craving Logging Components (Days 1-2)

**Goal:** Build reusable UI components (TDD approach)

#### Files to Create (5 components)

8. **`Presentation/Views/Components/IntensitySlider.swift`**
   - Displays 1-10 scale with emoji feedback
   - Binds to `Double` (converts to `Int` for use case)
   - Visual feedback (color gradient)

9. **`Presentation/Views/Components/TimestampPicker.swift`**
   - Date + Time picker
   - Defaults to "Now" (current timestamp)
   - Allows backdating (up to 7 days)

10. **`Presentation/Views/Components/ChipSelector.swift`**
    - Multi-select chip UI (like iOS Health app)
    - Supports single-select mode (location)
    - Binds to `Set<String>`

11. **`Presentation/Views/Components/TriggerOptions.swift`** (NEW - constants)
    - Static list of trigger options
    - Used by ChipSelector

12. **`Presentation/Views/Components/LocationOptions.swift`** (NEW - constants)
    - Static list of location presets
    - Used by ChipSelector

---

### Part 3: Craving Logging View (Days 3-4)

**Goal:** Complete craving logging feature (form + list)

#### Files to Create (2 views)

13. **`Presentation/Views/Craving/CravingLogForm.swift`**
    - Sheet presentation
    - Required section (intensity only)
    - Optional section (triggers, location, notes, managed successfully)
    - Cancel/Save toolbar
    - Success/Error alerts

14. **`Presentation/Views/Craving/CravingListView.swift`** (NEW)
    - Displays all cravings (fetched via `FetchCravingsUseCase`)
    - List with intensity badge, timestamp, triggers
    - Swipe-to-delete (future - stub for now)

---

### Part 4: Integration + Testing (Day 5)

**Goal:** Wire everything together, validate <5 sec log time

#### Tests to Write (9 tests total)

**Unit Tests (6 tests):**
- `LogCravingUseCaseTests.swift` (2 tests - already exists in baseline)
- `CravingLogViewModelTests.swift` (2 tests - already exists in baseline)
- `IntensitySliderTests.swift` (2 tests - new in Phase 1)

**Integration Tests (2 tests):**
- `CravingLogIntegrationTests.swift` (2 tests - form → VM → UC → Repo)
  - Test 1: End-to-end craving log with all fields
  - Test 2: Fetch and display cravings from SwiftData

**UI Tests (1 test):**
- `CravingLogUITests.swift` (1 test - <5 sec validation)

**Note:** Component tests for ChipSelector and other reusable components will be added in later phases as those components evolve. List refresh behavior is validated via manual testing checklist (Step 14).

---

## 📦 Complete File Checklist (17 files total)

### Foundation (2 files)
- [ ] `Data/Models/UsageModel.swift` (CREATE - data model only, repository in Phase 2)
- [ ] `Data/Storage/ModelContainerSetup.swift` (MODIFY - add UsageModel to schema)

### App Setup (1 file)
- [ ] `App/CraveyApp.swift` (MODIFY - add TabView with environment injection)

### Tab Bar Shell (3 files)
- [ ] `Presentation/Views/Home/HomeView.swift` (CREATE)
- [ ] `Presentation/Views/Dashboard/DashboardView.swift` (CREATE)
- [ ] `Presentation/Views/Settings/SettingsView.swift` (CREATE)

### Components (5 files)
- [ ] `Presentation/Views/Components/IntensitySlider.swift` (CREATE)
- [ ] `Presentation/Views/Components/TimestampPicker.swift` (CREATE)
- [ ] `Presentation/Views/Components/ChipSelector.swift` (CREATE)
- [ ] `Presentation/Views/Components/TriggerOptions.swift` (CREATE)
- [ ] `Presentation/Views/Components/LocationOptions.swift` (CREATE)

### Craving Views (3 files)
- [ ] `Presentation/Views/Craving/CravingLogForm.swift` (CREATE)
- [ ] `Presentation/Views/Craving/CravingListView.swift` (CREATE)
- [ ] `Presentation/ViewModels/CravingListViewModel.swift` (CREATE)

### Tests (2 files - new in Phase 1, baseline already has 4 test files)
- [ ] `CraveyTests/Presentation/Components/IntensitySliderTests.swift` (CREATE - 2 tests)
- [ ] `CraveyTests/Integration/CravingLogIntegrationTests.swift` (CREATE - 2 tests)
- [ ] `CraveyUITests/CravingLogUITests.swift` (CREATE - 1 test)

---

## 🏗️ Architecture Diagram (Phase 1)

```
┌─────────────────────────────────────────────────┐
│  USER INTERACTION                               │
│  ┌─────────────┐  ┌─────────────┐              │
│  │ TabView     │  │ CravingLog  │              │
│  │  - Home     │  │    Form     │              │
│  │  - Dashboard│  │  (Sheet)    │              │
│  │  - Settings │  └──────┬──────┘              │
│  └─────────────┘         │                      │
└──────────────────────────┼──────────────────────┘
                           │
┌──────────────────────────▼──────────────────────┐
│  PRESENTATION LAYER (SwiftUI)                   │
│  ┌────────────────────────────────────┐         │
│  │ CravingLogViewModel (@Observable)   │         │
│  │  - intensity: Double                │         │
│  │  - selectedTriggers: Set<String>    │         │
│  │  - notes: String                    │         │
│  │  - location: String                 │         │
│  │  - wasManagedSuccessfully: Bool     │         │
│  │  - logCraving() async               │         │
│  └────────────┬───────────────────────┘         │
└───────────────┼─────────────────────────────────┘
                │ depends on
┌───────────────▼─────────────────────────────────┐
│  DOMAIN LAYER (Pure Swift - NO frameworks)     │
│  ┌────────────────────────────────────┐         │
│  │ LogCravingUseCase (Protocol)        │         │
│  │  - execute(intensity, triggers...)  │         │
│  │    → CravingEntity                  │         │
│  └────────────┬───────────────────────┘         │
│               │ uses                             │
│  ┌────────────▼───────────────────────┐         │
│  │ CravingRepositoryProtocol           │         │
│  │  - save(CravingEntity) async throws │         │
│  │  - fetchAll() → [CravingEntity]     │         │
│  └─────────────────────────────────────┘         │
└──────────────────────┬──────────────────────────┘
                       │ ↑ implements
┌──────────────────────▼──────────────────────────┐
│  DATA LAYER (SwiftData + File I/O)             │
│  ┌────────────────────────────────────┐         │
│  │ CravingRepository (Concrete)        │         │
│  │  - modelContext: ModelContext       │         │
│  │  - save() → SwiftData insert        │         │
│  └────────────┬───────────────────────┘         │
│               │ uses                             │
│  ┌────────────▼───────────────────────┐         │
│  │ CravingMapper (Utility)             │         │
│  │  - toModel(Entity) → Model          │         │
│  │  - toEntity(Model) → Entity         │         │
│  └────────────┬───────────────────────┘         │
│               │                                  │
│  ┌────────────▼───────────────────────┐         │
│  │ CravingModel (@Model)               │         │
│  │  - id: UUID                         │         │
│  │  - timestamp: Date                  │         │
│  │  - intensity: Int                   │         │
│  │  - triggers: [String]               │         │
│  │  - notes: String?                   │         │
│  │  - location: String?                │         │
│  └─────────────────────────────────────┘         │
└─────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow (Logging a Craving)

```
1. User taps "Log Craving" button in HomeView
   ↓
2. CravingLogForm sheet opens
   ↓
3. User adjusts intensity slider (binding updates viewModel.intensity)
   ↓
4. User selects triggers (binding updates viewModel.selectedTriggers)
   ↓
5. User taps "Save" button
   ↓
6. CravingLogForm calls: await viewModel.logCraving()
   ↓
7. ViewModel validates state, calls use case:
   try await logCravingUseCase.execute(
       intensity: Int(intensity),
       triggers: Array(selectedTriggers),
       notes: notes.isEmpty ? nil : notes,
       location: location.isEmpty ? nil : location,
       wasManagedSuccessfully: wasManagedSuccessfully
   )
   ↓
8. Use case validates intensity (1-10), creates CravingEntity
   ↓
9. Use case calls repository.save(craving)
   ↓
10. Repository converts Entity → Model via Mapper
    ↓
11. Repository inserts Model into SwiftData ModelContext
    ↓
12. Repository saves ModelContext (persists to disk)
    ↓
13. Use case returns CravingEntity to ViewModel
    ↓
14. ViewModel sets showSuccessAlert = true, resets form
    ↓
15. CravingLogForm shows success alert
    ↓
16. User taps "OK", sheet dismisses
    ↓
17. HomeView re-fetches cravings (via FetchCravingsUseCase)
    ↓
18. CravingListView updates with new craving
```

---

## 📝 Step-by-Step Implementation (TDD Workflow)

### Day 1 Morning: Foundation Setup

#### Step 1: Create UsageModel.swift

**Test First (RED):** Skip for data models (SwiftData doesn't need unit tests)

**Implementation:**

```swift
// Cravey/Data/Models/UsageModel.swift

import Foundation
import SwiftData

@Model
final class UsageModel {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var method: String  // ROA: "Bowls", "Vape", etc.
    var amount: Double
    var triggers: [String]
    var location: String?
    var notes: String?
    var createdAt: Date
    var modifiedAt: Date?

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

**Commit:** `[Phase 1] Add UsageModel schema`

---

#### Step 2: Update ModelContainerSetup.swift

**Modify:** `Cravey/Data/Storage/ModelContainerSetup.swift`

**Change:** Add `UsageModel.self` to schema

```swift
// Line 15 (schema definition)
let schema = Schema([
    CravingModel.self,
    UsageModel.self,  // ← ADD THIS
    RecordingModel.self,
    MotivationalMessageModel.self
])
```

**Verify:** Build succeeds

```bash
xcodebuild -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build | xcbeautify
```

**Commit:** `[Phase 1] Add UsageModel to SwiftData schema`

---

### Day 1 Afternoon: Tab Bar Shell

#### Step 3: Create Empty Tab Bar

**Goal:** App launches with 3 tabs (Home, Dashboard, Settings)

**Create:** `Cravey/Presentation/Views/Home/HomeView.swift`

```swift
// Cravey/Presentation/Views/Home/HomeView.swift

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("🌿 Cravey")
                    .font(.largeTitle.bold())

                Text("Track your journey to clarity")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                // TODO: Quick Play section (Phase 4 - Recordings)
                // TODO: Craving list (Phase 1, Day 3)
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Log Craving") {
                            // TODO: Open CravingLogForm sheet
                        }
                        Button("Log Usage") {
                            // TODO: Open UsageLogForm sheet (Phase 2)
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
```

**Create:** `Cravey/Presentation/Views/Dashboard/DashboardView.swift`

```swift
// Cravey/Presentation/Views/Dashboard/DashboardView.swift

import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Dashboard")
                    .font(.largeTitle)

                Text("Coming in Phase 5")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Progress")
        }
    }
}

#Preview {
    DashboardView()
}
```

**Create:** `Cravey/Presentation/Views/Settings/SettingsView.swift`

```swift
// Cravey/Presentation/Views/Settings/SettingsView.swift

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0 (Phase 1)")
                            .foregroundColor(.secondary)
                    }
                }

                Section("Data") {
                    Text("Export Data (Phase 5)")
                        .foregroundColor(.secondary)
                    Text("Delete All Data (Phase 5)")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
```

**Modify:** `Cravey/App/CraveyApp.swift`

```swift
// Cravey/App/CraveyApp.swift

import SwiftUI
import SwiftData

@main
struct CraveyApp: App {
    @State private var dependencyContainer = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                DashboardView()
                    .tabItem {
                        Label("Progress", systemImage: "chart.bar.fill")
                    }

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
            .environment(dependencyContainer)
        }
        .modelContainer(dependencyContainer.modelContainer)
    }
}
```

**Test Manually:**
1. Build and run app
2. Verify 3 tabs appear
3. Tap each tab, verify navigation works
4. Verify + menu in Home tab shows "Log Craving" / "Log Usage" (disabled for now)

**Commit:** `[Phase 1] Add empty tab bar shell (Home, Dashboard, Settings)`

---

### Day 2: Components (TDD Approach)

#### Step 4: Create IntensitySlider.swift

**Test First (RED):** Component tests are optional for SwiftUI views, but we'll write one for logic

**Create Test:** `CraveyTests/Presentation/Components/IntensitySliderTests.swift`

```swift
// CraveyTests/Presentation/Components/IntensitySliderTests.swift

import Testing
import SwiftUI
@testable import Cravey

@Suite("IntensitySlider Tests")
struct IntensitySliderTests {

    @Test("Should format intensity label correctly")
    func testIntensityLabel() {
        #expect(IntensitySlider.formatLabel(for: 1) == "1 - Very Mild")
        #expect(IntensitySlider.formatLabel(for: 5) == "5 - Moderate")
        #expect(IntensitySlider.formatLabel(for: 10) == "10 - Overwhelming")
    }

    @Test("Should return correct emoji for intensity")
    func testIntensityEmoji() {
        #expect(IntensitySlider.emoji(for: 1) == "😌")
        #expect(IntensitySlider.emoji(for: 5) == "😐")
        #expect(IntensitySlider.emoji(for: 10) == "😫")
    }
}
```

**Implement (GREEN):**

```swift
// Cravey/Presentation/Views/Components/IntensitySlider.swift

import SwiftUI

struct IntensitySlider: View {
    @Binding var value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Intensity")
                    .font(.headline)
                Spacer()
                Text(Self.emoji(for: Int(value)))
                    .font(.title)
            }

            HStack {
                Text("1")
                    .foregroundColor(.secondary)
                Slider(value: $value, in: 1...10, step: 1)
                Text("10")
                    .foregroundColor(.secondary)
            }

            Text(Self.formatLabel(for: Int(value)))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    // Testable static methods
    static func formatLabel(for intensity: Int) -> String {
        switch intensity {
        case 1...2: return "\(intensity) - Very Mild"
        case 3...4: return "\(intensity) - Mild"
        case 5...6: return "\(intensity) - Moderate"
        case 7...8: return "\(intensity) - Strong"
        case 9...10: return "\(intensity) - Overwhelming"
        default: return "\(intensity)"
        }
    }

    static func emoji(for intensity: Int) -> String {
        switch intensity {
        case 1...2: return "😌"
        case 3...4: return "🙂"
        case 5...6: return "😐"
        case 7...8: return "😟"
        case 9...10: return "😫"
        default: return "😐"
        }
    }
}

#Preview {
    IntensitySlider(value: .constant(5))
        .padding()
}
```

**Run Tests:**

```bash
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests/IntensitySliderTests | xcbeautify
```

**Verify:** ✅ 2/2 tests passing

**Commit:** `[Phase 1] Add IntensitySlider component with tests`

---

#### Step 5: Create TimestampPicker.swift

**Implementation (no test needed - simple wrapper):**

```swift
// Cravey/Presentation/Views/Components/TimestampPicker.swift

import SwiftUI

struct TimestampPicker: View {
    @Binding var date: Date

    var body: some View {
        DatePicker(
            "When did this happen?",
            selection: $date,
            in: ...Date(),  // Can't pick future dates
            displayedComponents: [.date, .hourAndMinute]
        )
        .datePickerStyle(.compact)
    }
}

#Preview {
    TimestampPicker(date: .constant(Date()))
        .padding()
}
```

**Commit:** `[Phase 1] Add TimestampPicker component`

---

#### Step 6: Create ChipSelector.swift

**Implementation:**

```swift
// Cravey/Presentation/Views/Components/ChipSelector.swift

import SwiftUI

struct ChipSelector: View {
    let title: String
    let options: [String]
    @Binding var selectedValues: Set<String>
    let multiSelect: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    ChipButton(
                        title: option,
                        isSelected: selectedValues.contains(option),
                        action: {
                            toggleSelection(option)
                        }
                    )
                }
            }
        }
    }

    private func toggleSelection(_ option: String) {
        if multiSelect {
            if selectedValues.contains(option) {
                selectedValues.remove(option)
            } else {
                selectedValues.insert(option)
            }
        } else {
            // Single-select: replace selection
            if selectedValues.contains(option) {
                selectedValues.remove(option)
            } else {
                selectedValues = [option]
            }
        }
    }
}

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
    }
}

// Flow Layout (wraps chips to next line)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.reduce(0) { $0 + $1.height + spacing }
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[Int]] {
        var rows: [[Int]] = [[]]
        var currentRowWidth: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity

        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            if currentRowWidth + size.width > maxWidth && !rows[rows.count - 1].isEmpty {
                rows.append([index])
                currentRowWidth = size.width + spacing
            } else {
                rows[rows.count - 1].append(index)
                currentRowWidth += size.width + spacing
            }
        }

        return rows
    }
}

extension [Int] {
    var height: CGFloat {
        // Simplified: assume uniform height
        return 32
    }
}

#Preview {
    ChipSelector(
        title: "Triggers",
        options: ["Anxious", "Bored", "Stressed", "Social", "Celebratory"],
        selectedValues: .constant(["Anxious", "Stressed"]),
        multiSelect: true
    )
    .padding()
}
```

**Commit:** `[Phase 1] Add ChipSelector component with FlowLayout`

---

#### Step 7: Create Option Constants

**Create:** `Cravey/Presentation/Views/Components/TriggerOptions.swift`

```swift
// Cravey/Presentation/Views/Components/TriggerOptions.swift

import Foundation

enum TriggerOptions {
    static let all: [String] = [
        "Anxious",
        "Bored",
        "Stressed",
        "Social Situation",
        "Celebratory",
        "Craving",
        "Habit/Routine",
        "Sad",
        "Angry",
        "Tired"
    ]
}
```

**Create:** `Cravey/Presentation/Views/Components/LocationOptions.swift`

```swift
// Cravey/Presentation/Views/Components/LocationOptions.swift

import Foundation

enum LocationOptions {
    static let presets: [String] = [
        "Home",
        "Work",
        "Social Gathering",
        "Outdoors",
        "Vehicle",
        "Other"
    ]
}
```

**Commit:** `[Phase 1] Add trigger and location option constants`

---

### Day 3: Craving Logging View

#### Step 8: Create CravingLogForm.swift

**Test First (RED):** UI test (end-to-end)

**Create Test:** `CraveyUITests/CravingLogUITests.swift`

```swift
// CraveyUITests/CravingLogUITests.swift

import XCTest

final class CravingLogUITests: XCTestCase {

    func testLogCravingUnder5Seconds() throws {
        let app = XCUIApplication()
        app.launch()

        let startTime = Date()

        // 1. Tap + button in Home tab
        app.buttons["plus.circle.fill"].tap()

        // 2. Tap "Log Craving" in menu
        app.buttons["Log Craving"].tap()

        // 3. Adjust intensity slider to 7
        let slider = app.sliders["Intensity"]
        slider.adjust(toNormalizedSliderPosition: 0.7)

        // 4. Tap Save
        app.buttons["Save"].tap()

        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)

        XCTAssertLessThan(duration, 5.0, "Craving log took \(duration)s, target <5s")
    }
}
```

**Implement (GREEN):**

```swift
// Cravey/Presentation/Views/Craving/CravingLogForm.swift

import SwiftUI

struct CravingLogForm: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: CravingLogViewModel

    init(viewModel: CravingLogViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                // REQUIRED SECTION
                Section {
                    IntensitySlider(value: $viewModel.intensity)
                        .accessibilityLabel("Intensity")
                }

                // OPTIONAL SECTION
                Section("Details (Optional)") {
                    ChipSelector(
                        title: "What triggered this?",
                        options: TriggerOptions.all,
                        selectedValues: $viewModel.selectedTriggers,
                        multiSelect: true
                    )

                    ChipSelector(
                        title: "Where are you?",
                        options: LocationOptions.presets,
                        selectedValues: Binding(
                            get: {
                                viewModel.location.isEmpty ? [] : Set([viewModel.location])
                            },
                            set: {
                                viewModel.location = $0.first ?? ""
                            }
                        ),
                        multiSelect: false
                    )

                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...5)

                    Toggle("I managed this craving successfully", isOn: $viewModel.wasManagedSuccessfully)
                }
            }
            .navigationTitle("Log Craving")
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
                            await viewModel.logCraving()
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
                Text("Craving logged successfully ✓")
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
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
}

#Preview {
    let container = DependencyContainer.preview
    let viewModel = container.makeCravingLogViewModel()
    return CravingLogForm(viewModel: viewModel)
}
```

**Wire Up in HomeView:**

```swift
// Modify Cravey/Presentation/Views/Home/HomeView.swift

import SwiftUI

struct HomeView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var showCravingLogSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("🌿 Cravey")
                    .font(.largeTitle.bold())

                Text("Track your journey to clarity")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                // TODO: Craving list (Step 10)
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Log Craving") {
                            showCravingLogSheet = true
                        }
                        Button("Log Usage") {
                            // TODO: Phase 2
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
        }
    }
}
```

**Test:**
1. Build and run app
2. Tap + button → "Log Craving"
3. Adjust intensity slider
4. Tap Save
5. Verify success alert shows
6. Verify sheet dismisses
7. Use stopwatch to verify <5 sec

**Commit:** `[Phase 1] Add CravingLogForm with <5 sec validation`

---

#### Step 9: Create CravingListView.swift

**Goal:** Display all cravings in HomeView

**Create ViewModel:** `Cravey/Presentation/ViewModels/CravingListViewModel.swift`

```swift
// Cravey/Presentation/ViewModels/CravingListViewModel.swift

import Foundation

@Observable
@MainActor
final class CravingListViewModel {
    var cravings: [CravingEntity] = []
    var isLoading = false
    var errorMessage: String?

    private let fetchCravingsUseCase: FetchCravingsUseCase

    init(fetchCravingsUseCase: FetchCravingsUseCase) {
        self.fetchCravingsUseCase = fetchCravingsUseCase
    }

    func fetchCravings() async {
        isLoading = true
        errorMessage = nil

        do {
            cravings = try await fetchCravingsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
```

**Create View:**

```swift
// Cravey/Presentation/Views/Craving/CravingListView.swift

import SwiftUI

struct CravingListView: View {
    @State var viewModel: CravingListViewModel

    init(viewModel: CravingListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.cravings.isEmpty {
                EmptyStatePlaceholder()
            } else {
                List(viewModel.cravings) { craving in
                    CravingRow(craving: craving)
                }
                .listStyle(.plain)
            }
        }
        .task {
            await viewModel.fetchCravings()
        }
    }
}

struct CravingRow: View {
    let craving: CravingEntity

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Intensity Badge
            ZStack {
                Circle()
                    .fill(intensityColor(for: craving.intensity))
                    .frame(width: 40, height: 40)

                Text("\(craving.intensity)")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(craving.timestamp, style: .relative)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if !craving.triggers.isEmpty {
                    Text(craving.triggers.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let notes = craving.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func intensityColor(for intensity: Int) -> Color {
        switch intensity {
        case 1...3: return .green
        case 4...6: return .yellow
        case 7...8: return .orange
        case 9...10: return .red
        default: return .gray
        }
    }
}

struct EmptyStatePlaceholder: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Cravings Logged")
                .font(.headline)

            Text("Tap + to log your first craving")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    let container = DependencyContainer()
    let viewModel = CravingListViewModel(
        fetchCravingsUseCase: container.fetchCravingsUseCase
    )
    return CravingListView(viewModel: viewModel)
}
```

**Wire Up in HomeView:**

```swift
// Modify Cravey/Presentation/Views/Home/HomeView.swift

import SwiftUI

struct HomeView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var showCravingLogSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Craving List
                CravingListView(
                    viewModel: CravingListViewModel(
                        fetchCravingsUseCase: container.fetchCravingsUseCase
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
                            // TODO: Phase 2
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
        }
    }
}
```

**Test:**
1. Build and run app
2. Verify empty state shows ("No Cravings Logged")
3. Log a craving
4. Verify craving appears in list with intensity badge
5. Verify timestamp shows relative time ("2 minutes ago")

**Commit:** `[Phase 1] Add CravingListView with empty state`

---

### Day 4: Integration Testing

#### Step 10: Write Integration Tests

**Create Test:** `CraveyTests/Integration/CravingLogIntegrationTests.swift`

```swift
// CraveyTests/Integration/CravingLogIntegrationTests.swift

import Testing
import SwiftData
@testable import Cravey

@Suite("Craving Log Integration Tests")
struct CravingLogIntegrationTests {

    @Test("Should log craving end-to-end (Form → ViewModel → UseCase → Repository → SwiftData)")
    func testEndToEndCravingLog() async throws {
        // Setup: In-memory SwiftData container
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: CravingModel.self,
            configurations: config
        )
        let context = ModelContext(container)

        // Setup: Real dependencies (no mocks)
        let repository = CravingRepository(modelContext: context)
        let useCase = DefaultLogCravingUseCase(repository: repository)
        let viewModel = CravingLogViewModel(logCravingUseCase: useCase)

        // Given: User fills form
        viewModel.intensity = 7
        viewModel.selectedTriggers = Set(["Anxious", "Bored"])
        viewModel.notes = "Integration test"
        viewModel.location = "Home"
        viewModel.wasManagedSuccessfully = false

        // When: User taps Save
        await viewModel.logCraving()

        // Then: Craving saved to SwiftData
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.showSuccessAlert == true)

        // Verify: Fetch from SwiftData
        let descriptor = FetchDescriptor<CravingModel>()
        let results = try context.fetch(descriptor)
        #expect(results.count == 1)

        let savedCraving = results[0]
        #expect(savedCraving.intensity == 7)
        #expect(savedCraving.triggers == ["Anxious", "Bored"])
        #expect(savedCraving.notes == "Integration test")
    }

    @Test("Should fetch cravings end-to-end (SwiftData → Repository → UseCase → ViewModel)")
    func testEndToEndFetchCravings() async throws {
        // Setup
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: CravingModel.self,
            configurations: config
        )
        let context = ModelContext(container)

        // Insert sample craving
        let craving = CravingModel(
            timestamp: Date(),
            intensity: 5,
            triggers: ["Stressed"],
            notes: "Test",
            wasManagedSuccessfully: true
        )
        context.insert(craving)
        try context.save()

        // Setup: Real dependencies
        let repository = CravingRepository(modelContext: context)
        let useCase = DefaultFetchCravingsUseCase(repository: repository)
        let viewModel = CravingListViewModel(fetchCravingsUseCase: useCase)

        // When: Fetch cravings
        await viewModel.fetchCravings()

        // Then: Craving appears in ViewModel
        #expect(viewModel.cravings.count == 1)
        #expect(viewModel.cravings[0].intensity == 5)
        #expect(viewModel.cravings[0].triggers == ["Stressed"])
    }

    // Note: List refresh behavior tested manually in Step 14
    // Auto-refresh via .id(refreshID) binding validated in manual checklist
}
```

**Run Tests:**

```bash
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests/CravingLogIntegrationTests | xcbeautify
```

**Verify:** ✅ 2/3 tests passing (3rd test is TODO)

**Commit:** `[Phase 1] Add integration tests for craving log flow`

---

### Day 5: Polish + Validation

#### Step 11: Implement List Refresh

**Problem:** When user logs a craving, CravingListView doesn't auto-refresh.

**Solution:** Use `.refreshable` modifier + manual refresh trigger

**Modify:** `Cravey/Presentation/Views/Craving/CravingListView.swift`

```swift
// Add .refreshable modifier
var body: some View {
    Group {
        // ... existing code
    }
    .task {
        await viewModel.fetchCravings()
    }
    .refreshable {  // ← ADD THIS
        await viewModel.fetchCravings()
    }
}
```

**Modify:** `Cravey/Presentation/Views/Home/HomeView.swift`

```swift
// Add @State for manual refresh
@State private var refreshID = UUID()

// ... in body:
CravingListView(
    viewModel: CravingListViewModel(
        fetchCravingsUseCase: container.fetchCravingsUseCase
    )
)
.id(refreshID)  // ← Force re-render when refreshID changes

// ... in sheet's onDismiss:
.sheet(isPresented: $showCravingLogSheet) {
    refreshID = UUID()  // ← Trigger refresh after dismiss
} content: {
    let viewModel = container.makeCravingLogViewModel()
    CravingLogForm(viewModel: viewModel)
}
```

**Test:**
1. Log a craving
2. Verify list auto-updates with new craving (no manual pull-to-refresh needed)

**Commit:** `[Phase 1] Add auto-refresh to craving list after logging`

---

#### Step 12: Run Full Test Suite

**Run All Tests:**

```bash
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' | xcbeautify
```

**Expected Results:**
- ✅ LogCravingUseCaseTests: 2/2 passing (baseline)
- ✅ CravingLogViewModelTests: 2/2 passing (baseline)
- ✅ IntensitySliderTests: 2/2 passing (Phase 1)
- ✅ CravingLogIntegrationTests: 2/2 passing (Phase 1)
- ✅ CravingLogUITests: 1/1 passing (Phase 1)

**Total:** 9/9 tests passing (6 unit + 2 integration + 1 UI)

---

#### Step 13: Manual Testing Checklist

- [ ] App launches without crash
- [ ] Tab bar shows 3 tabs (Home, Dashboard, Settings)
- [ ] Home tab shows empty state ("No Cravings Logged")
- [ ] Tap + button → "Log Craving" opens sheet
- [ ] Intensity slider works (1-10 range, emoji updates)
- [ ] Trigger chips work (multi-select, visual feedback)
- [ ] Location chips work (single-select)
- [ ] Cancel button dismisses sheet without saving
- [ ] Save button logs craving (<5 sec validated)
- [ ] Success alert shows after Save (with OK button)
- [ ] Tapping OK on alert dismisses sheet
- [ ] List auto-refreshes with new craving after dismissal
- [ ] Craving row shows intensity badge (correct color)
- [ ] Timestamp shows relative time ("2 minutes ago")
- [ ] Triggers display correctly
- [ ] Notes display correctly (if present)
- [ ] Pull-to-refresh works

---

#### Step 14: Performance Validation

**Goal:** Verify <5 sec log time

**Manual Test:**
1. Open app
2. Start stopwatch
3. Tap + → "Log Craving"
4. Set intensity to 7
5. Tap Save
6. Stop stopwatch when success alert appears

**Expected:** <5 seconds total

**If fails:** Profile with Instruments (Time Profiler) to find bottleneck

---

#### Step 15: Code Quality Check

**Run SwiftLint:**

```bash
swiftlint
```

**Expected:** <10 warnings

**Run SwiftFormat:**

```bash
swiftformat .
```

**Verify:** Code formatted consistently

---

## ✅ Phase 1 Completion Checklist

- [ ] All 17 files created/modified (2 foundation + 1 app + 3 tabs + 5 components + 3 views/VMs + 3 test files)
- [ ] Build succeeds with zero errors
- [ ] All 9 tests passing (6 unit + 2 integration + 1 UI)
- [ ] Manual testing complete (15/15 checklist items)
- [ ] Performance validated (<5 sec craving log)
- [ ] SwiftLint violations ≤13 warnings (13 TODOs for Phase 2+ features are acceptable)
- [ ] Code formatted (swiftformat)
- [ ] Git commits pushed (feature/phase-1 branch)
- [ ] Phase deliverable shippable (users can log cravings)
- [ ] DI container uses environment injection (no duplicate instances)
- [ ] UsageModel includes @Attribute(.unique) on id field
- [ ] Alert/dismiss flow works correctly (success alert shows before dismiss)

---

## 🚀 What's Next: Phase 2

**Phase 2: Usage Logging (Week 2)** begins with:
1. Create UsageEntity (pure Swift, copy pattern from CravingEntity)
2. Create UsageRepositoryProtocol + UsageRepository (replaces what was skipped in Phase 1)
3. Create LogUsageUseCase + FetchUsageUseCase (copy patterns from Craving use cases)
4. Create ROAPickerInput component (ROA-aware amounts - Bowls, Vape, Edible, etc.)
5. Create UsageLogForm + UsageListView (copy patterns from CravingLogForm/CravingListView)
6. Wire up "Log Usage" menu item in HomeView
7. Write 14 tests (10 unit + 2 integration + 2 UI)

**See:** [PHASE_2.md](./PHASE_2.md)

---

## 📚 References

- [TECHNICAL_IMPLEMENTATION.md](../TECHNICAL_IMPLEMENTATION.md) - Master spec
- [MVP_PRODUCT_SPEC.md](../MVP_PRODUCT_SPEC.md) - Feature requirements
- [UX_FLOW_SPEC.md](../UX_FLOW_SPEC.md) - Screen flows
- [CLAUDE.md](../../CLAUDE.md) - Architecture patterns

---

**Status:** ✅ Phase 1 documentation complete - Ready to code! 🚀

**[← Back to Overview](./PHASE_OVERVIEW.md)** | **[Phase 2 →](./PHASE_2.md)**
