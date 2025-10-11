# Cravey - Cannabis Cessation Support App

A modern, privacy-focused **iOS application** built with SwiftUI and SwiftData to help users track cannabis cravings, log their journey, and access motivational support during difficult moments.

> **Note**: Currently focused on iOS 18+. macOS support planned for future release.

## Features

### Core Functionality
- **Craving Tracking**: Log cravings with intensity levels (1-10), triggers, location, and notes
- **Personal Recordings**: Create video and audio recordings for self-support during cravings
- **Motivational Messages**: Access categorized supportive messages and create personalized ones
- **Progress Dashboard**: View statistics and track your journey over time
- **Quick SOS**: Emergency support button for immediate access to coping strategies

### Privacy & Security
- ✅ 100% local-only storage (no cloud sync)
- ✅ All data stays on your device
- ✅ No analytics or tracking
- ✅ No internet connection required

## Tech Stack

### 2025 Modern iOS Development
- **Swift 6.2** with strict concurrency
- **SwiftUI** for declarative UI (iOS 18+)
- **SwiftData** for persistent storage (@Model macro)
- **AVFoundation** for audio/video recording
- **XcodeGen 2.44.1** for project generation

### Architecture
- **Clean Architecture + MVVM** (Robert C. Martin principles)
- Pure Domain layer (framework-independent business logic)
- Repository pattern with protocol-based DI
- @Observable ViewModels (Swift 6)
- Proper separation of concerns

### Development Tools
- **Xcode 26.0.1** (Build 17A400)
- **xcbeautify 2.30.1** - Pretty terminal output
- **swiftlint 0.61.0** - Code linting
- **swiftformat 0.58.3** - Auto-formatting
- **gh 2.81.0** - GitHub CLI

## App Configuration Templates

- iOS Info.plist template: `Config/iOS.Info.plist.template`
- macOS Info.plist template: `Config/macOS.Info.plist.template`
- Remote chat config example: `Config/ChatConfig.example.json`

## Project Structure

