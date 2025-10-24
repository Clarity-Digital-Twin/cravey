# Cravey UX Flow Specification

**Version:** 1.0
**Last Updated:** 2025-10-24
**Status:** 🚧 In Progress - Mapping User Journeys

---

## 🔖 Purpose

This document maps **screen-by-screen user flows** for all 7 MVP features. It translates clinical requirements (CLINICAL_CANNABIS_SPEC.md) and product features (MVP_PRODUCT_SPEC.md) into **tangible UI patterns** that feel natural, fast, and compassionate.

**What This Document Defines:**
- Navigation architecture (tabs, modals, sheets)
- Screen layouts (wireframe descriptions, not pixel-perfect)
- State transitions (User taps X → Screen shows Y → If Z, then...)
- Error states, empty states, loading states
- Component reuse patterns (DRY principle)

**What This Document Does NOT Define:**
- Exact pixel dimensions or colors (implementation detail)
- Animation timing/curves (implementation detail)
- Specific SF Symbol names (implementation detail)

---

## 📐 General Design Guidelines (2025 SwiftUI Best Practices)

### **1. Architecture Patterns**

**Navigation:**
- **NavigationStack** (iOS 16+) - NOT NavigationView (deprecated)
- **Tab Bar** (4 tabs) - Persistent at bottom, hides when modal is open
  - Tab 1: **Home** (Quick action hub)
  - Tab 2: **Progress** (Dashboard with charts)
  - Tab 3: **Recordings** (Video/audio library)
  - Tab 4: **Settings** (Data management, AI chat, permissions)
- **Bottom Sheets** - For contextual, dismissible actions (Log Craving/Usage forms)
- **Full-Screen Modals** - For separate modes (Recording video/audio)
- **Alerts** - For destructive actions (Delete All Data confirmation)

**State Management:**
- `@Observable` for ViewModels (Swift 6)
- `@State` for local view state (picker selection, text input)
- Unidirectional data flow: User action → ViewModel → Update state → View re-renders

---

### **2. Component Library (Reusable UI Elements)**

**Purpose:** Consistent UI, less code, easier maintenance. Build once, use everywhere.

#### **Core Components:**

1. **`LogFormSheet`** - Bottom sheet wrapper
   - Single scrollable `Form { }` (Apple Health style)
   - Auto-dismisses on save or swipe-down
   - Used by: Craving logging, Usage logging

2. **`ChipSelector`** - Multi-select or single-select chips
   - Horizontal scrolling row of tappable pills
   - Used by: Triggers (multi-select), Location (single-select), ROA (single-select)

3. **`PickerWheelInput`** - Context-aware amount picker
   - SwiftUI `Picker` with `.wheel` style
   - Dynamic ranges based on ROA (0.5→5.0 for bowls, 5mg→100mg for edibles)
   - Used by: Usage logging (amount field)

4. **`IntensitySlider`** - 1-10 slider with visual feedback
   - Color-coded: 1-3 green (mild), 4-6 yellow (moderate), 7-9 orange (strong), 10 red (overwhelming)
   - Haptic feedback on value change
   - Used by: Craving logging (intensity field)

5. **`TimestampPicker`** - Date/time picker with "Now" default
   - Auto-populates to current time
   - Shows warning if >7 days in past (clinical memory reliability threshold)
   - Used by: Both craving and usage logging

6. **`ChartCard`** - Reusable dashboard metric container
   - Title + subtitle + Swift Charts visualization
   - Tap to expand detail view
   - Used by: All 11 dashboard metrics

7. **`EmptyStateView`** - Placeholder for no data
   - Friendly illustration + message + optional CTA
   - Used by: Dashboard (< 7 days of data), Recordings (no recordings yet)

8. **`PrimaryActionButton`** - Large, clear CTA
   - Minimum 44x44pt tap target (Apple HIG)
   - High contrast, accessible
   - Used by: "Log Craving", "Log Usage", "Record" buttons

---

### **3. Crisis-Optimized UX Principles**

**Users may be in crisis → Design for cognitive load:**

✅ **Large Tap Targets** - Minimum 44x44pt (Apple HIG standard)
✅ **Clear Primary Actions** - One obvious next step per screen
✅ **Minimal Decisions** - Default to "Now" for timestamp, pre-populate common choices
✅ **Quick Escape** - Swipe-to-dismiss sheets (don't trap users)
✅ **Progressive Disclosure** - Required fields first, optional fields below divider
✅ **Instant Feedback** - Save confirmation, haptic feedback on actions

---

### **4. Accessibility (Non-Negotiable)**

✅ **Dynamic Type** - All text scales with user settings (1x → 7x size)
✅ **SF Symbols** - Native icons that adapt to dark mode, size, weight
✅ **VoiceOver Support** - All buttons labeled, forms navigable
✅ **High Contrast** - Works in light mode, dark mode, increased contrast
✅ **Reduced Motion** - Respects accessibility settings (no essential info in animations)

---

### **5. Performance Targets**

- **Craving log**: <10 sec (required fields only)
- **Usage log**: <10 sec (required fields only)
- **Dashboard load**: <2 sec (even with 90+ days of data)
- **Recording start**: <1 sec (tap "Record" → camera active)

---

### **6. Privacy Messaging**

**Persistent reassurance across all screens:**
- Onboarding: "All data stays on your device. No cloud sync."
- Location permission request: "Location data never leaves your device."
- Settings: "Your data is private and local-only."

---

## 🧭 User Flows (7 Features)

### **Flow 1: First Launch & Onboarding**

**Goal:** Get user to first craving/usage log in <60 seconds

**Screens:**

#### Screen 1.1: Welcome
**Layout:**
- [ ] App icon + name
- [ ] Tagline: "Private cannabis tracking and support"
- [ ] Subtext: "All data stays on your device. No cloud sync."
- [ ] Primary button: "Get Started"
- [ ] Skip button: "Skip Tour" (goes straight to Home)

**Navigation:**
- Tap "Get Started" → Screen 1.2 (Optional Tour)
- Tap "Skip Tour" → Home tab (Flow 2)

---

#### Screen 1.2: Optional Tour (Swipeable Cards)
**Layout:**
- [ ] Card 1: "Track Cravings" - Illustration + "Log intensity, triggers, location in <10 seconds"
- [ ] Card 2: "Track Usage" - Illustration + "Track what you use, when, and why"
- [ ] Card 3: "Record Motivational Content" - Illustration + "Create videos/audio to watch during cravings"
- [ ] Card 4: "See Your Patterns" - Illustration + "Insights emerge after 7 days of tracking"
- [ ] Bottom: "Done" button

**Navigation:**
- Swipe through cards (optional, skippable)
- Tap "Done" → Home tab (Flow 2)

**Note:** Permissions (camera/mic/location) requested CONTEXTUALLY when first needed, NOT here

---

### **Flow 2: Home Tab (Daily Hub)**

**Goal:** Fast access to primary actions (log craving, log usage, record)

**Screen 2.1: Home**
**Layout:**
- [ ] TO BE DESIGNED SOCRATICALLY

**Navigation:**
- [ ] TO BE MAPPED SOCRATICALLY

---

### **Flow 3: Log Craving (Bottom Sheet Form)**

**Goal:** Log in <10 seconds (intensity + timestamp minimum)

**Screen 3.1: Craving Log Form**
**Layout:**
- [ ] TO BE DESIGNED SOCRATICALLY

**Navigation:**
- [ ] TO BE MAPPED SOCRATICALLY

---

### **Flow 4: Log Usage (Bottom Sheet Form)**

**Goal:** Log in <10 seconds (ROA + amount + timestamp minimum)

**Screen 4.1: Usage Log Form**
**Layout:**
- [ ] TO BE DESIGNED SOCRATICALLY

**Navigation:**
- [ ] TO BE MAPPED SOCRATICALLY

---

### **Flow 5: Recordings Tab**

**Goal:** Record motivational content, play during cravings

**Screen 5.1: Recordings Library**
**Layout:**
- [ ] TO BE DESIGNED SOCRATICALLY

**Navigation:**
- [ ] TO BE MAPPED SOCRATICALLY

---

### **Flow 6: Progress Dashboard Tab**

**Goal:** Show patterns after 7 days of data

**Screen 6.1: Dashboard (Empty State)**
**Layout:**
- [ ] TO BE DESIGNED SOCRATICALLY

**Screen 6.2: Dashboard (With Data)**
**Layout:**
- [ ] TO BE DESIGNED SOCRATICALLY

**Navigation:**
- [ ] TO BE MAPPED SOCRATICALLY

---

### **Flow 7: Settings Tab**

**Goal:** Data export, AI chat setup, permissions management

**Screen 7.1: Settings**
**Layout:**
- [ ] TO BE DESIGNED SOCRATICALLY

**Navigation:**
- [ ] TO BE MAPPED SOCRATICALLY

---

## 🚧 Status

**Completed:**
- ✅ General design guidelines
- ✅ Component library defined
- ✅ Onboarding flow (Screen 1.1, 1.2)

**In Progress:**
- 🚧 Flow 2: Home Tab

**Not Started:**
- 🔴 Flow 3: Log Craving
- 🔴 Flow 4: Log Usage
- 🔴 Flow 5: Recordings Tab
- 🔴 Flow 6: Progress Dashboard Tab
- 🔴 Flow 7: Settings Tab

---

**Next Step:** Design Home Tab (Flow 2) - the daily hub users return to 10x/day
