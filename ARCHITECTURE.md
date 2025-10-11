# Cravey Architecture Documentation

**Architecture Pattern:** Clean Architecture + MVVM
**Language:** Swift 6.0
**Frameworks:** SwiftUI, SwiftData, AVFoundation
**Minimum Deployment:** iOS 18.0, macOS 15.0

---

## Table of Contents
1. [Architectural Overview](#architectural-overview)
2. [Layer Responsibilities](#layer-responsibilities)
3. [Dependency Rules](#dependency-rules)
4. [Project Structure](#project-structure)
5. [Data Flow](#data-flow)
6. [Design Patterns](#design-patterns)
7. [Testing Strategy](#testing-strategy)

---

## Architectural Overview

### Why Clean Architecture + MVVM?

**Clean Architecture** (Robert C. Martin) provides:
- **Testability**: Each layer can be tested independently
- **Independence**: Business logic doesn't depend on UI or frameworks
- **Maintainability**: Clear boundaries make changes easier
- **Scalability**: Easy to add features without breaking existing code

**MVVM** in SwiftUI provides:
- **Reactive UI**: Natural fit with SwiftUI's declarative paradigm
- **Separation**: Views don't contain business logic
- **Testable ViewModels**: UI logic can be unit tested
- **Observable State**: @Observable macro makes state management clean

### Core Principles

1. **Dependency Inversion**: High-level modules don't depend on low-level modules
2. **Single Responsibility**: Each class has one reason to change
3. **Open/Closed**: Open for extension, closed for modification
4. **Interface Segregation**: Many specific interfaces > one general interface
5. **Liskov Substitution**: Subtypes must be substitutable for base types

---

## Layer Responsibilities

### 1. Domain Layer (Core Business Logic)

**Location:** `Cravey/Domain/`

**Purpose:** Contains enterprise business rules that are independent of any framework or UI.

**Components:**

#### Entities
Pure Swift models representing core business concepts.
```swift
// Example: Domain/Entities/Craving.swift
struct CravingEntity {
    let id: UUID
    let timestamp: Date
    let intensity: Int
    let trigger: String?
    // ... pure data, no SwiftData, no @Observable
}
```

**Rules:**
- ✅ Pure Swift (Codable, Equatable, Hashable)
- ✅ No dependencies on other layers
- ✅ No framework imports (SwiftUI, SwiftData, etc.)
- ❌ No persistence logic
- ❌ No UI concerns

#### Use Cases (Interactors)
Encapsulate application-specific business rules.
```swift
// Example: Domain/UseCases/LogCravingUseCase.swift
protocol LogCravingUseCase {
    func execute(intensity: Int, trigger: String?) async throws -> CravingEntity
}
```

**Rules:**
- ✅ Contains business logic
- ✅ Orchestrates data flow
- ✅ Uses repository protocols (defined in Domain)
- ❌ No direct DB/API access
- ❌ No UI logic

#### Repository Protocols
Define data access contracts (implementations in Data layer).
```swift
// Example: Domain/Repositories/CravingRepositoryProtocol.swift
protocol CravingRepositoryProtocol {
    func save(_ craving: CravingEntity) async throws
    func fetchAll() async throws -> [CravingEntity]
    func delete(_ id: UUID) async throws
}
```

**Rules:**
- ✅ Protocol only (no implementation)
- ✅ Defines what data operations are needed
- ❌ No implementation details
- ❌ No framework-specific types

---

### 2. Data Layer (Persistence & External APIs)

**Location:** `Cravey/Data/`

**Purpose:** Implements data access, persistence, and external service integration.

**Components:**

#### Models (SwiftData @Model)
Framework-specific models for persistence.
```swift
// Example: Data/Models/CravingModel.swift
@Model
final class CravingModel {
    var id: UUID
    var timestamp: Date
    var intensity: Int
    // SwiftData-specific model
}
```

**Rules:**
- ✅ Uses SwiftData @Model
- ✅ Persistence-focused
- ✅ Mapped to/from Domain entities
- ❌ Not exposed to Presentation layer

#### Repositories (Implementations)
Concrete implementations of repository protocols.
```swift
// Example: Data/Repositories/CravingRepository.swift
final class CravingRepository: CravingRepositoryProtocol {
    private let modelContext: ModelContext

    func save(_ craving: CravingEntity) async throws {
        // Convert Entity → SwiftData Model
        // Save to ModelContext
    }
}
```

**Rules:**
- ✅ Implements Domain protocols
- ✅ Handles persistence (SwiftData)
- ✅ Converts between Models and Entities
- ❌ No business logic
- ❌ No UI concerns

#### Storage
File system and external storage management.
```swift
// Example: Data/Storage/FileStorageManager.swift
actor FileStorageManager {
    func saveRecording(from url: URL) async throws -> String
    func deleteRecording(at path: String) async throws
}
```

**Rules:**
- ✅ Handles file I/O
- ✅ Thread-safe (use actor isolation)
- ✅ Returns simple types (String, Data, URL)
- ❌ No business logic

---

### 3. Presentation Layer (UI & User Interaction)

**Location:** `Cravey/Presentation/`

**Purpose:** Handles UI rendering and user interactions.

**Components:**

#### ViewModels
Observable state containers that prepare data for views.
```swift
// Example: Presentation/ViewModels/CravingLogViewModel.swift
@Observable
final class CravingLogViewModel {
    var intensity: Int = 5
    var trigger: String = ""
    var isLoading: Bool = false

    private let logCravingUseCase: LogCravingUseCase

    func logCraving() async {
        // Call use case
        // Handle success/error
        // Update UI state
    }
}
```

**Rules:**
- ✅ Uses @Observable (Swift 6)
- ✅ Depends on Use Cases (via DI)
- ✅ Contains UI state and presentation logic
- ✅ Handles async operations
- ❌ No direct repository access
- ❌ No SwiftData models
- ❌ No file I/O

#### Views
SwiftUI views that render UI and handle user input.
```swift
// Example: Presentation/Views/CravingLogView.swift
struct CravingLogView: View {
    @State private var viewModel: CravingLogViewModel

    var body: some View {
        // SwiftUI view code
    }
}
```

**Rules:**
- ✅ Pure SwiftUI
- ✅ Depends on ViewModel
- ✅ Handles layout and rendering
- ❌ No business logic
- ❌ No data persistence
- ❌ No direct use case calls

---

### 4. App Layer (Composition Root)

**Location:** `Cravey/App/`

**Purpose:** Application entry point and dependency injection.

**Components:**

#### App Entry Point
```swift
// Example: App/CraveyApp.swift
@main
struct CraveyApp: App {
    @State private var dependencyContainer = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dependencyContainer)
        }
    }
}
```

#### Dependency Container
```swift
// Example: App/DependencyContainer.swift
@Observable
final class DependencyContainer {
    // Singletons
    let modelContext: ModelContext
    let fileStorage: FileStorageManager

    // Repositories
    lazy var cravingRepository: CravingRepositoryProtocol = {
        CravingRepository(modelContext: modelContext)
    }()

    // Use Cases
    lazy var logCravingUseCase: LogCravingUseCase = {
        DefaultLogCravingUseCase(repository: cravingRepository)
    }()
}
```

**Rules:**
- ✅ Wires up all dependencies
- ✅ Creates and owns singleton services
- ✅ Provides factories for scoped instances
- ❌ No business logic

---

## Dependency Rules

### The Golden Rule
**Dependencies point INWARD** (toward Domain layer)

```
┌─────────────────────────────────────┐
│         Presentation Layer          │  ← Depends on Domain
│   (Views, ViewModels, Coordinators) │
└──────────────┬──────────────────────┘
               │
               ↓
┌─────────────────────────────────────┐
│          Domain Layer                │  ← No dependencies
│  (Entities, Use Cases, Protocols)   │     (pure Swift)
└──────────────┬──────────────────────┘
               ↑
               │
┌──────────────┴──────────────────────┐
│          Data Layer                  │  ← Depends on Domain
│ (Models, Repositories, Storage)     │     (implements protocols)
└─────────────────────────────────────┘
```

### What This Means

1. **Domain** knows nothing about other layers
2. **Presentation** depends on Domain (via protocols)
3. **Data** depends on Domain (implements protocols)
4. **App** knows about all layers (composition root)

### Enforcing Rules

- Use `internal` access control by default
- Make Domain types `public` only when necessary
- Never import SwiftUI in Domain
- Never import SwiftData in Domain or Presentation

---

## Project Structure

```
Cravey/                              # Xcode app target
├── App/
│   ├── CraveyApp.swift             # @main entry point
│   ├── DependencyContainer.swift   # DI container
│   └── SceneDelegate.swift         # (if needed)
│
├── Domain/
│   ├── Entities/
│   │   ├── CravingEntity.swift
│   │   ├── RecordingEntity.swift
│   │   └── MotivationalMessageEntity.swift
│   │
│   ├── UseCases/
│   │   ├── CravingTracking/
│   │   │   ├── LogCravingUseCase.swift
│   │   │   ├── FetchCravingsUseCase.swift
│   │   │   └── DeleteCravingUseCase.swift
│   │   ├── Recordings/
│   │   │   ├── CreateRecordingUseCase.swift
│   │   │   └── PlayRecordingUseCase.swift
│   │   └── Motivational/
│   │       └── FetchRandomMessageUseCase.swift
│   │
│   └── Repositories/
│       ├── CravingRepositoryProtocol.swift
│       ├── RecordingRepositoryProtocol.swift
│       └── MessageRepositoryProtocol.swift
│
├── Data/
│   ├── Models/
│   │   ├── CravingModel.swift         # SwiftData @Model
│   │   ├── RecordingModel.swift       # SwiftData @Model
│   │   └── MotivationalMessageModel.swift
│   │
│   ├── Repositories/
│   │   ├── CravingRepository.swift    # Implements protocol
│   │   ├── RecordingRepository.swift
│   │   └── MessageRepository.swift
│   │
│   ├── Storage/
│   │   ├── FileStorageManager.swift   # File I/O
│   │   └── ModelContainer+Setup.swift # SwiftData setup
│   │
│   └── Mappers/
│       ├── CravingMapper.swift        # Entity ↔ Model
│       ├── RecordingMapper.swift
│       └── MessageMapper.swift
│
├── Presentation/
│   ├── ViewModels/
│   │   ├── CravingLog/
│   │   │   └── CravingLogViewModel.swift
│   │   ├── Dashboard/
│   │   │   └── DashboardViewModel.swift
│   │   ├── Recordings/
│   │   │   ├── RecordingsListViewModel.swift
│   │   │   └── RecordingPlayerViewModel.swift
│   │   └── Motivational/
│   │       └── MotivationalViewModel.swift
│   │
│   ├── Views/
│   │   ├── CravingLog/
│   │   │   └── CravingLogView.swift
│   │   ├── Dashboard/
│   │   │   ├── DashboardView.swift
│   │   │   ├── Components/
│   │   │   │   └── StatCard.swift
│   │   ├── Recordings/
│   │   │   ├── RecordingsListView.swift
│   │   │   └── RecordingPlayerView.swift
│   │   ├── Motivational/
│   │   │   └── MotivationalView.swift
│   │   └── ContentView.swift
│   │
│   └── Common/
│       ├── ViewModifiers/
│       └── Components/
│
├── Resources/
│   ├── Assets.xcassets
│   ├── Info.plist
│   └── Localizable.strings
│
└── Supporting Files/
    └── (Generated files)
```

---

## Data Flow

### Example: Logging a Craving

```
┌──────────────┐
│ CravingLogView│ User taps "Log Craving"
└───────┬──────┘
        │
        ↓
┌───────────────────────┐
│ CravingLogViewModel   │ viewModel.logCraving()
└───────┬───────────────┘
        │
        ↓
┌───────────────────────┐
│ LogCravingUseCase     │ execute(intensity, trigger)
└───────┬───────────────┘
        │
        ↓
┌───────────────────────┐
│ CravingRepository     │ save(cravingEntity)
└───────┬───────────────┘
        │
        ↓
┌───────────────────────┐
│ SwiftData ModelContext│ insert(cravingModel)
└───────────────────────┘
```

**Flow Steps:**
1. **View** receives user action
2. **ViewModel** calls appropriate Use Case
3. **Use Case** applies business rules, calls Repository
4. **Repository** converts Entity → Model, saves to SwiftData
5. **Repository** returns result to Use Case
6. **Use Case** returns to ViewModel
7. **ViewModel** updates observable state
8. **View** automatically updates (SwiftUI reactivity)

---

## Design Patterns

### 1. Repository Pattern
**Purpose:** Abstraction over data access
**Location:** Domain (protocol) + Data (implementation)

### 2. Use Case Pattern
**Purpose:** Encapsulate business rules
**Location:** Domain/UseCases/

### 3. MVVM Pattern
**Purpose:** Separate presentation logic from views
**Location:** Presentation layer

### 4. Dependency Injection
**Purpose:** Loose coupling, testability
**Location:** App/DependencyContainer.swift

### 5. Mapper Pattern
**Purpose:** Convert between layers (Entity ↔ Model)
**Location:** Data/Mappers/

### 6. Observer Pattern
**Purpose:** Reactive UI updates
**Implementation:** @Observable macro (Swift 6)

---

## Testing Strategy

### Unit Tests (Fast, Isolated)

#### Domain Layer Tests
```
CraveyTests/Domain/
├── UseCases/
│   ├── LogCravingUseCaseTests.swift
│   └── FetchCravingsUseCaseTests.swift
└── Entities/
    └── CravingEntityTests.swift
```

**Test:** Pure business logic with mocked repositories

#### Data Layer Tests
```
CraveyTests/Data/
├── Repositories/
│   └── CravingRepositoryTests.swift
└── Mappers/
    └── CravingMapperTests.swift
```

**Test:** Data access with in-memory SwiftData

#### Presentation Layer Tests
```
CraveyTests/Presentation/
└── ViewModels/
    └── CravingLogViewModelTests.swift
```

**Test:** UI logic with mocked use cases

### Integration Tests (Medium Speed)

```
CraveyIntegrationTests/
└── Flows/
    ├── CravingLoggingFlowTests.swift
    └── RecordingFlowTests.swift
```

**Test:** Multiple layers working together

### UI Tests (Slow, End-to-End)

```
CraveyUITests/
├── CravingLoggingUITests.swift
├── RecordingsUITests.swift
└── DashboardUITests.swift
```

**Test:** User flows in simulator

---

## Key Architectural Decisions

### Why Not Combine?
- @Observable + async/await is more modern
- Better cancellation with Task
- Cleaner syntax

### Why Not Coordinators?
- SwiftUI navigation is declarative
- NavigationStack handles most cases
- Can add later if needed

### Why Actors for Storage?
- File I/O is inherently concurrent
- Actor isolation prevents race conditions
- Matches Swift 6 concurrency model

### Why Not SwiftData Everywhere?
- Domain needs to be framework-independent
- Testability requires pure entities
- SwiftData is an implementation detail

---

## Migration Path

If the app grows large, we can modularize:

1. **Extract Domain → SPM Package**
   - `Package: CraveyDomain`
   - Contains: Entities, Use Cases, Protocols

2. **Extract Data → SPM Package**
   - `Package: CraveyData`
   - Depends on: CraveyDomain

3. **Extract Presentation → SPM Package**
   - `Package: CraveyPresentation`
   - Depends on: CraveyDomain

4. **App Target becomes thin**
   - Just DI + Navigation

This is **NOT needed now** but the architecture supports it.

---

## Checklist for New Features

When adding a feature, follow this order:

- [ ] Define Entity in Domain/Entities/
- [ ] Define Repository Protocol in Domain/Repositories/
- [ ] Create Use Case in Domain/UseCases/
- [ ] Write Unit Tests for Use Case
- [ ] Create SwiftData Model in Data/Models/
- [ ] Implement Repository in Data/Repositories/
- [ ] Create Mapper in Data/Mappers/
- [ ] Create ViewModel in Presentation/ViewModels/
- [ ] Write ViewModel Tests
- [ ] Create View in Presentation/Views/
- [ ] Wire up DI in DependencyContainer
- [ ] Write UI Tests for happy path

---

## Questions? Common Pitfalls

**Q: Can Views access Repositories directly?**
❌ NO. Views → ViewModels → Use Cases → Repositories

**Q: Can I use SwiftData @Model in ViewModels?**
❌ NO. Use Domain Entities. Repositories convert.

**Q: Where do I put validation logic?**
✅ Use Cases (business rules) or Entities (simple checks)

**Q: Can Use Cases depend on other Use Cases?**
✅ YES, but keep it shallow. Inject via protocol.

**Q: Where does API networking go?**
✅ Data layer (similar to Repository pattern)

---

## Resources

- [Clean Architecture (Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [iOS Clean Architecture Example](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM)
- [SOLID Principles](https://www.digitalocean.com/community/conceptual_articles/s-o-l-i-d-the-first-five-principles-of-object-oriented-design)
- [SwiftUI + Clean Architecture](https://nalexn.github.io/clean-architecture-swiftui/)

---

**Last Updated:** 2025-10-11
**Version:** 1.0
**Status:** ✅ Approved for Implementation
