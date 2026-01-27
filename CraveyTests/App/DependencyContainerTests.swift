@testable import Cravey
import Foundation
import SwiftData
import Testing

@Suite("DependencyContainer Bootstrap Tests")
@MainActor
struct DependencyContainerTests {
    enum MockContainerError: LocalizedError {
        case persistentFailed
        case inMemoryFailed

        var errorDescription: String? {
            switch self {
            case .persistentFailed:
                "Mock persistent container failed"
            case .inMemoryFailed:
                "Mock in-memory container failed"
            }
        }
    }

    @Test("Startup throws a non-crashing error when both persistent and fallback storage fail")
    func startupThrowsStartupFailureWhenAllContainersFail() {
        do {
            _ = try DependencyContainer(
                arguments: [],
                makePersistentContainer: { throw MockContainerError.persistentFailed },
                makeInMemoryContainer: { throw MockContainerError.inMemoryFailed }
            )

            Issue.record("Expected DependencyContainer init to throw, but it succeeded.")
        } catch let failure as DependencyContainer.StartupFailure {
            #expect(failure.persistentErrorDescription == MockContainerError.persistentFailed.localizedDescription)
            #expect(failure.inMemoryErrorDescription == MockContainerError.inMemoryFailed.localizedDescription)
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
}
