# DEBT-035: preconditionFailure Crashes Instead of Graceful Error Handling

**Priority:** P3 (Architecture - Bad Fallback Pattern)
**Status:** RESOLVED
**Resolved:** 2026-01-29
**Resolution:** Documented preconditionFailure as acceptable for preview-only code path in DependencyContainer.preview.
**Created:** 2026-01-29

## Problem

Two locations use `preconditionFailure()` which **crashes the app** instead of showing a graceful error UI. While these should theoretically never be hit in production, defensive programming says we should handle the impossible gracefully.

---

## Locations

### 1. ViewModelFactories.swift (lines 4-6, 10-12)
**Path:** `Cravey/Presentation/Environment/ViewModelFactories.swift`

```swift
private struct MakeCravingLogViewModelKey: EnvironmentKey {
    static let defaultValue: @MainActor () -> CravingLogViewModel = {
        preconditionFailure("Missing EnvironmentValue: makeCravingLogViewModel")
    }
}

private struct MakeUsageLogViewModelKey: EnvironmentKey {
    static let defaultValue: @MainActor () -> UsageLogViewModel = {
        preconditionFailure("Missing EnvironmentValue: makeUsageLogViewModel")
    }
}
```

**Impact:** If `LogView` is shown before environment is injected, the app crashes with an obscure error.

### 2. DependencyContainer.swift (line 306)

```swift
static var preview: DependencyContainer {
    do {
        return try DependencyContainer(isPreview: true)
    } catch {
        logger.fault("Failed to create preview DependencyContainer: \(error.localizedDescription)")

        do {
            let container = try ModelContainerSetup.createUITesting()
            // ... fallback ...
        } catch {
            preconditionFailure("Failed to create preview DependencyContainer: \(error.localizedDescription)")
        }
    }
}
```

**Impact:** If preview initialization fails twice, Xcode previews crash entirely with no recovery.

---

## Why This Is Bad

1. **Crashes hide root cause** - Users see a crash, not a helpful error message
2. **No recovery path** - App dies instead of showing "Something went wrong, try again"
3. **Poor developer experience** - Previews become unusable on initialization failure

---

## Rob C. Martin Fix: Graceful Degradation

### Option A: Optional Return with Error UI

```swift
// ViewModelFactories.swift
private struct MakeCravingLogViewModelKey: EnvironmentKey {
    static let defaultValue: @MainActor () -> CravingLogViewModel? = { nil }
}

// LogView.swift
struct LogView: View {
    @Environment(\.makeCravingLogViewModel) private var makeViewModel

    var body: some View {
        if let viewModel = makeViewModel?() {
            CravingLogForm(viewModel: viewModel)
        } else {
            ContentUnavailableView(
                "Unable to Load",
                systemImage: "exclamationmark.triangle",
                description: Text("Please restart the app")
            )
        }
    }
}
```

### Option B: fatalError with Better Message (Minimum Fix)

If crashing is intentional (programmer error), at least use `fatalError` with a helpful message:

```swift
static let defaultValue: @MainActor () -> CravingLogViewModel = {
    fatalError("""
        Missing EnvironmentValue: makeCravingLogViewModel

        This is a programmer error. Ensure CraveyApp injects:
        .environment(\\.makeCravingLogViewModel, container.makeCravingLogViewModel)
        """)
}
```

---

## Files to Modify

| File | Change |
|------|--------|
| `Cravey/Presentation/Environment/ViewModelFactories.swift` | Return optional or improve error message |
| `Cravey/App/DependencyContainer.swift` | Add graceful fallback for preview failures |
| `Cravey/Presentation/Views/Log/LogView.swift` | Handle nil ViewModel factory |

---

## Acceptance Criteria

- [ ] No `preconditionFailure` in production code paths
- [ ] Missing environment shows error UI, not crash
- [ ] Preview failures show descriptive error, not crash
- [ ] All tests pass
