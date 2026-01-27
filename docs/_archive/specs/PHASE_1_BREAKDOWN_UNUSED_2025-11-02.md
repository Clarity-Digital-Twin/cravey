# Phase 1: Systematic Breakdown & TDD Implementation Plan

> ⚠️ Archived: Historical planning doc. Not current SSOT.

**Date:** 2025-11-02
**Approach:** Chunk-wise validation → TDD → Forward progress (no patching)
**Status:** 🎯 Ready for systematic implementation

---

## 🎯 Strategy Overview

Instead of "build fast, fix later," we'll:

1. **Break Phase 1 into atomic chunks** (A, B, C, D...)
2. **Validate each chunk against ALL specs** (PHASE_1, CLINICAL, DATA_MODEL, MVP)
3. **Write tests FIRST** (TDD - Red → Green → Refactor)
4. **Implement chunk-by-chunk** (working software after each chunk)
5. **No drift** (spec is source of truth, not our intuition)

---

## 📊 Phase 1 Chunk Map

```
PHASE 1: CRAVING LOGGING MVP
│
├─ CHUNK A: Data Layer (Foundation)
│  ├─ A1: CravingModel (SwiftData @Model)
│  ├─ A2: CravingEntity (Domain)
│  ├─ A3: CravingMapper (Entity ↔ Model)
│  └─ A4: CravingRepository (CRUD operations)
│
├─ CHUNK B: Business Logic (Use Cases)
│  ├─ B1: LogCravingUseCase (validation + save)
│  └─ B2: FetchCravingsUseCase (query + sort)
│
├─ CHUNK C: UI Components (Reusable)
│  ├─ C1: IntensitySlider (1-10 scale with emoji)
│  ├─ C2: TimestampPicker (backdating + validation)
│  ├─ C3: TriggerChipSelector (HAALT multi-select)
│  ├─ C4: LocationChipSelector (GPS + presets)
│  └─ C5: NotesField (500 char limit + counter)
│
├─ CHUNK D: ViewModels (State Management)
│  ├─ D1: CravingLogViewModel (form state + validation)
│  └─ D2: CravingListViewModel (fetch + display)
│
├─ CHUNK E: Views (User Interface)
│  ├─ E1: CravingLogForm (sheet with all components)
│  ├─ E2: CravingListView (list + empty state)
│  └─ E3: HomeView (tab + sheet integration)
│
└─ CHUNK F: Integration & Polish
   ├─ F1: End-to-end integration tests
   ├─ F2: UI/UX polish (animations, haptics)
   └─ F3: Performance validation (<5 sec logging)
```

---

## 🔬 CHUNK A: Data Layer (Foundation)

### A1: CravingModel (SwiftData @Model)

**Scope:** Persistent storage model

**Spec References:**
- `DATA_MODEL_SPEC.md` lines 247-305 (CravingModel definition)
- `CLINICAL_CANNABIS_SPEC.md` lines 185-209 (Craving logging flow)
- `MVP_PRODUCT_SPEC.md` lines 108-142 (Feature #1: Craving Logging)

**Exact Spec Requirements:**

| Field | Type | Required | Spec Location |
|-------|------|----------|---------------|
| `id` | `UUID` (@Attribute.unique) | Yes | DATA_MODEL_SPEC.md:266 |
| `timestamp` | `Date` | Yes | DATA_MODEL_SPEC.md:269 |
| `intensity` | `Int` (1-10) | Yes | DATA_MODEL_SPEC.md:270 |
| `triggers` | `[String]` | No (empty array) | DATA_MODEL_SPEC.md:273 |
| `location` | `String?` | No (nil) | DATA_MODEL_SPEC.md:274 |
| `notes` | `String?` | No (nil) | DATA_MODEL_SPEC.md:275 |
| `createdAt` | `Date` | Yes | DATA_MODEL_SPEC.md:278 |
| `modifiedAt` | `Date?` | No (nil) | DATA_MODEL_SPEC.md:279 |
| `recording` | `RecordingModel?` | No (nil) | DATA_MODEL_SPEC.md:282-283 |

**Relationship:**
```swift
@Relationship(deleteRule: .nullify, inverse: \RecordingModel.linkedCravings)
var recording: RecordingModel?  // Many-to-one (optional)
```

**VALIDATION CHECKLIST:**
- [ ] All 9 fields present (no extra, no missing)
- [ ] `id` has `@Attribute(.unique)`
- [ ] `timestamp` defaults to `Date()` in init
- [ ] `intensity` is `Int` (not `Double`)
- [ ] `triggers` defaults to `[]` (not nil)
- [ ] `createdAt` set to `Date()` in init
- [ ] `modifiedAt` defaults to `nil` in init
- [ ] Relationship uses `.nullify` (NOT `.cascade`)
- [ ] Relationship is `RecordingModel?` (NOT `[RecordingModel]`)
- [ ] NO fields beyond spec (no `duration`, no `managementStrategy`, no `wasManagedSuccessfully`)

**TDD Approach:**

**Test 1 (RED):**
```swift
@Test("CravingModel should initialize with required fields")
func testCravingModelInit() throws {
    let model = CravingModel(
        timestamp: Date(),
        intensity: 7,
        triggers: ["Anxious", "Bored"],
        location: "Home",
        notes: "Test note"
    )

    #expect(model.id != UUID()) // Auto-generated
    #expect(model.intensity == 7)
    #expect(model.triggers == ["Anxious", "Bored"])
    #expect(model.location == "Home")
    #expect(model.notes == "Test note")
    #expect(model.createdAt != nil)
    #expect(model.modifiedAt == nil)
    #expect(model.recording == nil)
}
```

**Test 2 (RED):**
```swift
@Test("CravingModel should persist and fetch from SwiftData")
func testCravingModelPersistence() async throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
        for: CravingModel.self,
        configurations: config
    )
    let context = ModelContext(container)

    // Insert
    let craving = CravingModel(
        timestamp: Date(),
        intensity: 5,
        triggers: ["Tired"],
        location: nil,
        notes: nil
    )
    context.insert(craving)
    try context.save()

    // Fetch
    let descriptor = FetchDescriptor<CravingModel>()
    let results = try context.fetch(descriptor)

    #expect(results.count == 1)
    #expect(results[0].intensity == 5)
    #expect(results[0].triggers == ["Tired"])
}
```

**Implementation (GREEN):**
```swift
// Cravey/Data/Models/CravingModel.swift

import Foundation
import SwiftData

@Model
final class CravingModel {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var intensity: Int
    var triggers: [String]
    var location: String?
    var notes: String?
    var createdAt: Date
    var modifiedAt: Date?

    @Relationship(deleteRule: .nullify, inverse: \RecordingModel.linkedCravings)
    var recording: RecordingModel?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        intensity: Int,
        triggers: [String] = [],
        location: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.intensity = intensity
        self.triggers = triggers
        self.location = location
        self.notes = notes
        self.createdAt = Date()
        self.modifiedAt = nil
        self.recording = nil
    }
}
```

**Commit:** `[Phase 1 - Chunk A1] Add CravingModel (spec-aligned, TDD)`

---

### A2: CravingEntity (Domain)

**Scope:** Pure Swift domain model (framework-independent)

**Spec References:**
- Domain layer should **mirror** Data layer (Clean Architecture principle)
- All fields from CravingModel must exist in CravingEntity
- Entity should be `Codable`, `Equatable`, `Hashable`, `Identifiable`

**Exact Spec Requirements:**

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `id` | `UUID` | Yes | Identifiable |
| `timestamp` | `Date` | Yes | When craving occurred |
| `intensity` | `Int` (1-10) | Yes | 1-3 mild, 4-6 moderate, 7-10 strong |
| `triggers` | `[String]` | Yes (empty OK) | HAALT multi-select |
| `location` | `String?` | Yes | GPS coordinate OR preset |
| `notes` | `String?` | Yes | Freeform text |
| `createdAt` | `Date` | Yes | Record creation time |
| `modifiedAt` | `Date?` | Yes | Last edit time |

**Business Logic:**
```swift
extension CravingEntity {
    enum IntensityLevel {
        case mild       // 1-3
        case moderate   // 4-6
        case strong     // 7-10
    }

    var intensityLevel: IntensityLevel {
        switch intensity {
        case 1...3: return .mild
        case 4...6: return .moderate
        case 7...10: return .strong
        default: return .mild
        }
    }
}
```

**VALIDATION CHECKLIST:**
- [ ] All 8 fields present (match CravingModel exactly, minus `recording`)
- [ ] Conforms to `Identifiable, Codable, Equatable, Hashable`
- [ ] NO SwiftData imports (pure Swift)
- [ ] NO extra fields (no `duration`, no `managementStrategy`, no `wasManagedSuccessfully`)
- [ ] Business logic in extension (intensityLevel computed property)

**TDD Approach:**

**Test 1 (RED):**
```swift
@Test("CravingEntity should categorize intensity correctly")
func testIntensityLevels() {
    let mild = CravingEntity(timestamp: Date(), intensity: 2, triggers: [], location: nil, notes: nil)
    let moderate = CravingEntity(timestamp: Date(), intensity: 5, triggers: [], location: nil, notes: nil)
    let strong = CravingEntity(timestamp: Date(), intensity: 9, triggers: [], location: nil, notes: nil)

    #expect(mild.intensityLevel == .mild)
    #expect(moderate.intensityLevel == .moderate)
    #expect(strong.intensityLevel == .strong)
}
```

**Test 2 (RED):**
```swift
@Test("CravingEntity should be Codable")
func testCodable() throws {
    let entity = CravingEntity(
        timestamp: Date(),
        intensity: 7,
        triggers: ["Anxious", "Bored"],
        location: "Home",
        notes: "Test"
    )

    let encoded = try JSONEncoder().encode(entity)
    let decoded = try JSONDecoder().decode(CravingEntity.self, from: encoded)

    #expect(decoded.intensity == 7)
    #expect(decoded.triggers == ["Anxious", "Bored"])
}
```

**Implementation (GREEN):**
```swift
// Cravey/Domain/Entities/CravingEntity.swift

import Foundation

struct CravingEntity: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let timestamp: Date
    let intensity: Int
    let triggers: [String]
    let location: String?
    let notes: String?
    let createdAt: Date
    let modifiedAt: Date?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        intensity: Int,
        triggers: [String] = [],
        location: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        modifiedAt: Date? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.intensity = intensity
        self.triggers = triggers
        self.location = location
        self.notes = notes
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

// MARK: - Business Logic

extension CravingEntity {
    enum IntensityLevel {
        case mild       // 1-3
        case moderate   // 4-6
        case strong     // 7-10
    }

    var intensityLevel: IntensityLevel {
        switch intensity {
        case 1...3: return .mild
        case 4...6: return .moderate
        case 7...10: return .strong
        default: return .mild
        }
    }
}
```

**Commit:** `[Phase 1 - Chunk A2] Add CravingEntity (spec-aligned, TDD)`

---

### A3: CravingMapper (Entity ↔ Model)

**Scope:** Bidirectional conversion between Domain and Data layers

**Spec References:**
- Clean Architecture: Domain layer must not import SwiftData
- Mapper handles all field transformations
- Mapper is PURE FUNCTION (no side effects)

**Exact Spec Requirements:**

```swift
struct CravingMapper {
    // Convert Entity → Model (for saving)
    static func toModel(_ entity: CravingEntity) -> CravingModel

    // Convert Model → Entity (for fetching)
    static func toEntity(_ model: CravingModel) -> CravingEntity
}
```

**VALIDATION CHECKLIST:**
- [ ] `toModel` converts all 8 fields correctly
- [ ] `toEntity` converts all 8 fields correctly
- [ ] No field loss (round-trip conversion preserves data)
- [ ] No SwiftData imports in Domain (mapper is in Data layer)
- [ ] Pure functions (no state, no side effects)

**TDD Approach:**

**Test 1 (RED):**
```swift
@Test("Mapper should convert Entity → Model correctly")
func testEntityToModel() {
    let entity = CravingEntity(
        timestamp: Date(),
        intensity: 7,
        triggers: ["Anxious", "Bored"],
        location: "Home",
        notes: "Test"
    )

    let model = CravingMapper.toModel(entity)

    #expect(model.id == entity.id)
    #expect(model.intensity == 7)
    #expect(model.triggers == ["Anxious", "Bored"])
    #expect(model.location == "Home")
    #expect(model.notes == "Test")
}
```

**Test 2 (RED):**
```swift
@Test("Mapper should round-trip Entity → Model → Entity")
func testRoundTrip() {
    let original = CravingEntity(
        timestamp: Date(),
        intensity: 5,
        triggers: ["Tired"],
        location: nil,
        notes: nil
    )

    let model = CravingMapper.toModel(original)
    let converted = CravingMapper.toEntity(model)

    #expect(converted.id == original.id)
    #expect(converted.intensity == original.intensity)
    #expect(converted.triggers == original.triggers)
}
```

**Implementation (GREEN):**
```swift
// Cravey/Data/Mappers/CravingMapper.swift

import Foundation

struct CravingMapper {
    static func toModel(_ entity: CravingEntity) -> CravingModel {
        CravingModel(
            id: entity.id,
            timestamp: entity.timestamp,
            intensity: entity.intensity,
            triggers: entity.triggers,
            location: entity.location,
            notes: entity.notes
        )
    }

    static func toEntity(_ model: CravingModel) -> CravingEntity {
        CravingEntity(
            id: model.id,
            timestamp: model.timestamp,
            intensity: model.intensity,
            triggers: model.triggers,
            location: model.location,
            notes: model.notes,
            createdAt: model.createdAt,
            modifiedAt: model.modifiedAt
        )
    }
}
```

**Commit:** `[Phase 1 - Chunk A3] Add CravingMapper (spec-aligned, TDD)`

---

### A4: CravingRepository (CRUD Operations)

**Scope:** Concrete implementation of CravingRepositoryProtocol

**Spec References:**
- Domain defines protocol (interface)
- Data implements protocol (concrete class)
- Uses ModelContext for SwiftData operations

**Protocol (Already Exists):**
```swift
// Cravey/Domain/Repositories/CravingRepositoryProtocol.swift
protocol CravingRepositoryProtocol: Sendable {
    func save(_ craving: CravingEntity) async throws -> CravingEntity
    func fetchAll() async throws -> [CravingEntity]
    func delete(_ id: UUID) async throws
}
```

**VALIDATION CHECKLIST:**
- [ ] Implements CravingRepositoryProtocol
- [ ] Uses CravingMapper for all Entity ↔ Model conversions
- [ ] Uses ModelContext for SwiftData operations
- [ ] Handles errors gracefully
- [ ] Thread-safe (uses `nonisolated(unsafe)` for ModelContext)

**TDD Approach:**

**Test 1 (RED):**
```swift
@Test("Repository should save and fetch craving")
func testSaveAndFetch() async throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
        for: CravingModel.self,
        configurations: config
    )
    let context = ModelContext(container)
    let repository = CravingRepository(modelContext: context)

    // Save
    let entity = CravingEntity(
        timestamp: Date(),
        intensity: 7,
        triggers: ["Anxious"],
        location: "Home",
        notes: "Test"
    )
    let saved = try await repository.save(entity)

    // Fetch
    let results = try await repository.fetchAll()

    #expect(results.count == 1)
    #expect(results[0].intensity == 7)
    #expect(results[0].triggers == ["Anxious"])
}
```

**Test 2 (RED):**
```swift
@Test("Repository should delete craving by ID")
func testDelete() async throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
        for: CravingModel.self,
        configurations: config
    )
    let context = ModelContext(container)
    let repository = CravingRepository(modelContext: context)

    // Save
    let entity = CravingEntity(timestamp: Date(), intensity: 5, triggers: [], location: nil, notes: nil)
    let saved = try await repository.save(entity)

    // Delete
    try await repository.delete(saved.id)

    // Verify
    let results = try await repository.fetchAll()
    #expect(results.isEmpty)
}
```

**Implementation (GREEN):**
```swift
// Cravey/Data/Repositories/CravingRepository.swift

import Foundation
import SwiftData

final class CravingRepository: CravingRepositoryProtocol {
    nonisolated(unsafe) private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ craving: CravingEntity) async throws -> CravingEntity {
        let model = CravingMapper.toModel(craving)
        modelContext.insert(model)
        try modelContext.save()
        return CravingMapper.toEntity(model)
    }

    func fetchAll() async throws -> [CravingEntity] {
        let descriptor = FetchDescriptor<CravingModel>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let models = try modelContext.fetch(descriptor)
        return models.map { CravingMapper.toEntity($0) }
    }

    func delete(_ id: UUID) async throws {
        let descriptor = FetchDescriptor<CravingModel>(
            predicate: #Predicate { $0.id == id }
        )
        let models = try modelContext.fetch(descriptor)
        guard let model = models.first else {
            throw RepositoryError.notFound
        }
        modelContext.delete(model)
        try modelContext.save()
    }
}

enum RepositoryError: Error {
    case notFound
}
```

**Commit:** `[Phase 1 - Chunk A4] Add CravingRepository (spec-aligned, TDD)`

---

## 🎯 Chunk A Complete Checklist

After implementing A1-A4, validate:

- [ ] All tests passing (8 tests total: 2 per chunk)
- [ ] CravingModel has exactly 9 fields (no drift)
- [ ] CravingEntity mirrors CravingModel (minus `recording`)
- [ ] CravingMapper round-trips data correctly
- [ ] CravingRepository saves/fetches/deletes correctly
- [ ] Zero SwiftData imports in Domain layer
- [ ] Build succeeds with zero warnings

**Commit:** `[Phase 1 - Chunk A] Complete Data Layer (4/4 components, 8/8 tests passing)`

---

## 🔬 CHUNK B: Business Logic (Use Cases)

### B1: LogCravingUseCase (Validation + Save)

**Scope:** Business logic for logging a craving

**Spec References:**
- `MVP_PRODUCT_SPEC.md` lines 108-142 (Feature #1: Craving Logging)
- Validates intensity (1-10 range)
- Accepts optional fields (triggers, location, notes)
- Returns saved CravingEntity

**Protocol (Already Exists):**
```swift
// Cravey/Domain/UseCases/LogCravingUseCase.swift
protocol LogCravingUseCase: Sendable {
    func execute(
        intensity: Int,
        triggers: [String],
        notes: String?,
        location: String?,
        timestamp: Date
    ) async throws -> CravingEntity
}
```

**Validation Logic:**
- `intensity` must be 1-10 (throw error if out of range)
- `triggers` can be empty array
- `notes` can be nil OR ≤500 characters (enforce in ViewModel, not UseCase)
- `location` can be nil OR valid preset/GPS
- `timestamp` can be any past date (warning if >7 days enforced in ViewModel)

**VALIDATION CHECKLIST:**
- [ ] Validates intensity (1-10 range, throws error otherwise)
- [ ] Accepts all optional fields
- [ ] Calls repository.save()
- [ ] Returns saved CravingEntity
- [ ] No UI logic (no alerts, no state management)

**TDD Approach:**

**Test 1 (RED):**
```swift
@Test("LogCravingUseCase should save valid craving")
func testLogValidCraving() async throws {
    let repository = MockCravingRepository()
    let useCase = DefaultLogCravingUseCase(repository: repository)

    let result = try await useCase.execute(
        intensity: 7,
        triggers: ["Anxious", "Bored"],
        notes: "Test note",
        location: "Home",
        timestamp: Date()
    )

    #expect(result.intensity == 7)
    #expect(result.triggers == ["Anxious", "Bored"])

    let count = await repository.count()
    #expect(count == 1)
}
```

**Test 2 (RED):**
```swift
@Test("LogCravingUseCase should reject invalid intensity")
func testInvalidIntensity() async throws {
    let repository = MockCravingRepository()
    let useCase = DefaultLogCravingUseCase(repository: repository)

    await #expect(throws: UseCaseError.invalidIntensity) {
        try await useCase.execute(
            intensity: 11,  // Out of range
            triggers: [],
            notes: nil,
            location: nil,
            timestamp: Date()
        )
    }
}
```

**Implementation (GREEN):**
```swift
// Cravey/Domain/UseCases/LogCravingUseCase.swift

import Foundation

protocol LogCravingUseCase: Sendable {
    func execute(
        intensity: Int,
        triggers: [String],
        notes: String?,
        location: String?,
        timestamp: Date
    ) async throws -> CravingEntity
}

final class DefaultLogCravingUseCase: LogCravingUseCase {
    private let repository: CravingRepositoryProtocol

    init(repository: CravingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        intensity: Int,
        triggers: [String],
        notes: String?,
        location: String?,
        timestamp: Date
    ) async throws -> CravingEntity {
        // Validation
        guard (1...10).contains(intensity) else {
            throw UseCaseError.invalidIntensity
        }

        // Create entity
        let craving = CravingEntity(
            timestamp: timestamp,
            intensity: intensity,
            triggers: triggers,
            location: location,
            notes: notes
        )

        // Save
        return try await repository.save(craving)
    }
}

enum UseCaseError: Error {
    case invalidIntensity
}
```

**Commit:** `[Phase 1 - Chunk B1] Add LogCravingUseCase (spec-aligned, TDD)`

---

### B2: FetchCravingsUseCase (Query + Sort)

**Scope:** Fetch all cravings, sorted by timestamp (newest first)

**Protocol (Already Exists):**
```swift
// Cravey/Domain/UseCases/FetchCravingsUseCase.swift
protocol FetchCravingsUseCase: Sendable {
    func execute() async throws -> [CravingEntity]
}
```

**VALIDATION CHECKLIST:**
- [ ] Calls repository.fetchAll()
- [ ] Returns cravings sorted by timestamp (newest first)
- [ ] No filtering logic (simple fetch all)

**TDD Approach:**

**Test 1 (RED):**
```swift
@Test("FetchCravingsUseCase should return all cravings sorted")
func testFetchAll() async throws {
    let repository = MockCravingRepository()

    // Insert 3 cravings
    _ = try await repository.save(CravingEntity(timestamp: Date().addingTimeInterval(-100), intensity: 5, triggers: [], location: nil, notes: nil))
    _ = try await repository.save(CravingEntity(timestamp: Date(), intensity: 7, triggers: [], location: nil, notes: nil))
    _ = try await repository.save(CravingEntity(timestamp: Date().addingTimeInterval(-200), intensity: 3, triggers: [], location: nil, notes: nil))

    let useCase = DefaultFetchCravingsUseCase(repository: repository)
    let results = try await useCase.execute()

    #expect(results.count == 3)
    // Newest first
    #expect(results[0].intensity == 7)
    #expect(results[1].intensity == 5)
    #expect(results[2].intensity == 3)
}
```

**Implementation (GREEN):**
```swift
// Cravey/Domain/UseCases/FetchCravingsUseCase.swift

import Foundation

protocol FetchCravingsUseCase: Sendable {
    func execute() async throws -> [CravingEntity]
}

final class DefaultFetchCravingsUseCase: FetchCravingsUseCase {
    private let repository: CravingRepositoryProtocol

    init(repository: CravingRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [CravingEntity] {
        try await repository.fetchAll()
    }
}
```

**Commit:** `[Phase 1 - Chunk B2] Add FetchCravingsUseCase (spec-aligned, TDD)`

---

## 🎯 Chunk B Complete Checklist

- [ ] All tests passing (3 tests total: 2 for LogCravingUseCase, 1 for FetchCravingsUseCase)
- [ ] LogCravingUseCase validates intensity (1-10)
- [ ] FetchCravingsUseCase returns sorted cravings
- [ ] Build succeeds with zero warnings

**Commit:** `[Phase 1 - Chunk B] Complete Business Logic (2/2 use cases, 3/3 tests passing)`

---

## 🎨 CHUNK C: UI Components (Reusable)

### C1: IntensitySlider (1-10 Scale with Emoji)

**Scope:** Reusable intensity slider component

**Spec References:**
- `PHASE_1.md` lines 364-370, 834-928 (IntensitySlider spec)
- `CLINICAL_CANNABIS_SPEC.md` lines 165-175 (Craving intensity scale)
- 1-10 slider with emoji feedback
- Clinical ranges: 1-3 mild, 4-6 moderate, 7-10 strong

**Exact Spec Requirements:**

```swift
struct IntensitySlider: View {
    @Binding var value: Double

    var body: some View {
        // Slider 1-10 with emoji feedback
    }

    // Testable static methods
    static func formatLabel(for intensity: Int) -> String
    static func emoji(for intensity: Int) -> String
}
```

**Emoji Mapping:**
- 1-2: 😌 "Very Mild"
- 3-4: 🙂 "Mild"
- 5-6: 😐 "Moderate"
- 7-8: 😟 "Strong"
- 9-10: 😫 "Overwhelming"

**VALIDATION CHECKLIST:**
- [ ] Slider range 1-10 (step 1)
- [ ] Emoji updates dynamically
- [ ] Label shows intensity + description
- [ ] `formatLabel()` and `emoji()` are static (testable)

**TDD Approach:**

**Test 1 (RED):**
```swift
@Test("IntensitySlider should format labels correctly")
func testIntensityLabels() {
    #expect(IntensitySlider.formatLabel(for: 1) == "1 - Very Mild")
    #expect(IntensitySlider.formatLabel(for: 5) == "5 - Moderate")
    #expect(IntensitySlider.formatLabel(for: 10) == "10 - Overwhelming")
}
```

**Test 2 (RED):**
```swift
@Test("IntensitySlider should return correct emojis")
func testIntensityEmojis() {
    #expect(IntensitySlider.emoji(for: 1) == "😌")
    #expect(IntensitySlider.emoji(for: 5) == "😐")
    #expect(IntensitySlider.emoji(for: 10) == "😫")
}
```

**Implementation (GREEN):**
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

**Commit:** `[Phase 1 - Chunk C1] Add IntensitySlider (spec-aligned, TDD)`

---

### C2: TimestampPicker (Backdating + Validation)

**Scope:** Date/time picker with backdating support

**Spec References:**
- `PHASE_1.md` lines 371-378, 944-971 (TimestampPicker spec)
- `CLINICAL_CANNABIS_SPEC.md` line 190 ("Auto 'now', editable to any past date/time with warning if >7 days")
- Defaults to "Now" (Date())
- Allows backdating (up to 7 days without warning, >7 days shows warning)

**Exact Spec Requirements:**

```swift
struct TimestampPicker: View {
    @Binding var date: Date
    @Binding var showWarning: Bool  // Set to true if >7 days ago

    var body: some View {
        // DatePicker with validation
    }
}
```

**Warning Trigger:**
- If selected date is >7 days ago → `showWarning = true`
- ViewModel displays warning banner: "⚠️ This craving is more than a week old. Are you sure?"

**VALIDATION CHECKLIST:**
- [ ] DatePicker allows any past date
- [ ] Disallows future dates (`.in ...Date()`)
- [ ] Defaults to Date() (current time)
- [ ] Sets `showWarning` binding if >7 days

**TDD Approach:**

**Test 1 (RED):**
```swift
@Test("TimestampPicker should detect old timestamps")
func testOldTimestampWarning() {
    let eightDaysAgo = Calendar.current.date(byAdding: .day, value: -8, to: Date())!
    let warning = TimestampPicker.shouldWarn(for: eightDaysAgo)

    #expect(warning == true)
}
```

**Test 2 (RED):**
```swift
@Test("TimestampPicker should NOT warn for recent timestamps")
func testRecentTimestamp() {
    let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
    let warning = TimestampPicker.shouldWarn(for: fiveDaysAgo)

    #expect(warning == false)
}
```

**Implementation (GREEN):**
```swift
// Cravey/Presentation/Views/Components/TimestampPicker.swift

import SwiftUI

struct TimestampPicker: View {
    @Binding var date: Date
    @Binding var showWarning: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            DatePicker(
                "When did this happen?",
                selection: $date,
                in: ...Date(),  // Can't pick future dates
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .onChange(of: date) { _, newDate in
                showWarning = Self.shouldWarn(for: newDate)
            }

            if showWarning {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("This craving is more than a week old. Are you sure?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }

    // Testable static method
    static func shouldWarn(for date: Date) -> Bool {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return date < sevenDaysAgo
    }
}

#Preview {
    TimestampPicker(date: .constant(Date()), showWarning: .constant(false))
        .padding()
}
```

**Commit:** `[Phase 1 - Chunk C2] Add TimestampPicker (spec-aligned, TDD)`

---

*[Continue with C3-C5 and remaining chunks...]*

---

## 📏 Implementation Order (Dependencies)

```
A1 → A2 → A3 → A4 → B1 → B2 → C1 → C2 → C3 → C4 → C5 → D1 → D2 → E1 → E2 → E3 → F1 → F2 → F3
```

**Rationale:**
- Data layer first (foundation)
- Use cases depend on repositories
- Components are independent (can parallelize)
- ViewModels depend on use cases
- Views depend on ViewModels + components
- Integration tests last

---

## ✅ Master Validation Checklist (After All Chunks)

**Data Layer (Chunk A):**
- [ ] CravingModel has exactly 9 fields (spec-aligned)
- [ ] CravingEntity mirrors CravingModel
- [ ] CravingMapper round-trips correctly
- [ ] CravingRepository saves/fetches/deletes
- [ ] 8/8 tests passing

**Business Logic (Chunk B):**
- [ ] LogCravingUseCase validates intensity
- [ ] FetchCravingsUseCase sorts by timestamp
- [ ] 3/3 tests passing

**UI Components (Chunk C):**
- [ ] IntensitySlider (1-10, emoji, labels)
- [ ] TimestampPicker (backdating, warning)
- [ ] TriggerChipSelector (HAALT, multi-select)
- [ ] LocationChipSelector (GPS + presets, single-select)
- [ ] NotesField (500 char limit, counter)
- [ ] 10/10 tests passing (2 per component)

**ViewModels (Chunk D):**
- [ ] CravingLogViewModel (form state, validation)
- [ ] CravingListViewModel (fetch, display)
- [ ] 4/4 tests passing

**Views (Chunk E):**
- [ ] CravingLogForm (sheet, all components)
- [ ] CravingListView (list, empty state)
- [ ] HomeView (tab, sheet integration)
- [ ] UI tests passing

**Integration (Chunk F):**
- [ ] End-to-end integration tests passing
- [ ] Performance <5 sec logging validated
- [ ] All polish complete

**Total Test Count:** 25+ tests passing

---

**Status:** Ready for chunk-by-chunk TDD implementation
**Next Step:** Start with Chunk A1 (CravingModel)
