# Getting Started with Cravey

**A B2C cannabis cessation tracking app built with Clean Architecture + MVVM**

---

## 🚀 Quick Start (5 minutes)

### 1. Install CLI Tools

```bash
./setup-tools.sh
```

This installs: xcodebuild, xcbeautify, fastlane, xcodegen, swiftlint, swiftformat

### 2. Generate Xcode Project

```bash
xcodegen generate
```

This creates `Cravey.xcodeproj` from `project.yml`

### 3. Verify the Repo (Recommended)

```bash
bash scripts/verify.sh
```

This runs the same objective gate used for convergence: project generation, formatting, linting, invariants, an iOS Simulator compile check, and unit tests (Mac Catalyst).

### 4. Build & Run

**Option A: Terminal Build**
```bash
xcodebuild -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build | xcbeautify
```

**Option B: Open in Xcode**
```bash
open Cravey.xcodeproj
# Then press Cmd+R
```

---

## 📁 Project Structure

```
Cravey/                          # ← Main app code (Clean Architecture)
├── App/                         # DI Container + Entry Point
├── Domain/                      # Pure business logic (no frameworks)
│   ├── Entities/                # Core models
│   ├── UseCases/                # Business rules
│   └── Repositories/            # Protocols
├── Data/                        # Persistence + Storage
│   ├── Models/                  # SwiftData @Model
│   ├── Repositories/            # Concrete implementations
│   ├── Mappers/                 # Entity ↔ Model conversion
│   └── Storage/                 # File I/O
└── Presentation/                # UI Layer
    ├── ViewModels/              # @Observable state
    └── Views/                   # SwiftUI

CraveyTests/                     # Unit tests
CraveyUITests/                   # UI tests
Config/                          # Info.plist templates
```

---

## 🏗️ Architecture

**Clean Architecture + MVVM + SwiftUI-native patterns**

### Dependency Flow
```
Presentation → Domain ← Data
      ↓           ↓        ↓
   Views    Use Cases  Repos
      ↓           ↓        ↓
ViewModels   Entities  Models
```

**Key Principles:**
- Domain layer is **pure Swift** (no SwiftUI/SwiftData)
- Data layer implements Domain protocols
- Presentation depends on Domain (via Use Cases)
- DI Container wires everything together

See [ARCHITECTURE.md](ARCHITECTURE.md) for full details.

---

## 🛠️ Development Workflow

### Day-to-Day Commands

**Format code:**
```bash
swiftformat .
```

**Lint code:**
```bash
swiftlint
```

**Run tests:**
```bash
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  | xcbeautify
```

**Clean build:**
```bash
xcodebuild clean -scheme Cravey
```

### Adding New Features

Follow this order (see ARCHITECTURE.md for checklist):
1. Create Entity in `Domain/Entities/`
2. Define Repository Protocol in `Domain/Repositories/`
3. Create Use Case in `Domain/UseCases/`
4. Write Unit Tests
5. Create SwiftData Model in `Data/Models/`
6. Implement Repository in `Data/Repositories/`
7. Create Mapper in `Data/Mappers/`
8. Create ViewModel in `Presentation/ViewModels/`
9. Write ViewModel Tests
10. Create View in `Presentation/Views/`
11. Wire up DI in `DependencyContainer`
12. Write UI Tests

---

## 🧪 Testing

**Unit Tests (Fast):**
```bash
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests \
  | xcbeautify
```

**UI Tests (Slow):**
```bash
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyUITests \
  | xcbeautify
```

---

## 📦 What's Implemented

### ✅ Complete
- Clean Architecture folder structure
- Domain layer (Entities, Use Cases, Protocols)
- Data layer (Models, Repositories, Mappers, Storage)
- Dependency Injection container
- SwiftUI Views + ViewModels for core logging + dashboard + settings
- Unit tests + integration-style tests (Swift Testing)
- UI test scaffolding
- XcodeGen configuration
- CLI tooling setup

### 🚧 TODO (Next Steps)
- Implement remaining repositories (Recording, Message)
- Implement recordings feature (AVFoundation capture + playback UI)
- Implement onboarding flow (Welcome + Tour)
- Expand motivational content feature (messages)
- (Optional) Re-enable / expand UI tests in the verification gate

---

## 🔧 Configuration Files

**project.yml** - XcodeGen config (generates .xcodeproj)
**Config/iOS.Info.plist.template** - Info.plist with privacy strings
**setup-tools.sh** - One-time CLI tools installation
**.gitignore** - Ignores .xcodeproj (regenerate with xcodegen)

---

## 🎯 Design Decisions

**Why XcodeGen?**
- Project file is YAML (human-readable, git-friendly)
- No merge conflicts on .xcodeproj
- Regenerate anytime with `xcodegen generate`
- Team members don't need Xcode open to edit structure

**Why Clean Architecture?**
- Testable (mock any dependency)
- Framework-independent Domain layer
- Scalable for B2C growth
- Clear separation of concerns

**Why local-first?**
- Privacy-focused (sensitive health data)
- No server costs
- Works offline
- User owns their data

---

## 📚 Documentation

- **ARCHITECTURE.md** - Full architecture guide
- **CLAUDE.md** - AI assistant context
- **README.md** - Project overview

---

## 🐛 Troubleshooting

**"command not found: xcodegen"**
→ Run `./setup-tools.sh` first

**"No such file or directory: Cravey.xcodeproj"**
→ Run `xcodegen generate`

**Build fails with "Cannot find type 'ModelContext'"**
→ Check target membership (files must be in Cravey target)

**SwiftLint errors**
→ Run `swiftformat .` then `swiftlint --fix`

---

## 🤝 Contributing

This is a personal health app, but Clean Architecture makes it easy to:
- Add new features (follow the checklist)
- Swap implementations (e.g., CoreData → Realm)
- Test everything (mocks provided)
- Extract modules (Domain can become SPM package)

---

## 📝 Notes

- All code is Swift 6 with strict concurrency
- iOS 18+ / macOS 15+ minimum
- No external dependencies (yet)
- SwiftData for persistence
- SwiftUI for all UI

---

**Ready to build the world's best cannabis cessation app? Let's go! 🚀**
