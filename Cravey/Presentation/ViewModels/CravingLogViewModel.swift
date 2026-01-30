import Foundation

/// ViewModel for logging new cravings
/// Presentation layer - prepares data for UI, handles user actions
/// Source: CLINICAL_CANNABIS_SPEC.md lines 185-211, MVP_PRODUCT_SPEC.md lines 119-139
/// Conforms to shared protocols for DRY code (DEBT-022, 023, 024)
@Observable
@MainActor
final class CravingLogViewModel: Identifiable, LocationHandling, TimestampWarning, FormSubmission {
    @ObservationIgnored
    let id = UUID() // For Identifiable conformance (sheet binding)

    // MARK: - Form Fields

    var intensity: Double = 5
    var timestamp: Date = .init() // REQUIRED: Auto "now", editable (CLINICAL_CANNABIS_SPEC.md:193)
    var selectedTriggers: Set<String> = []
    var notes: String = "" {
        didSet {
            // Enforce char limit (DATA_MODEL_SPEC:275, UX_FLOW:391)
            if notes.count > ValidationLimits.notesMaxLength {
                notes = String(notes.prefix(ValidationLimits.notesMaxLength))
            }
        }
    }

    // MARK: - LocationHandling Protocol

    var selectedLocation: String? // BUG-004 FIX: Optional to avoid Set allocation in binding
    var isLoadingLocation: Bool = false
    var showLocationPermissionAlert: Bool = false
    var locationError: String?

    @ObservationIgnored
    private(set) var locationService: LocationServiceProtocol?

    // MARK: - FormSubmission Protocol

    var isLoading: Bool = false
    var didSucceed: Bool = false // Signal success to parent (UX_FLOW:396-405) - toast, not alert
    var errorMessage: String?

    // MARK: - TimestampWarning Protocol

    var showTimestampWarning: Bool = false

    @ObservationIgnored
    var hasAcknowledgedOldTimestampInternal: Bool = false

    @ObservationIgnored
    private(set) var nowProvider: @Sendable () -> Date

    // MARK: - Dependencies

    @ObservationIgnored
    private let logCravingUseCase: LogCravingUseCase

    init(
        logCravingUseCase: LogCravingUseCase,
        locationService: LocationServiceProtocol? = nil,
        nowProvider: @escaping @Sendable () -> Date = Date.init
    ) {
        self.logCravingUseCase = logCravingUseCase
        self.locationService = locationService
        self.nowProvider = nowProvider
        timestamp = nowProvider()
    }

    // MARK: - Actions

    func logCraving() async {
        // Check for old timestamp warning (uses protocol extension)
        if shouldShowTimestampWarning() {
            showTimestampWarning = true
            return // Wait for user to confirm
        }

        guard canSubmit else { return }

        do {
            _ = try await withLoadingState {
                try await self.logCravingUseCase.execute(
                    timestamp: self.timestamp,
                    intensity: Int(self.intensity),
                    triggers: Array(self.selectedTriggers),
                    notes: self.notes.isEmpty ? nil : self.notes,
                    location: self.selectedLocation
                )
            }
            // Trigger haptic + signal success (UX_FLOW:396-405)
            markSuccess()
        } catch {
            // Error already handled by withLoadingState
        }
    }

    func confirmOldTimestamp() async {
        // User confirmed they want to log old timestamp (uses protocol extension)
        acknowledgeOldTimestamp()
        await logCraving() // Reuse existing logic - no duplication
    }

    func resetForm() {
        intensity = 5
        timestamp = nowProvider()
        selectedTriggers = []
        notes = ""
        selectedLocation = nil
        hasAcknowledgedOldTimestampInternal = false
        didSucceed = false
        isLoadingLocation = false
        showLocationPermissionAlert = false
        locationError = nil
    }

    // MARK: - Computed Properties for UI

    var intensityDescription: String {
        switch Int(intensity) {
        case 1 ... 3: "Mild - Manageable discomfort"
        case 4 ... 6: "Moderate - Noticeable urge"
        case 7 ... 10: "Intense - Strong urge"
        default: ""
        }
    }

    var canSubmit: Bool {
        !isLoading
    }

    var notesCharacterCount: Int {
        notes.count
    }

    /// BUG-006 FIX: Only show counter at threshold (matches UsageLogViewModel)
    var shouldShowNotesCounter: Bool {
        notes.count >= ValidationLimits.notesCounterThreshold
    }
}
