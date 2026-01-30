# DEBT-031: Form Toolbar Pattern Duplicated

**Priority:** P3 (Architecture - DRY Violation)
**Status:** OPEN
**Created:** 2026-01-28

## Problem

Cancel/Save toolbar buttons are **98% identical** across two forms - 18 lines each.

---

## Duplicated Code

### CravingLogForm.swift (lines 89-106)
### UsageLogForm.swift (lines 96-113)

*(Verified: Both have Cancel/Save ToolbarItems with nearly identical structure)*

```swift
.toolbar {
    ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
            dismiss()
        }
        .accessibilityIdentifier("cravingFormCancelButton")
    }

    ToolbarItem(placement: .confirmationAction) {
        Button("Save") {
            Task {
                await viewModel.logCraving()  // or logUsage()
            }
        }
        .disabled(!viewModel.canSubmit || viewModel.isLoading)
        .accessibilityIdentifier("cravingFormSaveButton")
    }
}
```

---

## Rob C. Martin Fix: ViewModifier Extension

```swift
// Cravey/Presentation/Views/Modifiers/FormToolbarModifier.swift

import SwiftUI

/// Protocol for ViewModels that can be saved
@MainActor
protocol Saveable: AnyObject {
    var canSubmit: Bool { get }
    var isLoading: Bool { get }
}

extension View {
    /// Standard form toolbar with Cancel and Save buttons
    func formToolbar<VM: Saveable>(
        cancelId: String,
        saveId: String,
        viewModel: VM,
        onSave: @escaping () async -> Void
    ) -> some View {
        self.toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    // Relies on @Environment(\.dismiss)
                }
                .accessibilityIdentifier(cancelId)
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        await onSave()
                    }
                }
                .disabled(!viewModel.canSubmit || viewModel.isLoading)
                .accessibilityIdentifier(saveId)
            }
        }
    }
}

// MARK: - Alternative: Custom Toolbar ViewModifier

struct FormToolbarModifier<VM: Saveable & Observable>: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: VM
    let cancelId: String
    let saveId: String
    let onSave: () async -> Void

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .accessibilityIdentifier(cancelId)
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        await onSave()
                    }
                }
                .disabled(!viewModel.canSubmit || viewModel.isLoading)
                .accessibilityIdentifier(saveId)
            }
        }
    }
}

// MARK: - Usage

// Before (18 lines each):
.toolbar { ... }

// After:
.modifier(FormToolbarModifier(
    viewModel: viewModel,
    cancelId: "cravingFormCancelButton",
    saveId: "cravingFormSaveButton",
    onSave: { await viewModel.logCraving() }
))
```

---

## Files to Modify

| File | Change |
|------|--------|
| Create `Cravey/Presentation/Views/Modifiers/FormToolbarModifier.swift` | New modifier |
| `CravingLogForm.swift` | Replace 18 lines with modifier |
| `UsageLogForm.swift` | Replace 18 lines with modifier |

---

## Acceptance Criteria

- [ ] `FormToolbarModifier` created
- [ ] Both forms use shared toolbar modifier
- [ ] ~36 lines of duplicated code removed
- [ ] All tests pass
