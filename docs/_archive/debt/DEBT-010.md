# DEBT-010: Home Motivation Card Not Backed by Message Repository

**Priority:** P3 (Architecture / Feature Completeness)
**Status:** CLOSED (2026-01-27)
**Created:** 2026-01-27
**Last Audited:** 2026-01-27

## Problem (Resolved)

HomeView now fetches motivational messages from `MessageRepository` instead of using static defaults. The message selection tracks `timesShown` and `lastShownAt` for future analytics and personalization.

## Solution Implemented

1. **Domain Layer - Use Cases:**
   - `SelectMotivationalMessageUseCase` - Selects one active message, preferring least-shown
   - `MarkMessageShownUseCase` - Increments `timesShown`, sets `lastShownAt`

2. **Presentation Layer:**
   - `HomeMotivationViewModel` - Manages message loading and shown-tracking
   - `HomeView` - Now uses `HomeMotivationViewModel` instead of static property

3. **DependencyContainer:**
   - Added use case wiring for motivation messages
   - Added `makeHomeMotivationViewModel()` factory method

4. **CraveyApp:**
   - Injects `HomeMotivationViewModel` into environment

## Acceptance Criteria

- [x] Home motivation message is fetched from `MessageRepository` (not hard-coded)
- [x] Displaying a message updates `timesShown` / `lastShownAt`
- [x] Unit tests cover selection + metadata updates

## Files Changed

- `Cravey/Domain/UseCases/SelectMotivationalMessageUseCase.swift` - NEW
- `Cravey/Domain/UseCases/MarkMessageShownUseCase.swift` - NEW
- `Cravey/Presentation/ViewModels/HomeMotivationViewModel.swift` - NEW
- `Cravey/Presentation/Views/Home/HomeView.swift` - Uses ViewModel instead of static
- `Cravey/App/DependencyContainer.swift` - Wiring + factory
- `Cravey/App/CraveyApp.swift` - Environment injection
- `CraveyTests/Domain/UseCases/SelectMotivationalMessageUseCaseTests.swift` - 4 tests
- `CraveyTests/Domain/UseCases/MarkMessageShownUseCaseTests.swift` - 3 tests
- `CraveyTests/Presentation/ViewModels/HomeMotivationViewModelTests.swift` - 7 tests

## Test Count (as of closure)

69 tests total (+14 new tests for this debt item)

_Note: Test count has grown since closure. See current verify.sh output for latest._
