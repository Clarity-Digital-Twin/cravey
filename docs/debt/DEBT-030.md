# DEBT-030: Empty State Component Duplicated

**Priority:** P3 (Architecture - DRY Violation)
**Status:** OPEN
**Created:** 2026-01-28

## Problem

`EmptyStatePlaceholder` struct is **95% identical** across two list views - 24 lines each.

---

## Duplicated Code

### CravingListView.swift (lines 121-145, struct `EmptyStatePlaceholder`)
### UsageListView.swift (lines 104-128, struct `UsageEmptyStateView`)

```swift
private struct EmptyStatePlaceholder: View {
    @State private var animateSymbol = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                .symbolEffect(.pulse, options: .repeating.speed(0.5), value: animateSymbol)

            Text("No Cravings Logged")  // or "No Usage Logged"
                .font(.headline)

            Text("Your cravings will appear here...")  // Different text
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .onAppear { animateSymbol = true }
    }
}
```

---

## Rob C. Martin Fix: Parameterized Reusable Component

```swift
// Cravey/Presentation/Views/Components/EmptyStateView.swift

import SwiftUI

/// Reusable empty state placeholder for list views
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    @State private var animateSymbol = false

    init(
        icon: String = "leaf.circle",
        title: String,
        subtitle: String
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                .symbolEffect(.pulse, options: .repeating.speed(0.5), value: animateSymbol)

            Text(title)
                .font(.headline)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .onAppear { animateSymbol = true }
    }
}

// MARK: - Convenience Initializers

extension EmptyStateView {
    static var cravings: EmptyStateView {
        EmptyStateView(
            icon: "brain.head.profile",
            title: "No Cravings Logged",
            subtitle: "Your cravings will appear here once you start logging them."
        )
    }

    static var usage: EmptyStateView {
        EmptyStateView(
            icon: "leaf.circle",
            title: "No Usage Logged",
            subtitle: "Your usage history will appear here."
        )
    }
}

// MARK: - Usage

// Before (24 lines each, defined inside view file):
private struct EmptyStatePlaceholder: View { ... }

// After (1 line each):
EmptyStateView.cravings
EmptyStateView.usage
```

---

## Files to Modify

| File | Change |
|------|--------|
| Create `Cravey/Presentation/Views/Components/EmptyStateView.swift` | Parameterized component |
| `CravingListView.swift` | Remove `EmptyStatePlaceholder`, use `EmptyStateView.cravings` |
| `UsageListView.swift` | Remove `EmptyStatePlaceholder`, use `EmptyStateView.usage` |

---

## Acceptance Criteria

- [ ] `EmptyStateView` created as parameterized component
- [ ] Both list views use shared component
- [ ] ~48 lines of duplicated code removed
- [ ] All tests pass
