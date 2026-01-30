# DEBT-029: Repository Boilerplate Duplicated

**Priority:** P3 (Architecture - DRY Violation)
**Status:** OPEN
**Created:** 2026-01-28

## Problem

`CravingRepository` and `UsageRepository` have **80% identical** boilerplate - ~146 total lines of near-identical code.

---

## Duplicated Pattern

### CravingRepository.swift (79 lines)
### UsageRepository.swift (67 lines)

```swift
final class XRepository: XRepositoryProtocol {
    private nonisolated(unsafe) let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ entity: XEntity) async throws {
        try await MainActor.run {
            let model = XMapper.toModel(entity)
            modelContext.insert(model)
            try modelContext.save()
        }
    }

    func fetchAll() async throws -> [XEntity] {
        try await MainActor.run {
            let descriptor = FetchDescriptor<XModel>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let models = try modelContext.fetch(descriptor)
            return models.map { XMapper.toEntity($0) }
        }
    }

    func fetch(with filter: XFilter) async throws -> [XEntity] {
        // Similar filtering logic
    }

    func delete(id: UUID) async throws {
        try await MainActor.run {
            let predicate = #Predicate<XModel> { $0.id == id }
            try modelContext.delete(model: XModel.self, where: predicate)
            try modelContext.save()
        }
    }
}
```

---

## Rob C. Martin Fix: Generic Base Repository

```swift
// Cravey/Data/Repositories/BaseRepository.swift

import Foundation
import SwiftData

/// Protocol for SwiftData models with standard properties
protocol RepositoryModel: PersistentModel {
    var id: UUID { get }
    var timestamp: Date { get }
}

/// Protocol for entity-model mapping
protocol EntityMapper {
    associatedtype Entity
    associatedtype Model: RepositoryModel

    static func toModel(_ entity: Entity) -> Model
    static func toEntity(_ model: Model) -> Entity
}

/// Generic repository base class
class BaseRepository<Entity, Model: RepositoryModel, Mapper: EntityMapper>
    where Mapper.Entity == Entity, Mapper.Model == Model
{
    nonisolated(unsafe) let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ entity: Entity) async throws {
        try await MainActor.run {
            let model = Mapper.toModel(entity)
            modelContext.insert(model)
            try modelContext.save()
        }
    }

    func fetchAll(sortBy: [SortDescriptor<Model>] = []) async throws -> [Entity] {
        try await MainActor.run {
            let descriptor = FetchDescriptor<Model>(sortBy: sortBy)
            let models = try modelContext.fetch(descriptor)
            return models.map { Mapper.toEntity($0) }
        }
    }

    func delete(id: UUID) async throws {
        try await MainActor.run {
            let predicate = #Predicate<Model> { $0.id == id }
            try modelContext.delete(model: Model.self, where: predicate)
            try modelContext.save()
        }
    }
}

// MARK: - Concrete Repositories (now thin wrappers)

final class CravingRepository: BaseRepository<CravingEntity, CravingModel, CravingMapper>,
    CravingRepositoryProtocol
{
    func fetchAll() async throws -> [CravingEntity] {
        try await fetchAll(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
    }

    // Only add methods that differ from base
    func fetch(with filter: CravingFilter) async throws -> [CravingEntity] {
        // Custom filtering logic specific to Craving
    }
}

final class UsageRepository: BaseRepository<UsageEntity, UsageModel, UsageMapper>,
    UsageRepositoryProtocol
{
    func fetchAll() async throws -> [UsageEntity] {
        try await fetchAll(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
    }

    func fetch(with filter: UsageFilter) async throws -> [UsageEntity] {
        // Custom filtering logic specific to Usage
    }
}
```

---

## Files to Modify

| File | Change |
|------|--------|
| Create `Cravey/Data/Repositories/BaseRepository.swift` | Generic base repository |
| `CravingRepository.swift` | Extend `BaseRepository`, remove ~50 lines |
| `UsageRepository.swift` | Extend `BaseRepository`, remove ~50 lines |
| `CravingMapper.swift` | Conform to `EntityMapper` |
| `UsageMapper.swift` | Conform to `EntityMapper` |

---

## Acceptance Criteria

- [ ] `BaseRepository` created with shared save/fetch/delete logic
- [ ] Both repositories extend base and only define custom behavior
- [ ] ~100 lines of duplicated code removed
- [ ] All tests pass
