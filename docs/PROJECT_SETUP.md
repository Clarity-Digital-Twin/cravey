# Project Setup Guide

## Step 0: Install CLI Tools (Recommended)

Run the setup script to install all terminal tools:
```bash
./setup-tools.sh
```

This installs:
- xcodebuild, xcrun, simctl (Apple's tools)
- xcbeautify (modern build formatter)
- fastlane (iOS automation)
- swiftlint & swiftformat (code quality)
- xcodegen (project generation)

**After installation**, you can build from terminal without opening Xcode!

---

## Quick Start: Creating the Xcode Project

### 1. Create New Xcode Project

```bash
# In Xcode:
File → New → Project
```

**Select:**
- Platform: iOS (or macOS)
- Template: **App**
- Interface: **SwiftUI**
- Storage: **None** (we'll handle SwiftData manually)
- Name: **Cravey**
- Bundle ID: `com.yourname.Cravey`

### 2. Move Code into Project

After project is created, **drag the Sources/Cravey App/** folders into your Xcode project:
- Domain/
- Data/
- Presentation/
- App/

### 3. Set Up Info.plist

Copy contents from `Config/iOS.Info.plist.template` into your project's Info.plist

**Required Keys:**
- NSMicrophoneUsageDescription
- NSCameraUsageDescription
- NSPhotoLibraryAddUsageDescription (optional)

### 4. Add Test Targets

**Unit Tests:**
```
File → New → Target → iOS Unit Testing Bundle
Name: CraveyTests
```

**UI Tests:**
```
File → New → Target → iOS UI Testing Bundle
Name: CraveyUITests
```

### 5. Build Settings

**In Xcode project settings:**
- Minimum iOS: 18.0
- Swift Language Version: 6.0
- Enable Strict Concurrency Checking: Yes

### 6. Run!

Cmd+R - Should compile and run

---

## Project Structure (After Setup)

```
Cravey.xcodeproj
Cravey/                      # Main app target
├── App/
├── Domain/
├── Data/
├── Presentation/
├── Resources/
│   ├── Assets.xcassets
│   └── Info.plist
└── Supporting Files/

CraveyTests/                 # Unit tests
CraveyUITests/              # UI tests
```

---

## Common Issues

**"Cannot find type 'ModelContext'"**
→ Make sure you imported SwiftData in the file

**"Module not found"**
→ Check target membership (files must be in correct target)

**Build taking forever**
→ Clean build folder: Cmd+Shift+K

---

## Terminal Build Commands

Once CLI tools are installed and Xcode project is created:

**Build from terminal:**
```bash
xcodebuild -scheme Cravey -destination 'platform=iOS Simulator,name=iPhone 15 Pro' | xcbeautify
```

**Run tests:**
```bash
xcodebuild test -scheme Cravey -destination 'platform=iOS Simulator,name=iPhone 15 Pro' | xcbeautify
```

**Format code:**
```bash
swiftformat .
```

**Lint code:**
```bash
swiftlint
```

**Clean build:**
```bash
xcodebuild clean -scheme Cravey
```

---

See ARCHITECTURE.md for detailed architecture info.
