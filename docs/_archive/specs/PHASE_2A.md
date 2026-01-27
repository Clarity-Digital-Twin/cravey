# Phase 2A: Usage Logging - Data Foundation

> ⚠️ Archived: Historical phase doc. Not current SSOT.

**Version:** 1.0 (Spec-First Approach)
**Duration:** Day 1 (Domain + Data layers only)
**Dependencies:** Phase 1 complete (CravingEntity pattern established)
**Status:** 📋 Ready to implement

---

## 🎯 Phase Goal

**Deliverable:** Complete Domain and Data layers for usage logging with **100% spec compliance** validated by integration tests.

**What We're Building:**
- UsageEntity (pure Swift domain model)
- UsageRepositoryProtocol (dependency inversion)
- LogUsageUseCase + FetchUsageUseCase (business logic)
- UsageMapper (Entity ↔ Model conversion)
- UsageRepository (SwiftData implementation)

**What We're NOT Building (Yet):**
- NO UI components
- NO ViewModels
- NO Forms

**Why This Approach:**
Phase 1 had 3 convergence passes because we built UI before validating data models against specs. This phase validates the data foundation FIRST with integration tests, BEFORE touching any UI.

---

## 📋 SPEC VALIDATION (Read Before Coding)

### Tier 1 Requirements

**Source: DATA_MODEL_SPEC.md lines 75-167**

#### UsageModel Field Requirements

| Field | Type | Required | Validation | Source Line |
|-------|------|----------|------------|-------------|
| `id` | `UUID` | ✅ Yes | `@Attribute(.unique)` | Line 116 |
| `timestamp` | `Date` | ✅ Yes | Any past date, warn if >7 days (UI only) | Line 117 |
| `method` | `String` | ✅ Yes | Must be one of 6 ROAs | Line 118 |
| `amount` | `Double` | ✅ Yes | Must be >0, range validated by method | Line 119 |
| `triggers` | `[String]` | ❌ No | HAALT set, empty array if none | Line 120 |
| `location` | `String?` | ❌ No | GPS coordinate OR preset name | Line 121 |
| `notes` | `String?` | ❌ No | ≤500 chars (enforced in UI, not DB) | Line 122 |
| `createdAt` | `Date` | ✅ Yes | Auto-set on init | Line 123 |
| `modifiedAt` | `Date?` | ❌ No | Auto-set on update | Line 124 |

#### ROA Method Validation

**Source: DATA_MODEL_SPEC.md lines 132-166 + CLINICAL_CANNABIS_SPEC.md lines 220-224**

Valid `method` values (case-sensitive):
```swift
["Bowls", "Joints", "Blunts", "Vape", "Dab", "Edible"]
```

#### Amount Range Validation (by ROA)

**Source: DATA_MODEL_SPEC.md lines 140-153**

| ROA | Min | Max | Increment | Options Count |
|-----|-----|-----|-----------|---------------|
| Bowls | 0.5 | 5.0 | 0.5 | 10 |
| Joints | 0.5 | 5.0 | 0.5 | 10 |
| Blunts | 0.5 | 5.0 | 0.5 | 10 |
| Vape | 1.0 | 10.0 | 1.0 | 10 |
| Dab | 1.0 | 5.0 | 1.0 | 5 |
| Edible | 5.0 | 100.0 | 5.0 | 20 |

#### Trigger Options (HAALT Model)

**Source: DATA_MODEL_SPEC.md lines 174-192 + CLINICAL_CANNABIS_SPEC.md lines 228-234**

**Primary (6 triggers):**
```swift
["Hungry", "Angry", "Anxious", "Lonely", "Tired", "Sad"]
```

**Secondary (4 triggers):**
```swift
["Bored", "Social", "Habit", "Paraphernalia"]
```

**Multi-select enabled:** Users can select 0-10 triggers

#### Location Options

**Source: DATA_MODEL_SPEC.md lines 198-221 + CLINICAL_CANNABIS_SPEC.md lines 231-233**

**Presets:**
```swift
["Home", "Work", "Social", "Outside", "Car"]
```

**GPS Format:** `"lat,long"` string (e.g., `"37.7749,-122.4194"`)

**Detection Logic:**
```swift
func isGPS(_ location: String) -> Bool {
    return location.contains(",")
}
```

---

## ✅ Acceptance Criteria (Definition of Done)

Before proceeding to Phase 2B, ALL of the following must be true:

### Code Completion
- [ ] UsageEntity created (pure Swift, no framework imports)
- [ ] UsageRepositoryProtocol created (Sendable protocol)
- [ ] LogUsageUseCase created (validates method + amount)
- [ ] FetchUsageUseCase created (fetches all + filtered by date)
- [ ] UsageMapper created (bidirectional Entity ↔ Model)
- [ ] UsageRepository created (SwiftData implementation)
- [ ] DependencyContainer updated (real UsageRepository, not stub)

### Validation Tests
- [ ] **Integration Test 1:** Log usage end-to-end (Domain → Data → SwiftData)
- [ ] **Integration Test 2:** Fetch usage from SwiftData via use case
- [ ] **Integration Test 3:** Validate all 6 ROAs with correct amount ranges
- [ ] **Integration Test 4:** Validate invalid method throws error
- [ ] **Integration Test 5:** Validate amount=0 throws error
- [ ] **Integration Test 6:** Validate triggers array accepts HAALT values
- [ ] All 6 integration tests passing ✅

### Spec Compliance
- [ ] UsageEntity matches DATA_MODEL_SPEC.md lines 75-124 (9 fields)
- [ ] ROA validation matches CLINICAL_CANNABIS_SPEC.md lines 220-224 (6 methods)
- [ ] Amount ranges match DATA_MODEL_SPEC.md lines 140-153 (6 ranges)
- [ ] Triggers match CLINICAL_CANNABIS_SPEC.md lines 228-234 (10 triggers)
- [ ] Location format matches DATA_MODEL_SPEC.md lines 198-221
- [ ] createdAt/modifiedAt auto-set (no manual timestamp bugs)

### Build Status
- [ ] Zero compilation errors
- [ ] Zero SwiftLint violations (except existing TODOs from Phase 1)
- [ ] All new files formatted with SwiftFormat

---

## 📝 Implementation Steps

### Step 1: Create UsageEntity (Domain Layer)

**File:** `Cravey/Domain/Entities/UsageEntity.swift`

**Spec Reference:** DATA_MODEL_SPEC.md lines 75-109

```swift
import Foundation

/// Pure Swift entity for usage tracking (no framework dependencies)
/// Source: DATA_MODEL_SPEC.md lines 75-124
struct UsageEntity: Equatable, Sendable, Identifiable {
    let id: UUID
    let timestamp: Date
    let method: String        // ROA: must be one of ["Bowls", "Joints", "Blunts", "Vape", "Dab", "Edible"]
    let amount: Double        // Must be >0, range validated by method
    let triggers: [String]    // HAALT triggers (0-10 items, validated in use case)
    let location: String?     // GPS "lat,long" OR preset name
    let notes: String?        // ≤500 chars (enforced in UI, not here)
    let createdAt: Date
    let modifiedAt: Date?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
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

**Checkpoint:** Build succeeds, no errors

---

### Step 2: Create UsageRepositoryProtocol (Domain Layer)

**File:** `Cravey/Domain/Repositories/UsageRepositoryProtocol.swift`

**Pattern:** Copy from CravingRepositoryProtocol, adjust for UsageEntity

```swift
import Foundation

/// Protocol for usage data operations (dependency inversion principle)
protocol UsageRepositoryProtocol: Sendable {
    /// Save a usage entity to persistent storage
    func save(_ usage: UsageEntity) async throws

    /// Fetch all usage entries (sorted by timestamp descending)
    func fetchAll() async throws -> [UsageEntity]

    /// Fetch usage entries since a specific date
    func fetch(since date: Date) async throws -> [UsageEntity]

    /// Delete a specific usage entry by ID
    func delete(id: UUID) async throws

    /// Delete all usage entries (PHASE_3: Data Management)
    func deleteAll() async throws
}
```

**Checkpoint:** Build succeeds, protocol compiles

---

### Step 3: Create ROA Validation Helper (Domain Layer)

**File:** `Cravey/Domain/UseCases/ROAAmountRange.swift` (NEW - reusable utility)

**Spec Reference:** DATA_MODEL_SPEC.md lines 132-166

```swift
import Foundation

/// ROA (Route of Administration) amount range validation
/// Source: DATA_MODEL_SPEC.md lines 140-153
enum ROAAmountRange {
    /// Valid ROA method names (case-sensitive)
    /// Source: CLINICAL_CANNABIS_SPEC.md lines 220-224
    static let validMethods = ["Bowls", "Joints", "Blunts", "Vape", "Dab", "Edible"]

    /// Get valid amount range for a given ROA method
    /// Returns empty array if method is invalid
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

    /// Check if amount is valid for given method
    static func isValid(method: String, amount: Double) -> Bool {
        return range(for: method).contains(amount)
    }

    /// Format amount for display (e.g., "2.5 bowls", "10mg")
    static func displayAmount(method: String, amount: Double) -> String {
        switch method {
        case "Bowls": return formatDecimal(amount) + " bowls"
        case "Joints": return formatDecimal(amount) + " joints"
        case "Blunts": return formatDecimal(amount) + " blunts"
        case "Vape": return "\(Int(amount)) pulls"
        case "Dab": return "\(Int(amount)) dabs"
        case "Edible": return "\(Int(amount))mg"
        default: return "\(amount)"
        }
    }

    /// Format decimal: 1.0 → "1", 2.5 → "2.5"
    private static func formatDecimal(_ value: Double) -> String {
        return value.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(value))"
            : "\(value)"
    }
}
```

**Checkpoint:** Build succeeds, helper compiles

---

### Step 4: Create LogUsageUseCase (Domain Layer)

**File:** `Cravey/Domain/UseCases/LogUsageUseCase.swift`

**Validation Rules (from specs):**
- `method` must be one of 6 valid ROAs (CLINICAL_CANNABIS_SPEC.md:220-224)
- `amount` must be >0 AND within valid range for method (DATA_MODEL_SPEC.md:140-153)
- `triggers` can be 0-10 items (validated but not enforced)

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

/// Default implementation with validation
final class DefaultLogUsageUseCase: LogUsageUseCase {
    private let repository: UsageRepositoryProtocol

    init(repository: UsageRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        timestamp: Date = Date(),
        method: String,
        amount: Double,
        triggers: [String] = [],
        location: String? = nil,
        notes: String? = nil
    ) async throws -> UsageEntity {
        // Validate method (must be one of 6 ROAs)
        guard ROAAmountRange.validMethods.contains(method) else {
            throw UsageError.invalidMethod
        }

        // Validate amount (must be >0)
        guard amount > 0 else {
            throw UsageError.invalidAmount
        }

        // Validate amount range for method
        guard ROAAmountRange.isValid(method: method, amount: amount) else {
            throw UsageError.amountOutOfRange
        }

        // Create entity
        let entity = UsageEntity(
            timestamp: timestamp,
            method: method,
            amount: amount,
            triggers: triggers,
            location: location,
            notes: notes
        )

        // Save to repository
        try await repository.save(entity)

        return entity
    }
}

/// Usage-specific errors
enum UsageError: LocalizedError {
    case invalidMethod
    case invalidAmount
    case amountOutOfRange
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .invalidMethod:
            return "Invalid method. Must be one of: Bowls, Joints, Blunts, Vape, Dab, Edible"
        case .invalidAmount:
            return "Amount must be greater than zero"
        case .amountOutOfRange:
            return "Amount is outside valid range for this method"
        case .saveFailed:
            return "Failed to save usage"
        }
    }
}
```

**Checkpoint:** Build succeeds, use case compiles

---

### Step 5: Create FetchUsageUseCase (Domain Layer)

**File:** `Cravey/Domain/UseCases/FetchUsageUseCase.swift`

**Pattern:** Copy from FetchCravingsUseCase, adjust for UsageEntity

```swift
import Foundation

/// Protocol for fetching usage history
protocol FetchUsageUseCase: Sendable {
    /// Fetch all usage entries (sorted by timestamp descending)
    func execute() async throws -> [UsageEntity]

    /// Fetch usage entries since a specific date
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

**Checkpoint:** Build succeeds, use case compiles

---

### Step 6: Create UsageMapper (Data Layer)

**File:** `Cravey/Data/Mappers/UsageMapper.swift`

**Pattern:** Copy from CravingMapper, adjust for UsageModel

**Important:** UsageModel already exists (created in Phase 1 Step 1)

```swift
import Foundation

/// Maps between UsageEntity (Domain) and UsageModel (SwiftData)
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
            notes: entity.notes,
            createdAt: entity.createdAt,
            modifiedAt: entity.modifiedAt
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

**Checkpoint:** Build succeeds, mapper compiles

---

### Step 7: Create UsageRepository (Data Layer)

**File:** `Cravey/Data/Repositories/UsageRepository.swift`

**Pattern:** Copy from CravingRepository, adjust for UsageModel

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

    func delete(id: UUID) async throws {
        let predicate = #Predicate<UsageModel> { usage in
            usage.id == id
        }
        let descriptor = FetchDescriptor<UsageModel>(predicate: predicate)
        let models = try modelContext.fetch(descriptor)

        guard let model = models.first else {
            throw UsageRepositoryError.notFound(id: id)
        }

        modelContext.delete(model)
        try modelContext.save()
    }

    func deleteAll() async throws {
        try modelContext.delete(model: UsageModel.self)
        try modelContext.save()
    }
}

enum UsageRepositoryError: Error {
    case notFound(id: UUID)
}
```

**Checkpoint:** Build succeeds, repository compiles

---

### Step 8: Update DependencyContainer

**Modify:** `Cravey/App/DependencyContainer.swift`

**Add property declarations** (after `recordingRepository`, ~line 20):

```swift
private(set) var usageRepository: UsageRepositoryProtocol
private(set) var logUsageUseCase: LogUsageUseCase
private(set) var fetchUsageUseCase: FetchUsageUseCase
```

**Replace stub with real implementation** (in `init`, ~line 40):

```swift
// Usage Repository (Phase 1 stub → Phase 2A real implementation)
let usageRepo = UsageRepository(modelContext: modelContext)
self.usageRepository = usageRepo

// Usage Use Cases
self.logUsageUseCase = DefaultLogUsageUseCase(repository: usageRepo)
self.fetchUsageUseCase = DefaultFetchUsageUseCase(repository: usageRepo)
```

**Remove old stub code** (search for `StubUsageRepository` and delete)

**Checkpoint:** Build succeeds, DI wired correctly

---

## 🧪 Validation Tests (Step 9)

**File:** `CraveyTests/Integration/UsageDataLayerTests.swift`

**Purpose:** Validate spec compliance BEFORE building UI

```swift
import Testing
import SwiftData
@testable import Cravey

@Suite("Usage Data Layer Integration Tests (Phase 2A)")
struct UsageDataLayerTests {

    // MARK: - Test 1: End-to-End Validation

    @Test("Should log usage end-to-end (UseCase → Repository → SwiftData)")
    @MainActor
    func testEndToEndUsageLog() async throws {
        // Setup in-memory SwiftData
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        // Create real repository and use case
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

        // Verify entity returned
        #expect(result.method == "Bowls")
        #expect(result.amount == 2.5)
        #expect(result.triggers.count == 2)

        // Verify persisted to SwiftData
        let descriptor = FetchDescriptor<UsageModel>()
        let saved = try context.fetch(descriptor)
        #expect(saved.count == 1)
        #expect(saved.first?.method == "Bowls")
        #expect(saved.first?.amount == 2.5)
    }

    // MARK: - Test 2: Fetch Validation

    @Test("Should fetch usage from SwiftData")
    @MainActor
    func testFetchUsage() async throws {
        // Setup
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        // Insert test data directly
        let model1 = UsageModel(timestamp: Date(), method: "Vape", amount: 5.0)
        let model2 = UsageModel(timestamp: Date().addingTimeInterval(-3600), method: "Edible", amount: 10.0)
        context.insert(model1)
        context.insert(model2)
        try context.save()

        // Fetch via use case
        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultFetchUsageUseCase(repository: repository)
        let results = try await useCase.execute()

        // Verify sorted by timestamp descending
        #expect(results.count == 2)
        #expect(results[0].method == "Vape")  // Most recent
        #expect(results[1].method == "Edible")
    }

    // MARK: - Test 3: Validate All 6 ROAs

    @Test("Should accept all 6 valid ROA methods")
    @MainActor
    func testAllROAMethods() async throws {
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultLogUsageUseCase(repository: repository)

        let methods = ["Bowls", "Joints", "Blunts", "Vape", "Dab", "Edible"]

        for method in methods {
            let validAmount = ROAAmountRange.range(for: method).first ?? 1.0
            let result = try await useCase.execute(
                timestamp: Date(),
                method: method,
                amount: validAmount
            )
            #expect(result.method == method)
        }

        // Verify all 6 saved
        let descriptor = FetchDescriptor<UsageModel>()
        let saved = try context.fetch(descriptor)
        #expect(saved.count == 6)
    }

    // MARK: - Test 4: Invalid Method Validation

    @Test("Should reject invalid ROA method")
    @MainActor
    func testInvalidMethod() async throws {
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultLogUsageUseCase(repository: repository)

        do {
            _ = try await useCase.execute(
                timestamp: Date(),
                method: "InvalidMethod",  // ❌ Not in valid list
                amount: 2.0
            )
            Issue.record("Should have thrown invalidMethod error")
        } catch UsageError.invalidMethod {
            // ✅ Expected error
        } catch {
            Issue.record("Wrong error type: \(error)")
        }
    }

    // MARK: - Test 5: Amount Validation

    @Test("Should reject amount = 0")
    @MainActor
    func testZeroAmount() async throws {
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultLogUsageUseCase(repository: repository)

        do {
            _ = try await useCase.execute(
                timestamp: Date(),
                method: "Bowls",
                amount: 0  // ❌ Must be >0
            )
            Issue.record("Should have thrown invalidAmount error")
        } catch UsageError.invalidAmount {
            // ✅ Expected error
        } catch {
            Issue.record("Wrong error type: \(error)")
        }
    }

    // MARK: - Test 6: HAALT Triggers Validation

    @Test("Should accept HAALT triggers array")
    @MainActor
    func testHAALTTriggers() async throws {
        let schema = Schema([UsageModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)

        let repository = UsageRepository(modelContext: context)
        let useCase = DefaultLogUsageUseCase(repository: repository)

        // Test with all 10 HAALT triggers
        let allTriggers = TriggerOptions.all
        let result = try await useCase.execute(
            timestamp: Date(),
            method: "Edible",
            amount: 25.0,
            triggers: allTriggers
        )

        #expect(result.triggers.count == 10)
        #expect(result.triggers.contains("Hungry"))
        #expect(result.triggers.contains("Paraphernalia"))
    }
}
```

**Run Tests:**

```bash
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests/UsageDataLayerTests | xcbeautify
```

**Expected:** ✅ 6/6 tests passing

**If tests fail:** FIX DATA LAYER BEFORE PROCEEDING TO PHASE 2B

---

## ✅ Completion Checklist

### Files Created (7 files)
- [ ] `Domain/Entities/UsageEntity.swift`
- [ ] `Domain/Repositories/UsageRepositoryProtocol.swift`
- [ ] `Domain/UseCases/ROAAmountRange.swift` (NEW - validation helper)
- [ ] `Domain/UseCases/LogUsageUseCase.swift`
- [ ] `Domain/UseCases/FetchUsageUseCase.swift`
- [ ] `Data/Mappers/UsageMapper.swift`
- [ ] `Data/Repositories/UsageRepository.swift`

### Files Modified (1 file)
- [ ] `App/DependencyContainer.swift` (added usage repository + use cases)

### Tests Created (1 file)
- [ ] `CraveyTests/Integration/UsageDataLayerTests.swift` (6 tests)

### Validation
- [ ] All 6 integration tests passing ✅
- [ ] Build succeeds with zero errors
- [ ] SwiftFormat applied to all new files
- [ ] No new SwiftLint violations
- [ ] UsageModel field count = 9 (matches DATA_MODEL_SPEC.md)
- [ ] ROA validation accepts all 6 methods
- [ ] ROA validation rejects invalid methods
- [ ] Amount validation rejects 0 and out-of-range values
- [ ] Triggers array accepts HAALT values (0-10 items)

---

## 🚀 What's Next: Phase 2B

**Phase 2B Goal:** Create ROAPickerInput component with full validation

**Why Separate:** ROA picker is complex (6 methods, dynamic ranges, display formatting). Validate this component in isolation before integrating into forms.

**Files to Create in 2B:**
- `Presentation/Views/Components/ROAPickerInput.swift`
- `CraveyTests/Presentation/Components/ROAPickerInputTests.swift`

**Checkpoint:** Component tests pass, picker validated for all 6 ROAs before building full form

---

**Status:** ✅ Phase 2A complete when all checkboxes marked
**Ready for:** Phase 2B (ROA Picker Component)

**[← Back to Phase 2](./PHASE_2.md)** | **[Phase 2B (ROA Picker) →](./PHASE_2B.md)**
