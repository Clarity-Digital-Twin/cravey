import Foundation
import SwiftData

/// Opt-in helper functions for repository implementations (DEBT-029)
/// Provides common SwiftData operations without forcing inheritance
/// Each repository explicitly specifies its types for type safety
enum RepositoryHelpers {
    /// Insert a model and save the context
    @MainActor
    static func insertAndSave(_ model: some PersistentModel, in context: ModelContext) throws {
        context.insert(model)
        try context.save()
    }

    /// Fetch all models of a type with optional sorting, then map to entities
    @MainActor
    static func fetchAll<M: PersistentModel, E>(
        from context: ModelContext,
        sortedBy sortDescriptors: [SortDescriptor<M>] = [],
        mappedBy mapper: (M) -> E
    ) throws -> [E] {
        var descriptor = FetchDescriptor<M>()
        descriptor.sortBy = sortDescriptors
        let models = try context.fetch(descriptor)
        return models.map(mapper)
    }

    /// Delete a model by ID using a predicate
    @MainActor
    static func delete<M: PersistentModel>(
        id: UUID,
        ofType _: M.Type,
        from context: ModelContext,
        findBy predicate: @escaping (UUID) -> Predicate<M>
    ) throws {
        var descriptor = FetchDescriptor<M>(predicate: predicate(id))
        descriptor.fetchLimit = 1
        let models = try context.fetch(descriptor)

        guard let model = models.first else {
            throw RepositoryError.notFound()
        }

        context.delete(model)
        try context.save()
    }

    /// Update a model by ID, applying changes via a closure
    @MainActor
    static func update<M: PersistentModel>(
        id: UUID,
        ofType _: M.Type,
        from context: ModelContext,
        findBy predicate: @escaping (UUID) -> Predicate<M>,
        applying changes: (M) -> Void
    ) throws {
        var descriptor = FetchDescriptor<M>(predicate: predicate(id))
        descriptor.fetchLimit = 1
        let models = try context.fetch(descriptor)

        guard let model = models.first else {
            throw RepositoryError.notFound()
        }

        changes(model)
        try context.save()
    }
}
