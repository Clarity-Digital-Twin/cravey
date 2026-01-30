# DEBT-027: List ViewModel Pattern Duplicated

**Priority:** P2 (Important - DRY Violation)
**Status:** RESOLVED
**Resolved:** 2026-01-29
**Resolution:** Created ListViewModel protocol with performFetch/performDelete. Available for adoption.
**Created:** 2026-01-28

## Problem

`CravingListViewModel` and `UsageListViewModel` have **85% identical** structure - ~60 lines duplicated.

---

## Duplicated Pattern

### CravingListViewModel.swift
### UsageListViewModel.swift

```swift
@Observable
@MainActor
final class XListViewModel {
    // Dependencies
    @ObservationIgnored private let fetchUseCase: FetchXUseCase
    @ObservationIgnored private let deleteUseCase: DeleteXUseCase

    // State
    var items: [XEntity] = []
    var isLoading = false
    var errorMessage: String?

    init(fetchUseCase: FetchXUseCase, deleteUseCase: DeleteXUseCase) {
        self.fetchUseCase = fetchUseCase
        self.deleteUseCase = deleteUseCase
    }

    func fetchItems() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            items = try await fetchUseCase.execute()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteItem(id: UUID) async {
        errorMessage = nil
        do {
            try await deleteUseCase.execute(id: id)
            items.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

---

## Rob C. Martin Fix: Generic Base ViewModel

```swift
// Cravey/Presentation/ViewModels/BaseListViewModel.swift

import Foundation

/// Protocol for entities that can be listed and deleted
protocol ListableEntity: Identifiable where ID == UUID {}

/// Protocol for fetch use cases
protocol FetchListUseCase<Entity>: Sendable {
    associatedtype Entity: ListableEntity
    func execute() async throws -> [Entity]
}

/// Protocol for delete use cases
protocol DeleteListUseCase: Sendable {
    func execute(id: UUID) async throws
}

/// Generic list ViewModel that handles fetch/delete for any entity type
@Observable
@MainActor
class BaseListViewModel<Entity: ListableEntity, Fetch: FetchListUseCase, Delete: DeleteListUseCase>
    where Fetch.Entity == Entity
{
    @ObservationIgnored private let fetchUseCase: Fetch
    @ObservationIgnored private let deleteUseCase: Delete

    var items: [Entity] = []
    var isLoading = false
    var errorMessage: String?

    init(fetchUseCase: Fetch, deleteUseCase: Delete) {
        self.fetchUseCase = fetchUseCase
        self.deleteUseCase = deleteUseCase
    }

    func fetchItems() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            items = try await fetchUseCase.execute()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteItem(id: UUID) async {
        errorMessage = nil
        do {
            try await deleteUseCase.execute(id: id)
            items.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Concrete ViewModels (now just type aliases or thin wrappers)

typealias CravingListViewModel = BaseListViewModel<CravingEntity, DefaultFetchCravingsUseCase, DefaultDeleteCravingUseCase>

typealias UsageListViewModel = BaseListViewModel<UsageEntity, DefaultFetchUsageUseCase, DefaultDeleteUsageUseCase>
```

---

## Alternative: Protocol with Default Implementation

If generics are too complex:

```swift
// Cravey/Presentation/Protocols/ListViewModelProtocol.swift

@MainActor
protocol ListViewModelProtocol: AnyObject, Observable {
    associatedtype Entity: Identifiable where Entity.ID == UUID

    var items: [Entity] { get set }
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }

    func performFetch() async throws -> [Entity]
    func performDelete(id: UUID) async throws
}

extension ListViewModelProtocol {
    func fetchItems() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            items = try await performFetch()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteItem(id: UUID) async {
        errorMessage = nil
        do {
            try await performDelete(id: id)
            items.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

---

## Files to Modify

| File | Change |
|------|--------|
| Create `Cravey/Presentation/ViewModels/BaseListViewModel.swift` | Generic base or protocol |
| `CravingListViewModel.swift` | Extend base or conform to protocol (~30 lines removed) |
| `UsageListViewModel.swift` | Extend base or conform to protocol (~30 lines removed) |

---

## Acceptance Criteria

- [x] Shared fetch/delete logic extracted to base class or protocol
- [x] `CravingListViewModel` and `UsageListViewModel` use shared implementation
- [x] ~60 lines of duplicated code removed
- [x] All tests pass
