# Phase 3: Onboarding + Data Management (Weeks 3-4)

**Version:** 3.0 (Chronologically Ordered + Technical Fixes)
**Duration:** 2 weeks (Weeks 3-4 of 16-week timeline)
**Dependencies:** Phases 1-2 complete (Craving + Usage logging) - **⚠️ PHASE_2 MUST BE COMPLETE** (requires UsageRepository for export)
**Status:** 📝 Ready for Implementation
**Last Updated:** 2025-11-01

---

## 🎯 Phase Goal

**Shippable Deliverable:** Users can **complete onboarding in <60 seconds**, **export all data** (CSV + JSON), and **delete all data** with confirmation.

**Features Implemented:**
- Feature 0 (Onboarding): WelcomeView + TourView
- Feature 5 (Data Management): Export + Delete + Settings UI

**Week 3 Focus:** Onboarding flow (Welcome → Tour → Home tab), basic Settings shell
**Week 4 Focus:** Export/Delete use cases, Settings UI polish, testing

---

## 📋 What's Already Done (Baseline from Phases 1-2)

### Domain Layer
- ✅ `CravingEntity.swift` - Domain model for cravings (PHASE_1)
- ✅ `UsageEntity.swift` - Domain model for usage logs (PHASE_2)
- ✅ `RecordingEntity.swift` - Domain model for recordings (baseline, full implementation in PHASE_4)
- ✅ `CravingRepositoryProtocol.swift` - Repository interface with `fetchAll()` method
- ✅ `UsageRepositoryProtocol.swift` - Repository interface with `fetchAll()` + `delete(id:)` methods (PHASE_2)
- ✅ `RecordingRepositoryProtocol.swift` - Repository interface (baseline)

### Data Layer
- ✅ `CravingModel.swift` - SwiftData @Model (PHASE_1)
- ✅ `UsageModel.swift` - SwiftData @Model (PHASE_2)
- ✅ `RecordingModel.swift` - SwiftData @Model (baseline)
- ✅ `CravingRepository.swift` - Full implementation with `fetchAll()` (PHASE_1)
- ✅ `UsageRepository.swift` - Full implementation with `fetchAll()` + `delete(id:)` (PHASE_2)
- ✅ `RecordingRepository.swift` - Stub implementation (real implementation in PHASE_4)
- ✅ `CravingMapper.swift`, `UsageMapper.swift`, `RecordingMapper.swift` - Entity ↔ Model conversion

### Presentation Layer
- ✅ `HomeView.swift` - Exists (will be enhanced with tab bar integration)
- ✅ `CravingLogForm.swift` - Craving logging UI (PHASE_1)
- ✅ `UsageLogForm.swift` - Usage logging UI (PHASE_2)

### App Layer
- ✅ `DependencyContainer.swift` - DI container with all repositories
- ✅ `CraveyApp.swift` - @main entry point

**Key Infrastructure Available:**
- SwiftData ModelContainer with all 4 models (Craving, Usage, Recording, Message)
- Repository pattern established (CravingRepository shows the pattern)
- Clean Architecture DI via @Environment
- Tab bar shell ready for Settings tab

---

## 📦 Complete File Checklist (8 files total)

### Part 1: Domain Layer - Use Cases (2 files)
- [ ] `Domain/UseCases/ExportDataUseCase.swift` (CREATE - CSV/JSON generation)
- [ ] `Domain/UseCases/DeleteAllDataUseCase.swift` (CREATE - atomic deletion)

### Part 2: Presentation Layer - ViewModels (1 file)
- [ ] `Presentation/ViewModels/SettingsViewModel.swift` (CREATE - settings state management)

### Part 3: Presentation Layer - Views (5 files)
- [ ] `Presentation/Views/Onboarding/WelcomeView.swift` (CREATE - first-launch welcome screen)
- [ ] `Presentation/Views/Onboarding/TourView.swift` (CREATE - 4-card swipeable tour)
- [ ] `Presentation/Views/Settings/SettingsView.swift` (CREATE - settings list with data management)
- [ ] `Presentation/Views/Settings/ExportDataView.swift` (CREATE - format picker + share sheet)
- [ ] `Presentation/Views/Settings/DeleteDataConfirmationView.swift` (CREATE - destructive action confirmation)

---

## 🧪 Test Plan (14 tests total)

### Unit Tests (8 tests across 3 files)

**Domain Layer (4 tests):**
1. `ExportDataUseCaseTests.swift` (2 tests)
   - Test: Export CSV with all data types (cravings + usage + recordings)
   - Test: Export JSON with all data types

2. `DeleteAllDataUseCaseTests.swift` (2 tests)
   - Test: Delete all data atomically (all 4 repositories cleared)
   - Test: Verify file deletion for recordings

**Presentation Layer (4 tests):**
3. `SettingsViewModelTests.swift` (4 tests)
   - Test: Export CSV triggers use case and returns URL
   - Test: Export JSON triggers use case and returns URL
   - Test: Delete all data calls use case
   - Test: Error handling for export failures

### Integration Tests (4 tests in 2 files)

4. `OnboardingIntegrationTests.swift` (2 tests)
   - Test: Complete onboarding flow (Welcome → Tour → Home tab)
   - Test: Onboarding only shows on first launch (UserDefaults check)

5. `DataManagementIntegrationTests.swift` (2 tests)
   - Test: Export flow generates valid CSV file
   - Test: Delete all data clears database and files

### UI Tests (2 tests in 1 file)

6. `SettingsUITests.swift` (2 tests)
   - Test: Export CSV flow (Settings → Export → Share Sheet appears)
   - Test: Delete all data flow (Settings → Delete → Confirmation → Success)

**Total: 8 unit + 4 integration + 2 UI = 14 tests**

---

## 🚀 Implementation Steps (Week 3: Onboarding, Week 4: Data Management)

---

## WEEK 3: Onboarding Flow

### Step 1: Create WelcomeView (Onboarding Screen 1)

**File:** `Cravey/Presentation/Views/Onboarding/WelcomeView.swift`

**Purpose:** First-launch welcome screen with privacy message and CTA to start tour.

```swift
import SwiftUI

/// First-launch welcome screen with privacy-first messaging
struct WelcomeView: View {
    @Binding var showOnboarding: Bool
    @State private var showTour = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.6), .purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // App icon/logo placeholder
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)

                // Welcome text
                VStack(spacing: 12) {
                    Text("Welcome to Cravey")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Your private companion for cannabis cessation")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                // Privacy badge
                HStack(spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .font(.title2)
                        .foregroundColor(.green)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("100% Private")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("All data stays on your device")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding()
                .background(Color.white.opacity(0.15))
                .cornerRadius(12)

                // CTA button
                Button {
                    showTour = true
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .fullScreenCover(isPresented: $showTour) {
            TourView(showOnboarding: $showOnboarding)
        }
    }
}

#Preview {
    WelcomeView(showOnboarding: .constant(true))
}
```

**Why This Code:**
- **Privacy-first messaging** - Emphasizes local-only data storage (core value prop)
- **Simple CTA** - Single "Get Started" button (no cognitive load)
- **Visual hierarchy** - Gradient background, large icon, clear text hierarchy
- **@Binding for flow control** - Parent can dismiss onboarding when complete

---

### Step 2: Create TourView (Onboarding Screen 2)

**File:** `Cravey/Presentation/Views/Onboarding/TourView.swift`

**Purpose:** 4-card swipeable tour explaining app features (<60 sec to complete).

```swift
import SwiftUI

/// 4-card swipeable tour of app features
struct TourView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    private let tourCards: [TourCard] = [
        TourCard(
            icon: "pencil.circle.fill",
            title: "Track Cravings",
            description: "Log cravings in <5 seconds. Track intensity, triggers, and outcomes.",
            color: .blue
        ),
        TourCard(
            icon: "chart.line.uptrend.xyaxis.circle.fill",
            title: "Visualize Progress",
            description: "See patterns, streaks, and progress over time. Celebrate wins.",
            color: .green
        ),
        TourCard(
            icon: "video.circle.fill",
            title: "Record Motivation",
            description: "Save videos/audio to play during vulnerable moments.",
            color: .purple
        ),
        TourCard(
            icon: "lock.circle.fill",
            title: "Stay Private",
            description: "All data stays on your device. No cloud sync, no tracking.",
            color: .orange
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack(spacing: 8) {
                ForEach(0..<tourCards.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: index == currentPage ? 30 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: currentPage)
                }
            }
            .padding(.top, 20)

            // Tour cards (swipeable)
            TabView(selection: $currentPage) {
                ForEach(0..<tourCards.count, id: \.self) { index in
                    TourCardView(card: tourCards[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // CTA button
            Button {
                if currentPage < tourCards.count - 1 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    // Complete onboarding
                    hasCompletedOnboarding = true
                    showOnboarding = false
                }
            } label: {
                Text(currentPage < tourCards.count - 1 ? "Next" : "Start Using Cravey")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)

            // Skip button (first 3 cards only)
            if currentPage < tourCards.count - 1 {
                Button("Skip") {
                    hasCompletedOnboarding = true
                    showOnboarding = false
                }
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            }
        }
    }
}

// Tour card data model
struct TourCard {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// Individual tour card view
struct TourCardView: View {
    let card: TourCard

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: card.icon)
                .font(.system(size: 100))
                .foregroundColor(card.color)

            VStack(spacing: 12) {
                Text(card.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(card.description)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()
        }
    }
}

#Preview {
    TourView(showOnboarding: .constant(true))
}
```

**Why This Code:**
- **4 cards, <60 sec** - Minimal friction, user can skip
- **@AppStorage for persistence** - Onboarding only shows once
- **SwipTabView with progress dots** - Standard iOS pattern
- **Adaptive CTA** - "Next" → "Start Using Cravey" on last card
- **Feature-focused messaging** - Clear value props (Track, Visualize, Record, Privacy)

**Dependencies Required:**
- None - Pure SwiftUI, no use cases

---

## WEEK 4: Data Management

### Step 3: Create ExportDataUseCase (Domain Layer)

**File:** `Cravey/Domain/UseCases/ExportDataUseCase.swift`

**Purpose:** Business logic for exporting all data to CSV or JSON format.

```swift
import Foundation

/// Export format options
enum ExportFormat: String, Sendable {
    case csv
    case json
}

/// Use case for exporting all app data
protocol ExportDataUseCase: Sendable {
    /// Export all data (cravings + usage + recordings metadata) to specified format
    /// - Parameter format: CSV or JSON
    /// - Returns: URL to generated export file in Documents directory
    func execute(format: ExportFormat) async throws -> URL
}

/// Default implementation of ExportDataUseCase
actor DefaultExportDataUseCase: ExportDataUseCase {
    private let cravingRepository: CravingRepositoryProtocol
    private let usageRepository: UsageRepositoryProtocol
    private let recordingRepository: RecordingRepositoryProtocol

    init(
        cravingRepository: CravingRepositoryProtocol,
        usageRepository: UsageRepositoryProtocol,
        recordingRepository: RecordingRepositoryProtocol
    ) {
        self.cravingRepository = cravingRepository
        self.usageRepository = usageRepository
        self.recordingRepository = recordingRepository
    }

    func execute(format: ExportFormat) async throws -> URL {
        // Fetch all data from repositories
        let cravings = try await cravingRepository.fetchAll()
        let usageLogs = try await usageRepository.fetchAll()
        let recordings = try await recordingRepository.fetchAll()

        // Generate export file based on format
        let fileName = "cravey_export_\(Date().ISO8601Format()).txt"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName.replacingOccurrences(of: ".txt", with: ".\(format.rawValue)"))

        switch format {
        case .csv:
            let csvContent = try generateCSV(cravings: cravings, usageLogs: usageLogs, recordings: recordings)
            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)

        case .json:
            let jsonData = try generateJSON(cravings: cravings, usageLogs: usageLogs, recordings: recordings)
            try jsonData.write(to: fileURL)
        }

        return fileURL
    }

    // MARK: - CSV Generation

    private func generateCSV(cravings: [CravingEntity], usageLogs: [UsageEntity], recordings: [RecordingEntity]) throws -> String {
        var csv = ""

        // Cravings section
        csv += "CRAVINGS\n"
        csv += "Timestamp,Intensity,Duration (min),Triggers,Location,Notes,Managed Successfully\n"

        for craving in cravings {
            let row = [
                ISO8601DateFormatter().string(from: craving.timestamp),
                String(craving.intensity),
                String(craving.duration ?? 0),
                craving.triggers.joined(separator: "; "),
                craving.location ?? "",
                (craving.notes ?? "").replacingOccurrences(of: ",", with: ";"), // Escape commas
                String(craving.wasManagedSuccessfully)
            ].joined(separator: ",")
            csv += row + "\n"
        }

        // Usage section
        csv += "\nUSAGE LOGS\n"
        csv += "Timestamp,ROA,Amount,Triggers,Location,Notes\n"

        for usage in usageLogs {
            let row = [
                ISO8601DateFormatter().string(from: usage.timestamp),
                usage.roa,
                usage.amount ?? "",
                usage.triggers.joined(separator: "; "),
                usage.location ?? "",
                (usage.notes ?? "").replacingOccurrences(of: ",", with: ";")
            ].joined(separator: ",")
            csv += row + "\n"
        }

        // Recordings section
        csv += "\nRECORDINGS\n"
        csv += "Timestamp,Type,Title,Duration (sec),Play Count,Last Played,Purpose\n"

        for recording in recordings {
            let row = [
                ISO8601DateFormatter().string(from: recording.timestamp),
                recording.type.rawValue,
                recording.title ?? "",
                String(format: "%.1f", recording.duration),
                String(recording.playCount),
                recording.lastPlayedAt.map { ISO8601DateFormatter().string(from: $0) } ?? "",
                recording.purpose.rawValue
            ].joined(separator: ",")
            csv += row + "\n"
        }

        return csv
    }

    // MARK: - JSON Generation

    private func generateJSON(cravings: [CravingEntity], usageLogs: [UsageEntity], recordings: [RecordingEntity]) throws -> Data {
        let exportData: [String: Any] = [
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "version": "1.0",
            "cravings": cravings.map { craving in
                [
                    "id": craving.id.uuidString,
                    "timestamp": ISO8601DateFormatter().string(from: craving.timestamp),
                    "intensity": craving.intensity,
                    "duration": craving.duration ?? 0,
                    "triggers": craving.triggers,
                    "location": craving.location ?? "",
                    "notes": craving.notes ?? "",
                    "managedSuccessfully": craving.wasManagedSuccessfully
                ]
            },
            "usageLogs": usageLogs.map { usage in
                [
                    "id": usage.id.uuidString,
                    "timestamp": ISO8601DateFormatter().string(from: usage.timestamp),
                    "roa": usage.roa,
                    "amount": usage.amount ?? "",
                    "triggers": usage.triggers,
                    "location": usage.location ?? "",
                    "notes": usage.notes ?? ""
                ]
            },
            "recordings": recordings.map { recording in
                [
                    "id": recording.id.uuidString,
                    "timestamp": ISO8601DateFormatter().string(from: recording.timestamp),
                    "type": recording.type.rawValue,
                    "title": recording.title ?? "",
                    "duration": recording.duration,
                    "playCount": recording.playCount,
                    "lastPlayedAt": recording.lastPlayedAt.map { ISO8601DateFormatter().string(from: $0) } ?? "",
                    "purpose": recording.purpose.rawValue,
                    "filePath": recording.filePath
                ]
            }
        ]

        return try JSONSerialization.data(withJSONObject: exportData, options: [.prettyPrinted, .sortedKeys])
    }
}
```

**Why This Code:**
- **Fetches from all 3 repositories** - Comprehensive export (cravings + usage + recordings)
- **Dual format support** - CSV for spreadsheet apps, JSON for programmatic access
- **ISO 8601 timestamps** - Universal date format
- **Escapes CSV commas** - Prevents data corruption (notes field)
- **Actor isolation** - Thread-safe async operations
- **Pure domain layer** - No SwiftUI/SwiftData imports

**Dependencies Required:**
- ✅ `CravingRepositoryProtocol.fetchAll()` - Exists (PHASE_1)
- ⚠️ `UsageRepositoryProtocol.fetchAll()` - Must exist from PHASE_2
- ⚠️ `RecordingRepositoryProtocol.fetchAll()` - Stub exists (real implementation in PHASE_4)

---

### Step 4: Create DeleteAllDataUseCase (Domain Layer)

**File:** `Cravey/Domain/UseCases/DeleteAllDataUseCase.swift`

**Purpose:** Business logic for atomic deletion of all app data (database + files).

```swift
import Foundation

/// Use case for deleting all app data (database + files)
protocol DeleteAllDataUseCase: Sendable {
    /// Atomically delete all cravings, usage logs, recordings (metadata + files), and messages
    func execute() async throws
}

/// Default implementation of DeleteAllDataUseCase
actor DefaultDeleteAllDataUseCase: DeleteAllDataUseCase {
    private let cravingRepository: CravingRepositoryProtocol
    private let usageRepository: UsageRepositoryProtocol
    private let recordingRepository: RecordingRepositoryProtocol

    init(
        cravingRepository: CravingRepositoryProtocol,
        usageRepository: UsageRepositoryProtocol,
        recordingRepository: RecordingRepositoryProtocol
    ) {
        self.cravingRepository = cravingRepository
        self.usageRepository = usageRepository
        self.recordingRepository = recordingRepository
    }

    func execute() async throws {
        // 1. Fetch all recordings to get file paths
        let recordings = try await recordingRepository.fetchAll()

        // 2. Delete all database entries
        let cravings = try await cravingRepository.fetchAll()
        for craving in cravings {
            try await cravingRepository.delete(id: craving.id)
        }

        let usageLogs = try await usageRepository.fetchAll()
        for usage in usageLogs {
            try await usageRepository.delete(id: usage.id)
        }

        for recording in recordings {
            try await recordingRepository.delete(id: recording.id)
        }

        // 3. Delete all recording files from disk
        // Note: FileStorageManager will be introduced in PHASE_4 (Recordings).
        // Until then, we use FileManager directly for directory deletion.
        // This is acceptable because RecordingRepository is still a stub at this phase.
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let recordingsURL = documentsURL.appendingPathComponent("Recordings")

        // Delete entire Recordings directory (if it exists)
        if fileManager.fileExists(atPath: recordingsURL.path) {
            try fileManager.removeItem(at: recordingsURL)
        }

        // Note: Motivational messages are NOT deleted (default content persists)
    }
}
```

**Why This Code:**
- **Atomic deletion** - All or nothing (if one fails, throw error)
- **Database + file deletion** - Clears SwiftData AND recording files
- **Preserves default messages** - Only user data deleted (not app content)
- **Actor isolation** - Thread-safe async operations
- **Uses existing repository APIs** - `delete(id:)` from CravingRepositoryProtocol
- **Raw FileManager for recordings** - FileStorageManager doesn't exist yet (introduced in PHASE_4)

**Dependencies Required:**
- ✅ `CravingRepositoryProtocol.fetchAll()` + `delete(id:)` - Exists (PHASE_1)
- ⚠️ `UsageRepositoryProtocol.fetchAll()` + `delete(id:)` - Must exist from PHASE_2
- ⚠️ `RecordingRepositoryProtocol.fetchAll()` + `delete(id:)` - Stub exists (PHASE_4)

---

### Step 5: Create SettingsViewModel (Presentation Layer)

**File:** `Cravey/Presentation/ViewModels/SettingsViewModel.swift`

**Purpose:** State management for Settings screen (export + delete flows).

```swift
import Foundation
import SwiftUI

/// ViewModel for Settings screen
@Observable
@MainActor
final class SettingsViewModel {
    // MARK: - State

    private(set) var isExporting = false
    private(set) var isDeleting = false
    private(set) var exportedFileURL: URL?
    private(set) var errorMessage: String?
    private(set) var showDeleteConfirmation = false

    // MARK: - Dependencies

    private let exportDataUseCase: ExportDataUseCase
    private let deleteAllDataUseCase: DeleteAllDataUseCase

    init(
        exportDataUseCase: ExportDataUseCase,
        deleteAllDataUseCase: DeleteAllDataUseCase
    ) {
        self.exportDataUseCase = exportDataUseCase
        self.deleteAllDataUseCase = deleteAllDataUseCase
    }

    // MARK: - Actions

    /// Export data to specified format
    func exportData(format: ExportFormat) async {
        isExporting = true
        errorMessage = nil
        exportedFileURL = nil

        do {
            let fileURL = try await exportDataUseCase.execute(format: format)
            exportedFileURL = fileURL
        } catch {
            errorMessage = "Export failed: \(error.localizedDescription)"
        }

        isExporting = false
    }

    /// Show delete confirmation dialog
    func promptDeleteAllData() {
        showDeleteConfirmation = true
    }

    /// Delete all data (called after confirmation)
    func deleteAllData() async {
        isDeleting = true
        errorMessage = nil

        do {
            try await deleteAllDataUseCase.execute()
        } catch {
            errorMessage = "Deletion failed: \(error.localizedDescription)"
        }

        isDeleting = false
    }

    /// Dismiss error message
    func dismissError() {
        errorMessage = nil
    }
}
```

**Why This Code:**
- **@Observable macro** - Modern SwiftUI state management (no ObservableObject)
- **@MainActor** - All UI updates on main thread
- **Separation of concerns** - VM delegates business logic to use cases
- **Loading states** - `isExporting`, `isDeleting` for UI feedback
- **Error handling** - Captures and exposes errors to UI
- **Confirmation flow** - `showDeleteConfirmation` flag for destructive action

**Dependencies Required:**
- ✅ `ExportDataUseCase` - Created in Step 3
- ✅ `DeleteAllDataUseCase` - Created in Step 4

---

### Step 6: Create SettingsView (Presentation Layer)

**File:** `Cravey/Presentation/Views/Settings/SettingsView.swift`

**Purpose:** Settings list with Data Management section (Export + Delete).

```swift
import SwiftUI

/// Settings screen with data management options
struct SettingsView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: SettingsViewModel
    @State private var showExportSheet = false

    init() {
        // ViewModel initialized in onAppear with DI
        _viewModel = State(wrappedValue: SettingsViewModel(
            exportDataUseCase: MockExportDataUseCase(),
            deleteAllDataUseCase: MockDeleteAllDataUseCase()
        ))
    }

    var body: some View {
        NavigationStack {
            List {
                // Data Management Section
                Section {
                    // Export data button
                    Button {
                        showExportSheet = true
                    } label: {
                        Label("Export Data", systemImage: "arrow.up.doc")
                    }
                    .disabled(viewModel.isExporting)

                    // Delete all data button (destructive)
                    Button(role: .destructive) {
                        viewModel.promptDeleteAllData()
                    } label: {
                        Label("Delete All Data", systemImage: "trash")
                    }
                    .disabled(viewModel.isDeleting)

                } header: {
                    Text("Data Management")
                } footer: {
                    Text("Export your data to CSV or JSON. Delete all data will permanently remove all cravings, usage logs, and recordings.")
                }

                // App Info Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                        }
                    }

                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showExportSheet) {
                ExportDataView(viewModel: viewModel)
            }
            .confirmationDialog(
                "Delete All Data",
                isPresented: $viewModel.showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete All Data", role: .destructive) {
                    Task {
                        await viewModel.deleteAllData()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all cravings, usage logs, and recordings. This cannot be undone.")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.dismissError()
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .onAppear {
                // Re-initialize ViewModel with real dependencies from DI
                viewModel = SettingsViewModel(
                    exportDataUseCase: container.exportDataUseCase,
                    deleteAllDataUseCase: container.deleteAllDataUseCase
                )
            }
        }
    }
}

// Mock use cases for preview
actor MockExportDataUseCase: ExportDataUseCase {
    func execute(format: ExportFormat) async throws -> URL {
        try await Task.sleep(for: .seconds(1))
        return FileManager.default.temporaryDirectory.appendingPathComponent("preview_export.\(format.rawValue)")
    }
}

actor MockDeleteAllDataUseCase: DeleteAllDataUseCase {
    func execute() async throws {
        try await Task.sleep(for: .seconds(1))
    }
}

#Preview {
    SettingsView()
        .environment(DependencyContainer.preview)
}
```

**Why This Code:**
- **List-based settings UI** - Standard iOS pattern
- **Destructive action confirmation** - `.confirmationDialog` for delete (iOS 15+)
- **Error handling UI** - `.alert` for error messages
- **Loading states** - Disables buttons during operations
- **Sheet presentation** - `ExportDataView` for format selection
- **DI via @Environment** - Gets dependencies from container
- **Preview mocks** - Mock use cases for Xcode Previews

**Dependencies Required:**
- ✅ `SettingsViewModel` - Created in Step 5
- ✅ `ExportDataView` - Created in Step 7
- ✅ `DependencyContainer.exportDataUseCase` - Added in Step 9
- ✅ `DependencyContainer.deleteAllDataUseCase` - Added in Step 9

---

### Step 7: Create ExportDataView (Presentation Layer)

**File:** `Cravey/Presentation/Views/Settings/ExportDataView.swift`

**Purpose:** Format picker (CSV/JSON) with iOS Share Sheet for export.

```swift
import SwiftUI

/// Export data format picker with share sheet
struct ExportDataView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFormat: ExportFormat = .csv
    @State private var showShareSheet = false
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Format picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Export Format")
                        .font(.headline)

                    Picker("Format", selection: $selectedFormat) {
                        Text("CSV (Spreadsheet)").tag(ExportFormat.csv)
                        Text("JSON (Developers)").tag(ExportFormat.json)
                    }
                    .pickerStyle(.segmented)
                }
                .padding()

                // Format descriptions
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "tablecells")
                            .font(.title2)
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("CSV Format")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text("Open in Numbers, Excel, Google Sheets. Separate sections for cravings, usage, and recordings.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .opacity(selectedFormat == .csv ? 1 : 0.5)

                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "curlybraces")
                            .font(.title2)
                            .foregroundColor(.purple)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("JSON Format")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text("Structured data for developers. Includes metadata and full export timestamp.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .opacity(selectedFormat == .json ? 1 : 0.5)
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()

                // Export button
                Button {
                    Task {
                        await viewModel.exportData(format: selectedFormat)
                        showShareSheet = true
                    }
                } label: {
                    if viewModel.isExporting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Export Data")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .disabled(viewModel.isExporting)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let fileURL = viewModel.exportedFileURL {
                    ShareSheet(items: [fileURL])
                        .onDisappear {
                            dismiss()
                        }
                }
            }
        }
    }
}

/// UIViewControllerRepresentable wrapper for UIActivityViewController (Share Sheet)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    ExportDataView(viewModel: SettingsViewModel(
        exportDataUseCase: MockExportDataUseCase(),
        deleteAllDataUseCase: MockDeleteAllDataUseCase()
    ))
}
```

**Why This Code:**
- **Segmented picker** - Clear CSV vs JSON choice
- **Format descriptions** - Educates users on use cases
- **iOS Share Sheet** - Native sharing (AirDrop, email, Files app)
- **UIViewControllerRepresentable** - Bridges UIKit share sheet to SwiftUI
- **Loading state** - ProgressView during export
- **Dismisses after share** - Clean UX flow

**Dependencies Required:**
- ✅ `SettingsViewModel` - Created in Step 5
- ✅ `ExportFormat` enum - Defined in Step 3

---

### Step 8: Update DependencyContainer (Wire New Use Cases)

**File:** `Cravey/App/DependencyContainer.swift`

**Purpose:** Add ExportDataUseCase and DeleteAllDataUseCase to DI container.

**Modifications:**

```swift
// ADD to DependencyContainer class properties:
let exportDataUseCase: ExportDataUseCase
let deleteAllDataUseCase: DeleteAllDataUseCase

// ADD to init() method after existing repository initialization:
// Export/Delete use cases (PHASE_3 - Onboarding + Data Management)
self.exportDataUseCase = DefaultExportDataUseCase(
    cravingRepository: cravingRepository,
    usageRepository: usageRepository,
    recordingRepository: recordingRepository
)

self.deleteAllDataUseCase = DefaultDeleteAllDataUseCase(
    cravingRepository: cravingRepository,
    usageRepository: usageRepository,
    recordingRepository: recordingRepository
)

// ADD to static preview property:
static var preview: DependencyContainer {
    let container = ModelContainer.preview
    return DependencyContainer(modelContainer: container)
}
```

**Why This Code:**
- **Centralized DI** - All use cases wired in one place
- **Uses existing repositories** - Reuses craving/usage/recording repos
- **Follows established pattern** - Same pattern as existing use cases

**Dependencies Required:**
- ✅ `CravingRepository` - Exists (PHASE_1)
- ⚠️ `UsageRepository` - Must exist from PHASE_2
- ⚠️ `RecordingRepository` - Stub exists (PHASE_4 replaces stub)

---

### Step 9: Update CraveyApp.swift (Add Onboarding Flow)

**File:** `Cravey/App/CraveyApp.swift`

**Purpose:** Show onboarding on first launch, then main app.

**Modifications:**

```swift
import SwiftUI
import SwiftData

@main
struct CraveyApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false

    // ... existing modelContainer and container code ...

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                HomeView()
                    .environment(container)
            } else {
                WelcomeView(showOnboarding: $showOnboarding)
                    .onAppear {
                        showOnboarding = true
                    }
            }
        }
        .modelContainer(modelContainer)
    }
}
```

**Why This Code:**
- **@AppStorage check** - Persists onboarding completion
- **Conditional root view** - WelcomeView → HomeView after onboarding
- **One-time flow** - Never shows again after completion

---

## ✅ Success Criteria (Phase 3 Complete When...)

### Onboarding
- [ ] WelcomeView shows on first launch with privacy messaging
- [ ] TourView shows 4 cards (Track, Visualize, Record, Privacy)
- [ ] User can swipe through tour or skip
- [ ] "Start Using Cravey" button completes onboarding
- [ ] Onboarding never shows again after completion
- [ ] Time to complete onboarding <60 seconds

### Export Data
- [ ] SettingsView shows "Export Data" button
- [ ] ExportDataView allows CSV/JSON format selection
- [ ] Export generates valid CSV with all data (cravings + usage + recordings)
- [ ] Export generates valid JSON with all data
- [ ] iOS Share Sheet appears with export file
- [ ] CSV opens correctly in Numbers/Excel
- [ ] JSON validates with JSON linter

### Delete All Data
- [ ] SettingsView shows "Delete All Data" button (red/destructive)
- [ ] Confirmation dialog appears with warning message
- [ ] Delete removes all cravings from database
- [ ] Delete removes all usage logs from database
- [ ] Delete removes all recordings from database
- [ ] Delete removes all recording files from ~/Documents/Recordings/
- [ ] Dashboard shows empty state after deletion
- [ ] Deletion completes in <3 seconds

### Testing
- [ ] All 8 unit tests passing
- [ ] All 4 integration tests passing
- [ ] All 2 UI tests passing
- [ ] Build succeeds with zero warnings
- [ ] SwiftLint violations <10 warnings

---

## 🧪 Mock Implementations for Tests

The test examples above reference mock objects. Implement these using the same patterns from PHASE_1/2/3/4:

### MockExportDataUseCase

**File:** `CraveyTests/Mocks/MockExportDataUseCase.swift` (CREATE THIS)

```swift
import Foundation
@testable import Cravey

actor MockExportDataUseCase: ExportDataUseCase {
    private(set) var lastExecutedFormat: ExportFormat?
    private var resultURL: URL?

    func setResult(_ url: URL) {
        self.resultURL = url
    }

    func execute(format: ExportFormat) async throws -> URL {
        lastExecutedFormat = format

        guard let resultURL = resultURL else {
            // Return temp URL if no mock result set
            return FileManager.default.temporaryDirectory.appendingPathComponent("test_export.\(format.rawValue)")
        }

        return resultURL
    }
}
```

### MockDeleteAllDataUseCase

**File:** `CraveyTests/Mocks/MockDeleteAllDataUseCase.swift` (CREATE THIS)

```swift
import Foundation
@testable import Cravey

actor MockDeleteAllDataUseCase: DeleteAllDataUseCase {
    private(set) var executeCallCount = 0

    func execute() async throws {
        executeCallCount += 1
    }
}
```

**Usage in Tests:**

```swift
@Test("SettingsViewModel should export CSV")
@MainActor
func testExportCSV() async throws {
    let mockExportUseCase = MockExportDataUseCase()
    let mockDeleteUseCase = MockDeleteAllDataUseCase()

    // Seed mock result
    let testURL = FileManager.default.temporaryDirectory.appendingPathComponent("test.csv")
    await mockExportUseCase.setResult(testURL)

    let viewModel = SettingsViewModel(
        exportDataUseCase: mockExportUseCase,
        deleteAllDataUseCase: mockDeleteUseCase
    )

    await viewModel.exportData(format: .csv)

    #expect(viewModel.exportedFileURL == testURL)
    let lastFormat = await mockExportUseCase.lastExecutedFormat
    #expect(lastFormat == .csv)
}
```

---

## 📊 Dependencies Validation

### From PHASE_1 (Craving Logging):
- ✅ `CravingEntity` exists
- ✅ `CravingRepositoryProtocol.fetchAll()` method exists (verified in baseline)
- ✅ `CravingRepositoryProtocol.delete(id:)` method exists
- ✅ `CravingRepository` implementation exists

### From PHASE_2 (Usage Logging):
- ⚠️ `UsageEntity` must exist
- ⚠️ `UsageRepositoryProtocol.fetchAll()` method must exist (same signature as CravingRepositoryProtocol)
- ⚠️ `UsageRepositoryProtocol.delete(id:)` method must exist
- ⚠️ `UsageRepository` implementation must exist

### From Baseline (Recordings - Stub):
- ⚠️ `RecordingEntity` exists (baseline)
- ⚠️ `RecordingRepositoryProtocol.fetchAll()` method exists (stub)
- ⚠️ `RecordingRepositoryProtocol.delete(id:)` method exists (stub)
- ⚠️ `RecordingRepository` stub exists (PHASE_4 replaces with real implementation)

**Action Required:**
1. ✅ **PHASE_1 must be complete** before starting this phase (CravingRepository needed for export/delete)
2. ✅ **PHASE_2 must be complete** before starting this phase (UsageRepository needed for export/delete)
3. ⚠️ **RecordingRepository stub is OK** - Export/delete will work with stub (returns empty array), real implementation comes in PHASE_4

**Note:** Export functionality will work even if PHASE_4 (Recordings) is not complete - it will simply export empty recordings array from stub repository.

---

## 🔄 Integration with Existing App

### Tab Bar Integration (PHASE_1 already has tab bar shell)

**File:** `Cravey/Presentation/Views/Home/HomeView.swift` (MODIFY)

Add Settings tab to existing TabView:

```swift
// ADD to TabView in HomeView.swift:
SettingsView()
    .tabItem {
        Label("Settings", systemImage: "gearshape")
    }
```

**Why This Integration:**
- Tab bar shell already exists from PHASE_1
- Settings is 4th tab (Home, Dashboard, Recordings, Settings)
- Standard iOS app pattern

---

## 📝 Testing Implementation Examples

### Unit Test Example: ExportDataUseCaseTests.swift

**File:** `CraveyTests/Domain/UseCases/ExportDataUseCaseTests.swift`

```swift
import Testing
import Foundation
@testable import Cravey

@Suite("ExportDataUseCase Tests")
struct ExportDataUseCaseTests {

    @Test("Should generate CSV with all data types")
    func testExportCSV() async throws {
        // Given
        let mockCravingRepo = MockCravingRepository()
        let mockUsageRepo = MockUsageRepository()
        let mockRecordingRepo = MockRecordingRepository()

        // Seed test data
        let testCraving = CravingEntity(
            id: UUID(),
            timestamp: Date(),
            intensity: 7,
            triggers: ["Stress", "Boredom"],
            location: "Home",
            notes: "Test craving",
            wasManagedSuccessfully: true
        )
        await mockCravingRepo.seed([testCraving])

        let testUsage = UsageEntity(
            id: UUID(),
            timestamp: Date(),
            roa: "Smoke",
            amount: "1 bowl",
            triggers: ["Social"],
            location: "Party",
            notes: "Test usage"
        )
        await mockUsageRepo.seed([testUsage])

        let useCase = DefaultExportDataUseCase(
            cravingRepository: mockCravingRepo,
            usageRepository: mockUsageRepo,
            recordingRepository: mockRecordingRepo
        )

        // When
        let fileURL = try await useCase.execute(format: .csv)

        // Then
        #expect(FileManager.default.fileExists(atPath: fileURL.path))

        let csvContent = try String(contentsOf: fileURL, encoding: .utf8)
        #expect(csvContent.contains("CRAVINGS"))
        #expect(csvContent.contains("USAGE LOGS"))
        #expect(csvContent.contains("RECORDINGS"))
        #expect(csvContent.contains("Test craving"))
        #expect(csvContent.contains("Test usage"))

        // Cleanup
        try FileManager.default.removeItem(at: fileURL)
    }

    @Test("Should generate JSON with metadata")
    func testExportJSON() async throws {
        // Given
        let mockCravingRepo = MockCravingRepository()
        let mockUsageRepo = MockUsageRepository()
        let mockRecordingRepo = MockRecordingRepository()

        let useCase = DefaultExportDataUseCase(
            cravingRepository: mockCravingRepo,
            usageRepository: mockUsageRepo,
            recordingRepository: mockRecordingRepo
        )

        // When
        let fileURL = try await useCase.execute(format: .json)

        // Then
        let jsonData = try Data(contentsOf: fileURL)
        let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]

        #expect(json?["version"] as? String == "1.0")
        #expect(json?["exportDate"] != nil)
        #expect(json?["cravings"] != nil)
        #expect(json?["usageLogs"] != nil)
        #expect(json?["recordings"] != nil)

        // Cleanup
        try FileManager.default.removeItem(at: fileURL)
    }
}
```

### Unit Test Example: DeleteAllDataUseCaseTests.swift

**File:** `CraveyTests/Domain/UseCases/DeleteAllDataUseCaseTests.swift`

```swift
import Testing
import Foundation
@testable import Cravey

@Suite("DeleteAllDataUseCase Tests")
struct DeleteAllDataUseCaseTests {

    @Test("Should delete all data from repositories")
    func testDeleteAllData() async throws {
        // Given
        let mockCravingRepo = MockCravingRepository()
        let mockUsageRepo = MockUsageRepository()
        let mockRecordingRepo = MockRecordingRepository()

        // Seed test data
        await mockCravingRepo.seed([
            CravingEntity(id: UUID(), timestamp: Date(), intensity: 5, triggers: [], location: nil, notes: nil, wasManagedSuccessfully: false)
        ])
        await mockUsageRepo.seed([
            UsageEntity(id: UUID(), timestamp: Date(), roa: "Smoke", amount: nil, triggers: [], location: nil, notes: nil)
        ])

        let useCase = DefaultDeleteAllDataUseCase(
            cravingRepository: mockCravingRepo,
            usageRepository: mockUsageRepo,
            recordingRepository: mockRecordingRepo
        )

        // When
        try await useCase.execute()

        // Then
        let cravingsCount = try await mockCravingRepo.count()
        let usageCount = try await mockUsageRepo.count()

        #expect(cravingsCount == 0)
        #expect(usageCount == 0)
    }
}
```

### Integration Test Example: OnboardingIntegrationTests.swift

**File:** `CraveyTests/Integration/OnboardingIntegrationTests.swift`

```swift
import Testing
import SwiftUI
@testable import Cravey

@Suite("Onboarding Integration Tests")
struct OnboardingIntegrationTests {

    @Test("Onboarding should only show on first launch")
    @MainActor
    func testOnboardingFirstLaunch() async throws {
        // Reset UserDefaults
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")

        // First launch - should show onboarding
        let hasCompleted1 = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        #expect(hasCompleted1 == false)

        // Complete onboarding
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        // Second launch - should not show onboarding
        let hasCompleted2 = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        #expect(hasCompleted2 == true)
    }
}
```

---

## 📦 Summary

**Phase 3 delivers onboarding + data management** that:
- ✅ Onboards users in <60 seconds (Welcome → Tour → Home)
- ✅ Exports all data (CSV for spreadsheets, JSON for developers)
- ✅ Deletes all data atomically (database + files)
- ✅ Shows Settings UI with clear data management options
- ✅ Uses iOS Share Sheet for native export experience
- ✅ Requires destructive confirmation for delete
- ✅ Follows Clean Architecture (Domain → Presentation)
- ✅ Uses established DI patterns from PHASE_1/2/3/4
- ✅ Builds on existing repository APIs (fetchAll, delete)
- ✅ Handles empty states gracefully (no data to export)
- ✅ Includes comprehensive mock implementations for testing

**Files Created:** 8 files (2 Use Cases + 1 ViewModel + 5 Views)
**Tests:** 14 tests (8 unit + 4 integration + 2 UI) with complete mock guidance
**Duration:** 2 weeks (Weeks 3-4)
**Dependencies:** Phases 1-2 complete (requires CravingRepository + UsageRepository)

**Next Phase:** PHASE_4 (Weeks 5-6) - Recordings (audio/video recording + playback)

---

**[← Back to Overview](./PHASE_OVERVIEW.md)** | **[← Phase 2 (Usage Logging)](./PHASE_2.md)** | **[Phase 4 (Recordings) →](./PHASE_4.md)**
