# Cravey – Ralph Wiggum Loop Prompt (Home Screen Polish)

## Mission
Polish the **Home Screen** with essential UX features: **swipe-to-delete** for logs and a **meaningful title** that reflects the app's purpose.

**Target:** Home screen feels complete, functional, and native iOS.

---

## Hard Constraints (must not violate)
- **Privacy-first:** local-only data; no analytics; no tracking; no cloud sync; keep SwiftData `cloudKitDatabase: .none`.
- **Clean Architecture:** Presentation → Domain ← Data; Domain stays framework-free (no SwiftUI/SwiftData).
- **Motivational interviewing tone:** non-judgmental language (avoid "failure", "streak broken").
- **iOS 18+ minimum deployment target**.

---

## Focus Tasks (This Loop)

### 1. Swipe-to-Delete for Logs

**Problem:** Users can log cravings and usage, but there's NO way to delete them. If someone accidentally logs something, they're stuck with it.

**Solution:** Add standard iOS swipe-to-delete gesture to both:
- **Recent Cravings** list items
- **Recent Usage** list items

**Implementation Requirements:**
- Use `.swipeActions(edge: .trailing)` modifier on list rows
- Red destructive delete button with trash icon
- Confirmation alert before permanent deletion (this is sensitive data!)
- Call appropriate delete use case through ViewModel
- Add haptic feedback (`.sensoryFeedback(.warning)` on swipe reveal)
- Animate row removal smoothly

**Files to Modify:**
- `Cravey/Presentation/Views/Home/CravingListView.swift` - Add swipe action
- `Cravey/Presentation/Views/Usage/UsageListView.swift` - Add swipe action
- `Cravey/Presentation/ViewModels/CravingListViewModel.swift` - Add delete method
- `Cravey/Presentation/ViewModels/UsageListViewModel.swift` - Add delete method
- `Cravey/Domain/UseCases/` - May need DeleteCravingUseCase, DeleteUsageUseCase
- `Cravey/Domain/Repositories/` - Check if delete methods exist in protocols
- `Cravey/Data/Repositories/` - Implement delete if needed

**Reference Pattern:**
```swift
ForEach(items) { item in
    ItemRow(item: item)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                itemToDelete = item
                showDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
}
.alert("Delete Log?", isPresented: $showDeleteConfirmation) {
    Button("Cancel", role: .cancel) {}
    Button("Delete", role: .destructive) {
        Task { await viewModel.delete(itemToDelete) }
    }
} message: {
    Text("This cannot be undone.")
}
.sensoryFeedback(.success, trigger: didDelete)
```

---

### 2. Better Home Screen Title

**Problem:** "Home" is generic and meaningless. Doesn't tell user what this screen is for.

**Options to Consider:**
- "Cannabis Logs" - Direct, clear
- "My Logs" - Personal, simple
- "Tracking" - Action-oriented
- "Journal" - Recovery-focused
- Keep "Home" as tab name, but use a different navigationTitle

**Implementation:**
- Update `HomeView.swift` `.navigationTitle()`
- Consider if subtitle/header would add context
- Tab bar can stay "Home" if that makes sense for navigation

**User's Preference:** Something more relevant than just "Home" - suggests "Cannabis Logs" or similar.

---

## Verification

### Automated Checks
```bash
set -euo pipefail

# 1. Build succeeds
xcodebuild -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build 2>&1 | xcbeautify

# 2. All tests pass
xcodebuild test -scheme Cravey \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:CraveyTests 2>&1 | xcbeautify

# 3. Verify swipe actions exist in list views
rg -n 'swipeActions' Cravey/Presentation/Views/ || echo "FAIL: No swipe actions found"

# 4. Verify delete functionality exists
rg -n 'delete|Delete' Cravey/Presentation/ViewModels/CravingListViewModel.swift || echo "WARNING: No delete in CravingListViewModel"
rg -n 'delete|Delete' Cravey/Presentation/ViewModels/UsageListViewModel.swift || echo "WARNING: No delete in UsageListViewModel"
```

### Manual Verification
1. Launch app in Simulator
2. Log a test craving
3. Swipe left on the craving row → Delete button appears
4. Tap Delete → Confirmation alert appears
5. Confirm delete → Row animates away, haptic feedback fires
6. Repeat for Usage logs
7. Verify Home screen title is updated and meaningful

---

## Definition of Done

When **ALL** of the following are true, output:

```
<promise>HOME SCREEN COMPLETE</promise>
```

### Checklist:
- [ ] Swipe-to-delete works on Craving list items
- [ ] Swipe-to-delete works on Usage list items
- [ ] Delete shows confirmation alert (prevent accidents)
- [ ] Delete actually removes from database (persists after app restart)
- [ ] Haptic feedback on delete action
- [ ] Smooth row removal animation
- [ ] Home screen title updated to something meaningful
- [ ] Build succeeds
- [ ] All unit tests pass
- [ ] No regressions in existing functionality

---

## Architecture Notes

### Clean Architecture Delete Flow
```
View (swipe action)
  → ViewModel.delete(entity)
    → DeleteUseCase.execute(id)
      → Repository.delete(id)
        → ModelContext.delete(model)
```

### Existing Patterns to Follow
- Look at `LogCravingUseCase` for use case pattern
- Look at `CravingRepository` for repository pattern
- Look at `SettingsView` delete flow for confirmation dialog pattern

---

## Non-Goals (out of scope this loop)
- Dashboard changes
- Settings changes
- New features beyond delete
- Form modifications
- Recording functionality

---

## Context Files
- `Cravey/Presentation/Views/Home/HomeView.swift` - Main home screen
- `Cravey/Presentation/Views/Home/CravingListView.swift` - Craving list
- `Cravey/Presentation/Views/Usage/UsageListView.swift` - Usage list
- `CLAUDE.md` - Architecture reference

---

**Remember:** This is about making the Home screen **functional and complete**. Users need to be able to fix mistakes by deleting accidental logs.
