@testable import Cravey
import Foundation
import Testing

@Suite("HomeMotivationViewModel Tests")
struct HomeMotivationViewModelTests {
    // MARK: - Test 1: loadMessage populates currentMessage

    @Test("loadMessage should populate currentMessage on success")
    @MainActor
    func loadMessageSuccess() async {
        let mockSelect = MockSelectUseCase(messageToReturn: MotivationalMessageEntity(
            content: "You can do it!",
            category: .urge
        ))
        let mockMark = MockMarkShownUseCase()

        let viewModel = HomeMotivationViewModel(
            selectMessageUseCase: mockSelect,
            markShownUseCase: mockMark
        )

        await viewModel.loadMessage()

        #expect(viewModel.currentMessage == "You can do it!")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - Test 2: loadMessage uses fallback when nil

    @Test("loadMessage should use fallback when repository returns nil")
    @MainActor
    func loadMessageFallback() async {
        let mockSelect = MockSelectUseCase(messageToReturn: nil)
        let mockMark = MockMarkShownUseCase()

        let viewModel = HomeMotivationViewModel(
            selectMessageUseCase: mockSelect,
            markShownUseCase: mockMark
        )

        await viewModel.loadMessage()

        #expect(viewModel.currentMessage == "You're making progress. Every day counts.")
    }

    // MARK: - Test 3: loadMessage handles errors

    @Test("loadMessage should use fallback on error")
    @MainActor
    func loadMessageError() async {
        let mockSelect = MockSelectUseCase(shouldThrow: true)
        let mockMark = MockMarkShownUseCase()

        let viewModel = HomeMotivationViewModel(
            selectMessageUseCase: mockSelect,
            markShownUseCase: mockMark
        )

        await viewModel.loadMessage()

        #expect(viewModel.currentMessage == "You're making progress. Every day counts.")
        #expect(viewModel.errorMessage == "Unable to load message")
    }

    // MARK: - Test 4: loadMessage only loads once

    @Test("loadMessage should not reload if message already loaded")
    @MainActor
    func loadMessageOnlyOnce() async {
        let mockSelect = MockSelectUseCase(messageToReturn: MotivationalMessageEntity(
            content: "First message",
            category: .urge
        ))
        let mockMark = MockMarkShownUseCase()

        let viewModel = HomeMotivationViewModel(
            selectMessageUseCase: mockSelect,
            markShownUseCase: mockMark
        )

        await viewModel.loadMessage()
        let callCount1 = await mockSelect.executeCallCount

        // Change what the mock would return
        await mockSelect.setMessageToReturn(MotivationalMessageEntity(
            content: "Second message",
            category: .anxiety
        ))

        await viewModel.loadMessage()
        let callCount2 = await mockSelect.executeCallCount

        // Should still show first message, and not have called execute again
        #expect(viewModel.currentMessage == "First message")
        #expect(callCount1 == 1)
        #expect(callCount2 == 1)
    }

    // MARK: - Test 5: markMessageShown calls use case

    @Test("markMessageShown should call use case with entity")
    @MainActor
    func markMessageShownCallsUseCase() async {
        let entity = MotivationalMessageEntity(content: "Test", category: .urge)
        let mockSelect = MockSelectUseCase(messageToReturn: entity)
        let mockMark = MockMarkShownUseCase()

        let viewModel = HomeMotivationViewModel(
            selectMessageUseCase: mockSelect,
            markShownUseCase: mockMark
        )

        await viewModel.loadMessage()
        await viewModel.markMessageShown()

        let markCalled = await mockMark.executeCalled
        #expect(markCalled == true)
    }

    // MARK: - Test 6: markMessageShown only marks once

    @Test("markMessageShown should only mark once")
    @MainActor
    func markMessageShownOnlyOnce() async {
        let entity = MotivationalMessageEntity(content: "Test", category: .urge)
        let mockSelect = MockSelectUseCase(messageToReturn: entity)
        let mockMark = MockMarkShownUseCase()

        let viewModel = HomeMotivationViewModel(
            selectMessageUseCase: mockSelect,
            markShownUseCase: mockMark
        )

        await viewModel.loadMessage()
        await viewModel.markMessageShown()
        await viewModel.markMessageShown()
        await viewModel.markMessageShown()

        let callCount = await mockMark.executeCallCount
        #expect(callCount == 1)
    }

    // MARK: - Test 7: markMessageShown does nothing if no entity loaded

    @Test("markMessageShown should do nothing if no entity loaded")
    @MainActor
    func markMessageShownNoEntity() async {
        let mockSelect = MockSelectUseCase(messageToReturn: nil)
        let mockMark = MockMarkShownUseCase()

        let viewModel = HomeMotivationViewModel(
            selectMessageUseCase: mockSelect,
            markShownUseCase: mockMark
        )

        await viewModel.loadMessage()
        await viewModel.markMessageShown()

        let markCalled = await mockMark.executeCalled
        #expect(markCalled == false)
    }
}

// MARK: - Mocks

actor MockSelectUseCase: SelectMotivationalMessageUseCase {
    private var messageToReturn: MotivationalMessageEntity?
    private let shouldThrow: Bool
    var executeCallCount = 0

    init(messageToReturn: MotivationalMessageEntity? = nil, shouldThrow: Bool = false) {
        self.messageToReturn = messageToReturn
        self.shouldThrow = shouldThrow
    }

    func setMessageToReturn(_ message: MotivationalMessageEntity) {
        messageToReturn = message
    }

    func execute() async throws -> MotivationalMessageEntity? {
        executeCallCount += 1
        if shouldThrow {
            throw NSError(domain: "test", code: 1)
        }
        return messageToReturn
    }
}

actor MockMarkShownUseCase: MarkMessageShownUseCase {
    var executeCalled = false
    var executeCallCount = 0
    var lastMessage: MotivationalMessageEntity?

    func execute(_ message: MotivationalMessageEntity) async throws {
        executeCalled = true
        executeCallCount += 1
        lastMessage = message
    }
}
