# Cravey – Ralph Wiggum Loop Prompt (UI/UX Polish)

## Mission
Elevate Cravey's UI/UX to **GOD TIER Apple HIG compliance** — a premium, polished health app that feels native to iOS 18/26 and would make Apple's design team proud.

**Target:** Screenshot-perfect UI across all screens. Every pixel intentional. Zero jank.

---

## Hard Constraints (must not violate)
- **Privacy-first:** local-only data; no analytics; no tracking; no cloud sync; keep SwiftData `cloudKitDatabase: .none`.
- **Clean Architecture:** Presentation → Domain ← Data; Domain stays framework-free (no SwiftUI/SwiftData).
- **Motivational interviewing tone:** non-judgmental language (avoid "failure", "streak broken").
- **iOS 18+ minimum deployment target** (prepare for iOS 26 Liquid Glass when available).

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
1. At start of each iteration, run `bd ls --ready` to see actionable tasks
2. Create beads for each UI/UX issue found: `bd add "Fix X" --depends-on bd-xxx`
3. Mark completed: `bd done bd-xxx`
4. Track progress: `bd status`

---

## UI/UX Audit Checklist (Must Fix)

### Visual Polish Issues to Address

1. **Typography Hierarchy**
   - [ ] Consistent font weights (SF Pro Display for titles, SF Pro Text for body)
   - [ ] Proper Dynamic Type scaling (all text must scale 1x → 7x)
   - [ ] Line heights and letter spacing per Apple HIG

2. **Spacing & Layout**
   - [ ] Consistent 16pt/20pt grid system
   - [ ] Proper insets for safe areas
   - [ ] Card/container padding consistency
   - [ ] Remove awkward gaps or cramped sections

3. **Color System**
   - [ ] Semantic colors only (no hardcoded hex values)
   - [ ] Dark mode full support (test every screen)
   - [ ] Proper contrast ratios (WCAG AA minimum)
   - [ ] Accent color usage consistency

4. **Components**
   - [ ] All tap targets ≥44×44pt (Apple HIG requirement)
   - [ ] Buttons have proper hit states (pressed, disabled)
   - [ ] Form inputs match iOS native styling
   - [ ] Cards use proper corner radius (16pt standard)
   - [ ] `.ultraThinMaterial` for glassmorphism (iOS 26 ready)

5. **Animations & Transitions**
   - [ ] Sheet presentations use spring animations
   - [ ] Loading states have smooth transitions
   - [ ] Success/error feedback with haptics
   - [ ] Respect `UIAccessibility.isReduceMotionEnabled`

6. **Empty States**
   - [ ] Every list has a beautiful empty state
   - [ ] Use SF Symbols with proper sizing (60pt icons)
   - [ ] Encouraging copy, not just "No data"

7. **Navigation**
   - [ ] Tab bar icons consistent weight/style
   - [ ] Navigation titles use `.large` or `.inline` appropriately
   - [ ] Back buttons and toolbar items properly spaced

---

## Screen-by-Screen Audit Requirements

### Home Tab
- [ ] "Log Craving" / "Log Usage" buttons are prominent, not cramped
- [ ] Section headers ("Recent Cravings", "Recent Usage") have proper styling
- [ ] Empty states are warm and inviting
- [ ] Toast overlay doesn't interfere with navigation
- [ ] List items have sufficient padding

### Craving/Usage Log Forms
- [ ] Form sections have proper headers
- [ ] ChipSelector chips are properly sized and spaced
- [ ] IntensitySlider feels native (matches iOS sliders)
- [ ] TextEditor has visible border/background
- [ ] Character counters don't crowd the input
- [ ] Save button has loading state

### Dashboard Tab
- [ ] MetricCards have consistent styling
- [ ] Numbers are prominent (large, bold)
- [ ] Units are secondary (smaller, gray)
- [ ] Empty dashboard has beautiful placeholder
- [ ] Cards have proper shadow/elevation (subtle)

### Settings Tab
- [ ] List style matches iOS Settings app exactly
- [ ] Destructive actions are properly red
- [ ] Version info is properly styled
- [ ] Export/Delete flows feel native

---

## 2026 SwiftUI Best Practices (Apply Throughout)

### From Apple HIG + WWDC25
1. **Liquid Glass readiness** (iOS 26)
   - Use `.glassEffect()` for card backgrounds when available
   - Prepare for `GlassEffectContainer` adoption
   - Current fallback: `.ultraThinMaterial` backgrounds

2. **Modern SwiftUI patterns**
   - `@Observable` not `ObservableObject`
   - `NavigationStack` not `NavigationView`
   - `@Environment(Type.self)` not `@EnvironmentObject`
   - Deferred ViewModel initialization pattern

3. **Accessibility-first**
   - All views have `.accessibilityLabel()`
   - VoiceOver navigation is logical
   - Increase Contrast mode works
   - Bold Text setting works

4. **Performance**
   - `LazyVStack` for long lists
   - No unnecessary redraws (check with `Self._printChanges()`)
   - Image caching where applicable

---

## Verification (UI/UX Specific)

### Visual Verification (Manual + Automated)

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
swiftlint --config .swiftlint.yml Cravey/Presentation/Views/

# 4. No hardcoded colors (should use semantic colors)
! rg -n 'Color\(red:|Color\(#|UIColor\(' Cravey/Presentation/Views/

# 5. All tap targets are accessible
rg -n 'frame\(width:\s*[0-3][0-9],' Cravey/Presentation/Views/ && echo "WARNING: Small tap targets found"

# 6. Dynamic Type support check
rg -n '\.font\(\.system\(size:' Cravey/Presentation/Views/ && echo "WARNING: Fixed font sizes found"
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
- [ ] Empty states are beautiful and encouraging
- [ ] Forms feel native iOS (match Apple Health app quality)
- [ ] Cards have consistent styling (corner radius, padding, materials)
- [ ] Typography hierarchy is clear and consistent
- [ ] Animations respect reduced motion settings
- [ ] VoiceOver navigation is logical
- [ ] Screenshots of all screens reviewed and approved

---

## How to Iterate (Convergent Loop)

1. **Start:** Run `bd ls --ready` to see pending UI/UX tasks
2. **Audit:** Take screenshots of current state
3. **Identify:** Find the most jarring UI issue
4. **Fix:** Make the smallest change that improves it
5. **Verify:** Run verification commands
6. **Record:** `bd done bd-xxx` and create new beads for found issues
7. **Screenshot:** Capture new state for comparison
8. **Repeat:** Until all screens are polished

---

## Reference Design Standards

### Apple Health App (Gold Standard for Health Apps)
- Clean card-based layout
- Prominent metrics with clear hierarchy
- Subtle animations, no gimmicks
- Perfect Dark mode support
- Accessibility-first design

### Apple HIG Links
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Accessibility Guidelines](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [Typography Guidelines](https://developer.apple.com/design/human-interface-guidelines/typography)
- [Color Guidelines](https://developer.apple.com/design/human-interface-guidelines/color)

### iOS 26 Liquid Glass Resources
- [Apple Liquid Glass Announcement](https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/)
- [Build a SwiftUI app with the new design - WWDC25](https://developer.apple.com/videos/play/wwdc2025/323/)
- [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)

---

## Context / Reference (do not treat as acceptance criteria)
- Tier 1 specs: `docs/MVP_PRODUCT_SPEC.md`, `docs/UX_FLOW_SPEC.md`, `docs/CLINICAL_CANNABIS_SPEC.md`
- Architecture: `CLAUDE.md`, `ARCHITECTURE.md`
- Previous work: App is functional, tests pass, this loop focuses purely on UI/UX polish

---

## Non-Goals (out of scope for this loop)
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
