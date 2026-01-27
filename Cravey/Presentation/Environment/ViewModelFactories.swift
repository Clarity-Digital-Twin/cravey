import SwiftUI

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

extension EnvironmentValues {
    var makeCravingLogViewModel: @MainActor () -> CravingLogViewModel {
        get { self[MakeCravingLogViewModelKey.self] }
        set { self[MakeCravingLogViewModelKey.self] = newValue }
    }

    var makeUsageLogViewModel: @MainActor () -> UsageLogViewModel {
        get { self[MakeUsageLogViewModelKey.self] }
        set { self[MakeUsageLogViewModelKey.self] = newValue }
    }
}
