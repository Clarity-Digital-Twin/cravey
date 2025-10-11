# Cravey App - Claude Code Context

## Project Overview
Cravey is a **cannabis cessation support app** built with modern SwiftUI and SwiftData. The app helps users track cravings, record motivational videos/audio, and access supportive content during difficult moments.

## Key Principles
1. **Privacy-First**: All data is local-only. No cloud sync, no analytics, no tracking.
2. **SwiftUI/SwiftData Native**: Uses iOS 18+ and macOS 15+ features with @Model macros.
3. **Motivational Interviewing**: Focuses on self-compassion and progress tracking.
4. **Simplicity**: Clean, intuitive interface for users in vulnerable moments.

## Architecture

### Tech Stack
- Swift 6.0 with strict concurrency
- SwiftUI for UI (iOS 18+, macOS 15+)
- SwiftData for persistence (@Model macro)
- AVFoundation for audio/video recording
- Swift Package Manager

### Project Structure
```
Sources/CraveyApp/
├── CraveyApp.swift              # @main entry point
├── Models/                      # SwiftData models
│   ├── Craving.swift
│   ├── Recording.swift
│   └── MotivationalMessage.swift
├── Views/                       # SwiftUI views
│   ├── ContentView.swift
│   ├── CravingLogView.swift
│   ├── RecordingsListView.swift
│   └── MotivationalView.swift
└── Utilities/                   # Helpers
    ├── FileStorageManager.swift
    └── ModelContainer+Extensions.swift
```

## Data Models

### Craving (@Model)
Tracks individual craving episodes with:
- Timestamp, intensity (1-10), trigger, notes
- Management success tracking
- One-to-many relationship with Recordings

### Recording (@Model)
Stores video/audio recordings with:
- Type (video/audio), purpose (motivational/craving/reflection/milestone)
- Local file path (not in database)
- Playback tracking
- Optional many-to-one relationship with Craving

### MotivationalMessage (@Model)
Pre-populated and user-created supportive messages with:
- Category-based organization
- Display priority system
- Usage analytics

## Important Implementation Details

### File Storage
- Recordings stored in `~/Documents/Recordings/`
- Thumbnails in `~/Documents/Recordings/Thumbnails/`
- Paths stored as relative strings in SwiftData
- `FileStorageManager` handles all file I/O

### SwiftData Configuration
```swift
ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false,
    allowsSave: true,
    cloudKitDatabase: .none  // IMPORTANT: Local only
)
```

### Recording Implementation (TODO)
The recording UI is stubbed out. To implement:
1. Request AVFoundation permissions
2. Use AVCaptureSession for video
3. Use AVAudioRecorder for audio
4. Save to temp file, then move to Documents/Recordings/
5. Generate thumbnail for videos
6. Create SwiftData Recording entry

## Development Guidelines

### When Adding Features
1. Keep privacy-first approach
2. Use SwiftData @Query for data access
3. Follow @MainActor for UI code
4. Use async/await for file operations
5. Handle errors gracefully (users may be in vulnerable state)

### Code Style
- Use SwiftUI best practices (2025)
- Prefer composition over inheritance
- Use @Relationship for model relationships
- Keep views focused and small
- Use extensions for computed properties

### Testing
- Preview containers available in ModelContainer+Extensions
- Use ModelContainer.preview for SwiftUI previews
- Keep sample data realistic

## Next Steps (Prioritized)

1. **AVFoundation Integration**
   - Audio recording with AVAudioRecorder
   - Video recording with AVCaptureSession
   - Playback with AVPlayer

2. **Analytics Dashboard**
   - Charts using Swift Charts
   - Streak tracking
   - Pattern identification

3. **Enhanced Motivational Content**
   - More default messages
   - Better categorization
   - Smart message selection based on context

4. **Export & Backup**
   - CSV export for tracking data
   - Manual backup/restore (still local)

## Common Tasks

### Adding a New Model Property
1. Add property to @Model class
2. May need migration (SwiftData handles lightweight changes)
3. Update relevant views
4. Consider preview data

### Adding a New View
1. Create in Views/ folder
2. Use @Query for data access
3. Get ModelContext from environment
4. Add preview with ModelContainer.preview

### Modifying File Storage
1. All changes go through FileStorageManager
2. Remember to update both file system AND SwiftData
3. Handle cleanup on delete

## Sensitive Considerations

This app deals with addiction recovery. Keep in mind:
- Users may be in crisis → Keep UI simple and clear
- Privacy is critical → Never add cloud features
- Be compassionate → Language should be supportive, not judgmental
- Focus on progress → Celebrate wins, normalize setbacks
- Don't gamify excessively → This isn't a fitness app

## Context7 Usage

This project was bootstrapped using Context7 MCP for:
- SwiftUI documentation (/websites/developer_apple_swiftui)
- SwiftData documentation (/websites/developer_apple_swiftdata)
- Modern iOS development patterns

Use `"use context7"` in prompts to fetch latest Apple docs.
