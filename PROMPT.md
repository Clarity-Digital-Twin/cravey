# Cravey – Ralph Wiggum Loop Prompt (UI/UX Polish)

## Mission
Elevate Cravey's UI/UX to **GOD TIER Apple HIG compliance** — a premium, polished health app that feels native to iOS 18+ and would make Apple's design team proud.

**Target:** Screenshot-perfect UI across all screens. Every pixel intentional. Zero jank.

---

## Hard Constraints (must not violate)
- **Privacy-first:** local-only data; no analytics; no tracking; no cloud sync; keep SwiftData `cloudKitDatabase: .none`.
- **Clean Architecture:** Presentation → Domain ← Data; Domain stays framework-free (no SwiftUI/SwiftData).
- **Motivational interviewing tone:** non-judgmental language (avoid "failure", "streak broken").
- **iOS 18+ minimum deployment target** (prepare for iOS 26 Liquid Glass when available).
- **Orientation:** Portrait-only for MVP (lock in Info.plist). UI must be safe-area aware for future landscape support.

---

## Beads Integration (Multi-Agent Memory)

This loop uses **[Beads](https://github.com/steveyegge/beads)** — Steve Yegge's distributed, git-backed graph issue tracker for AI agents.

**Why Beads:**
- Persistent task memory across Ralph Wiggum iterations
- Dependency-aware task graph (tasks chain like beads)
- Git-versioned progress tracking in `.beads/` directory
- Multi-agent coordination if spawning sub-agents

**Setup (if not already installed):**
```bash
brew tap steveyegge/beads
brew install beads
pip install beads-mcp
bd init  # Initialize beads in this repo
```

**Usage During Loop:**
1. At start of each iteration, run `bd ready` to see actionable tasks
2. Create beads for each UI/UX issue found: `bd create "Fix X" --depends-on bd-xxx`
3. Mark completed: `bd done bd-xxx`
4. Track progress: `bd status`

---

## iOS 18+ Modern APIs (REQUIRED)

### 1. MeshGradient (Liquid Glass Foundation)
Use `MeshGradient` for organic, fluid backgrounds on cards/headers:
```swift
MeshGradient(width: 3, height: 3, points: [
    [0, 0], [0.5, 0], [1, 0],
    [0, 0.5], [0.5, 0.5], [1, 0.5],
    [0, 1], [0.5, 1], [1, 1]
], colors: [
    .blue.opacity(0.3), .purple.opacity(0.2), .indigo.opacity(0.3),
    .cyan.opacity(0.2), .mint.opacity(0.1), .teal.opacity(0.2),
    .blue.opacity(0.2), .purple.opacity(0.3), .indigo.opacity(0.2)
])
```
Combine with `.ultraThinMaterial` overlay for glass effect.

### 2. Declarative Haptics (`.sensoryFeedback`)
**FORBIDDEN:** `UIImpactFeedbackGenerator`, `UINotificationFeedbackGenerator`
**REQUIRED:** `.sensoryFeedback()` modifier on Views

```swift
// Success feedback
.sensoryFeedback(.success, trigger: didSave)

// Selection feedback
.sensoryFeedback(.selection, trigger: selectedItem)

// Impact with customization
.sensoryFeedback(.impact(weight: .medium, intensity: 0.7), trigger: value)
```

### 3. Symbol Effects (`.symbolEffect`)
Animate SF Symbols for premium feel:
```swift
Image(systemName: "checkmark.circle.fill")
    .symbolEffect(.bounce, value: isComplete)

Image(systemName: "flame.fill")
    .symbolEffect(.pulse, options: .repeating, value: isActive)
```

### 4. Navigation Transitions (iOS 18)
Use zoom transitions for detail views:
```swift
NavigationLink(value: item) {
    CardView(item: item)
}
.navigationTransition(.zoom(sourceID: item.id, in: namespace))
```

### 5. Scroll Transitions
Add entrance animations:
```swift
.scrollTransition { content, phase in
    content
        .opacity(phase.isIdentity ? 1 : 0.3)
        .scaleEffect(phase.isIdentity ? 1 : 0.9)
}
```

---

## UI/UX Audit Checklist (Must Fix)

### Visual Polish Issues to Address

1. **Typography Hierarchy**
   - [ ] Consistent font weights (SF Pro Display for titles, SF Pro Text for body)
   - [ ] Proper Dynamic Type scaling (all text must scale 1x → 7x)
   - [ ] Line heights and letter spacing per Apple HIG
   - [ ] NO fixed font sizes (use semantic: `.title`, `.headline`, `.body`)

2. **Spacing & Layout**
   - [ ] Consistent 16pt/20pt grid system
   - [ ] Proper insets for safe areas (`.safeAreaInset`)
   - [ ] Card/container padding consistency (16pt standard)
   - [ ] Remove awkward gaps or cramped sections
   - [ ] Use `.containerRelativeFrame` for responsive sizing

3. **Color System**
   - [ ] Semantic colors only (`.primary`, `.secondary`, `.accentColor`)
   - [ ] NO hardcoded hex values or `Color(red:)`
   - [ ] Dark mode full support (test every screen)
   - [ ] Proper contrast ratios (WCAG AA minimum)
   - [ ] Use `MeshGradient` for premium backgrounds

4. **Components**
   - [ ] All tap targets ≥44×44pt (Apple HIG requirement)
   - [ ] Buttons have proper hit states (pressed, disabled)
   - [ ] Form inputs match iOS native styling
   - [ ] Cards use proper corner radius (16pt standard)
   - [ ] `.ultraThinMaterial` for glassmorphism (iOS 26 ready)
   - [ ] ChipSelector: Use material backgrounds, not flat colors

5. **Haptics & Feedback**
   - [ ] All saves/actions use `.sensoryFeedback(.success)`
   - [ ] Selections use `.sensoryFeedback(.selection)`
   - [ ] Slider changes use `.sensoryFeedback(.impact)`
   - [ ] NO legacy UIKit haptic generators

6. **Animations & Transitions**
   - [ ] Sheet presentations use spring animations
   - [ ] Loading states have smooth transitions (shimmer effect)
   - [ ] SF Symbols use `.symbolEffect(.bounce)` on state changes
   - [ ] Scroll views use `.scrollTransition` for entry
   - [ ] Respect `UIAccessibility.isReduceMotionEnabled`

7. **Empty States**
   - [ ] Every list has a beautiful empty state
   - [ ] Use SF Symbols with proper sizing (60pt icons)
   - [ ] Symbols animate with `.symbolEffect(.pulse)`
   - [ ] Encouraging copy, not just "No data"

8. **Navigation**
   - [ ] Tab bar icons consistent weight/style
   - [ ] Navigation titles use `.large` or `.inline` appropriately
   - [ ] Back buttons and toolbar items properly spaced
   - [ ] Use `.navigationTransition(.zoom)` where appropriate

---

## Screen-by-Screen Audit Requirements

### Home Tab
- [ ] "Log Craving" / "Log Usage" buttons are prominent, not cramped
- [ ] Buttons use `.sensoryFeedback(.impact)` on tap
- [ ] Section headers ("Recent Cravings", "Recent Usage") have proper styling
- [ ] Empty states use `.symbolEffect(.pulse)` animation
- [ ] Toast overlay uses `.sensoryFeedback(.success)` + `.symbolEffect(.bounce)`
- [ ] List items have sufficient padding (16pt horizontal, 12pt vertical)

### Craving/Usage Log Forms
- [ ] Form sections have proper headers
- [ ] ChipSelector uses `.ultraThinMaterial` or subtle `MeshGradient`
- [ ] IntensitySlider feels native (consider gradient track)
- [ ] Slider provides `.sensoryFeedback(.impact)` during drag
- [ ] TextEditor has visible border/background
- [ ] Character counters don't crowd the input
- [ ] Save button has loading state + `.sensoryFeedback(.success)`

### Dashboard Tab
- [ ] MetricCards use subtle `MeshGradient` or `.ultraThinMaterial`
- [ ] Numbers are prominent (large, bold)
- [ ] Units are secondary (smaller, `.secondary` color)
- [ ] Icons use `.symbolEffect(.bounce)` on appear
- [ ] Empty dashboard has beautiful placeholder with animated symbol
- [ ] Cards have proper shadow/elevation (subtle)
- [ ] Use `.scrollTransition` for card entry animations

### Settings Tab
- [ ] List style matches iOS Settings app exactly
- [ ] Destructive actions are properly red
- [ ] Version info is properly styled
- [ ] Export/Delete flows feel native
- [ ] Success/error states use `.sensoryFeedback`

---

## Verification (UI/UX Specific)

### Automated Checks

```bash
set -euo pipefail

# 1. Build succeeds
xcodegen generate
xcodebuild -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build | xcbeautify

# 2. All tests pass
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' | xcbeautify

# 3. No SwiftLint warnings in Views
swiftlint Cravey/Presentation/Views/

# 4. No hardcoded colors (should use semantic colors or MeshGradient)
! rg -n 'Color\(red:|Color\(#|UIColor\(' Cravey/Presentation/Views/

# 5. All tap targets are accessible (checks for width < 44)
rg -n '\.frame\(.*width:\s*([0-9]|[1-3][0-9])\D' Cravey/Presentation/Views/ && echo "FAIL: Small tap targets found" && exit 1 || true

# 6. Check for Legacy Haptics (FORBIDDEN)
rg -n 'UIImpactFeedbackGenerator|UINotificationFeedbackGenerator' Cravey/Presentation/ && echo "FAIL: Use .sensoryFeedback modifier instead" && exit 1 || true

# 7. Dynamic Type support check (no fixed font sizes in Views)
rg -n '\.font\(\.system\(size:' Cravey/Presentation/Views/ && echo "FAIL: Use semantic font styles" && exit 1 || true

# 8. Verify sensoryFeedback usage exists
rg -n 'sensoryFeedback' Cravey/Presentation/Views/ || echo "WARNING: No haptic feedback found in Views"

# 9. Verify symbolEffect usage exists
rg -n 'symbolEffect' Cravey/Presentation/Views/ || echo "WARNING: No symbol animations found"
```

### Screenshot Verification Task

At each iteration, capture and review screenshots of:
1. **Home Tab** (empty state)
2. **Home Tab** (with data)
3. **Log Craving Sheet** (full form)
4. **Log Usage Sheet** (full form)
5. **Dashboard Tab** (empty state)
6. **Dashboard Tab** (with metrics)
7. **Settings Tab**
8. **Dark Mode** variants of all above

Use simulator screenshots:
```bash
xcrun simctl io booted screenshot ~/Desktop/cravey-screenshots/$(date +%s).png
```

---

## Definition of Done (UI/UX Polish)

When **ALL** of the following are true, output:

```
<promise>UI/UX GOD TIER</promise>
```

### Checklist:
- [ ] All verification commands pass (exit 0)
- [ ] No hardcoded colors or font sizes
- [ ] All tap targets ≥44×44pt
- [ ] Dark mode works perfectly on all screens
- [ ] Empty states are beautiful with animated symbols
- [ ] Forms feel native iOS (match Apple Health app quality)
- [ ] Cards have consistent styling (corner radius, padding, materials)
- [ ] Typography hierarchy is clear and consistent
- [ ] `.sensoryFeedback` used for all user actions (no legacy haptics)
- [ ] `.symbolEffect` used for SF Symbol animations
- [ ] Animations respect reduced motion settings
- [ ] VoiceOver navigation is logical
- [ ] Screenshots of all screens reviewed and approved

---

## How to Iterate (Convergent Loop)

1. **Start:** Run `bd ready` to see pending UI/UX tasks
2. **Audit:** Take screenshots of current state
3. **Identify:** Find the most jarring UI issue
4. **Fix:** Make the smallest change that improves it
5. **Verify:** Run verification commands
6. **Record:** `bd done bd-xxx` and create new beads for found issues
7. **Screenshot:** Capture new state for comparison
8. **Repeat:** Until all screens are polished

---

## Migration Priorities (First Fixes)

Based on codebase audit, fix these FIRST:

1. **Remove Legacy Haptics** (blocking)
   - `CravingLogViewModel.swift:79` - uses `UINotificationFeedbackGenerator`
   - `UsageLogViewModel.swift:111` - uses `UINotificationFeedbackGenerator`
   - Move haptics to View layer using `.sensoryFeedback`

2. **ChipSelector Material** (visual)
   - Replace `Color(.systemGray5)` with `.ultraThinMaterial`
   - Add subtle shadow for depth

3. **Add Symbol Effects** (polish)
   - Empty state icons: `.symbolEffect(.pulse)`
   - Success checkmarks: `.symbolEffect(.bounce)`
   - Dashboard icons: `.symbolEffect(.bounce)` on appear

4. **Add Scroll Transitions** (premium feel)
   - Dashboard cards: fade/scale on scroll
   - List items: subtle entry animations

---

## Reference Design Standards

### Apple Health App (Gold Standard)
- Clean card-based layout with subtle materials
- Prominent metrics with clear hierarchy
- Subtle animations, no gimmicks
- Perfect Dark mode support
- Accessibility-first design

### Apple HIG Links
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
- [Color](https://developer.apple.com/design/human-interface-guidelines/color)
- [Materials](https://developer.apple.com/design/human-interface-guidelines/materials)

### iOS 18+ API References
- [MeshGradient](https://developer.apple.com/documentation/swiftui/meshgradient)
- [sensoryFeedback](https://developer.apple.com/documentation/swiftui/view/sensoryfeedback(_:trigger:))
- [symbolEffect](https://developer.apple.com/documentation/swiftui/view/symboleffect(_:options:value:))
- [scrollTransition](https://developer.apple.com/documentation/swiftui/view/scrolltransition(_:axis:transition:))

### iOS 26 Liquid Glass (Future)
- [Apple Announcement](https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/)
- [WWDC25 Session](https://developer.apple.com/videos/play/wwdc2025/323/)
- [Applying Liquid Glass](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)

---

## Context / Reference
- Tier 1 specs: `docs/MVP_PRODUCT_SPEC.md`, `docs/UX_FLOW_SPEC.md`, `docs/CLINICAL_CANNABIS_SPEC.md`
- Architecture: `CLAUDE.md`, `ARCHITECTURE.md`
- Previous work: App is functional, tests pass, this loop focuses purely on UI/UX polish

---

## Non-Goals (out of scope)
- New features
- Backend/data layer changes
- Test coverage expansion (unless UI-related)
- Performance optimization (unless visible jank)
- App Store submission assets

---

**Remember:** This is a *health app* for people in vulnerable moments. Every UI decision should prioritize:
1. **Clarity** — No confusion about what to do
2. **Calm** — Visual design that soothes, not stimulates
3. **Speed** — Get in, log, get out in <10 seconds
4. **Trust** — Feels like Apple made it
