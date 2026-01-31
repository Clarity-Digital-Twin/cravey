@testable import Cravey
import Foundation
import Testing

@Suite("UsageLogViewModel Tests (Phase 2C)")
@MainActor
struct UsageLogViewModelTests {
    // MARK: - Test 1: canSubmit Validation

    @Test("canSubmit should validate method and amount")
    func testCanSubmit() {
        let mockUseCase = MockLogUsageUseCase()
        let viewModel = UsageLogViewModel(logUsageUseCase: mockUseCase)

        // Valid state
        viewModel.selectedMethod = "Bowls"
        viewModel.amount = 2.5
        #expect(viewModel.canSubmit == true)

        // Invalid: zero amount
        viewModel.amount = 0
        #expect(viewModel.canSubmit == false)

        // Invalid: empty method (edge case)
        viewModel.selectedMethod = ""
        #expect(viewModel.canSubmit == false)
    }

    // MARK: - Test 2: logUsage Success

    @Test("logUsage should show success toast on success (not alert)")
    func logUsageSuccess() async {
        let mockUseCase = MockLogUsageUseCase()
        let viewModel = UsageLogViewModel(logUsageUseCase: mockUseCase)

        viewModel.selectedMethod = "Vape"
        viewModel.amount = 5.0

        await viewModel.logUsage()

        // Should signal success to parent (UX_FLOW:396-405)
        #expect(viewModel.didSucceed == true)
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - Test 3: updateAmountForMethod

    @Test("updateAmountForMethod should reset amount to first valid option")
    func testUpdateAmountForMethod() {
        let mockUseCase = MockLogUsageUseCase()
        let viewModel = UsageLogViewModel(logUsageUseCase: mockUseCase)

        // Change to Edible (first option is 5.0)
        viewModel.selectedMethod = "Edible"
        viewModel.updateAmountForMethod()

        #expect(viewModel.amount == 5.0)

        // Change to Vape (first option is 1.0)
        viewModel.selectedMethod = "Vape"
        viewModel.updateAmountForMethod()

        #expect(viewModel.amount == 1.0)
    }

    // MARK: - Test 4: Notes Character Limit

    @Test("Notes should enforce 500 character limit")
    func notesCharacterLimit() {
        let mockUseCase = MockLogUsageUseCase()
        let viewModel = UsageLogViewModel(logUsageUseCase: mockUseCase)

        // Set notes to 501 characters (should truncate to 500)
        let longNotes = String(repeating: "a", count: TestConstants.Notes.overMaxLength)
        viewModel.notes = longNotes

        #expect(viewModel.notes.count == TestConstants.Notes.atMaxLength)
        #expect(viewModel.notesCharacterCount == TestConstants.Notes.atMaxLength)
        #expect(viewModel.shouldShowNotesCounter == true)
    }

    // MARK: - Test 5: Old Timestamp Warning

    @Test("Timestamp >7 days old should trigger warning")
    func oldTimestampWarning() {
        let mockUseCase = MockLogUsageUseCase()
        let now = TestConstants.fixedEpoch
        let viewModel = UsageLogViewModel(logUsageUseCase: mockUseCase, nowProvider: { now })

        // Set timestamp to 8 days ago
        let eightDaysAgo = Calendar.current.date(byAdding: .day, value: -8, to: now) ?? now
        viewModel.timestamp = eightDaysAgo

        #expect(viewModel.isTimestampOld == true)
    }
}

// MARK: - Mocks

actor MockLogUsageUseCase: LogUsageUseCase {
    func execute(_ request: LogUsageRequest) async throws -> UsageEntity {
        UsageEntity(
            timestamp: request.timestamp,
            method: request.method,
            amount: request.amount,
            triggers: request.triggers,
            location: request.location,
            notes: request.notes
        )
    }
}
