# DEBT-028: Delete Confirmation Dialog Duplicated in List Views

**Priority:** P3 (Architecture - DRY Violation)
**Status:** OPEN
**Created:** 2026-01-28

## Problem

Delete confirmation dialog is **100% identical** across two list views - 21 lines each.

---

## Duplicated Code

### CravingListView.swift (lines 40-60)
### UsageListView.swift (lines 39-59)

*(Verified: Both patterns are identical except for entity names)*

```swift
.confirmationDialog(
    "Delete Craving?",
    isPresented: Binding(
        get: { itemToDelete != nil },
        set: { if !$0 { itemToDelete = nil } }
    ),
    titleVisibility: .visible
) {
    Button("Delete", role: .destructive) {
        guard let itemToDelete else { return }
        self.itemToDelete = nil
        Task {
            await viewModel.deleteCraving(id: itemToDelete.id)
        }
    }
    Button("Cancel", role: .cancel) {
        itemToDelete = nil
    }
} message: {
    Text("This cannot be undone.")
}
```

---

## Rob C. Martin Fix: ViewModifier Extension

```swift
// Cravey/Presentation/Views/Modifiers/DeleteConfirmationModifier.swift

import SwiftUI

extension View {
    /// Reusable delete confirmation dialog
    func deleteConfirmation<Item: Identifiable>(
        itemType: String,
        item: Binding<Item?>,
        onDelete: @escaping (Item) async -> Void
    ) -> some View {
        self.confirmationDialog(
            "Delete \(itemType)?",
            isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: { if !$0 { item.wrappedValue = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                guard let itemToDelete = item.wrappedValue else { return }
                item.wrappedValue = nil
                Task {
                    await onDelete(itemToDelete)
                }
            }
            Button("Cancel", role: .cancel) {
                item.wrappedValue = nil
            }
        } message: {
            Text("This cannot be undone.")
        }
    }
}

// MARK: - Usage

// Before (21 lines each):
.confirmationDialog("Delete Craving?", ...)

// After (1 line each):
.deleteConfirmation(itemType: "Craving", item: $itemToDelete) { item in
    await viewModel.deleteCraving(id: item.id)
}
```

---

## Files to Modify

| File | Change |
|------|--------|
| Create `Cravey/Presentation/Views/Modifiers/DeleteConfirmationModifier.swift` | New modifier |
| `CravingListView.swift` | Replace 21 lines with `.deleteConfirmation()` |
| `UsageListView.swift` | Replace 21 lines with `.deleteConfirmation()` |

---

## Acceptance Criteria

- [ ] `deleteConfirmation` modifier created
- [ ] Both list views use modifier instead of duplicated code
- [ ] ~42 lines of duplicated code removed
- [ ] All tests pass
