import Foundation

/// ViewModel for logging new cravings
/// Presentation layer - prepares data for UI, handles user actions
/// Source: CLINICAL_CANNABIS_SPEC.md lines 185-211, MVP_PRODUCT_SPEC.md lines 119-139
@Observable
@MainActor
final class CravingLogViewModel: Identifiable {
    @ObservationIgnored
    let id = UUID() // For Identifiable conformance (sheet binding)

    // UI State (matches spec fields exactly)
    var intensity: Double = 5
    var timestamp: Date = .init() // REQUIRED: Auto "now", editable (CLINICAL_CANNABIS_SPEC.md:193)
    var selectedTriggers: Set<String> = []
    var notes: String = "" {
        didSet {
            // Enforce 500 char limit (DATA_MODEL_SPEC:275, UX_FLOW:391)
            if notes.count > 500 {
                notes = String(notes.prefix(500))
            }
        }
    }

    var selectedLocation: String? // BUG-004 FIX: Optional to avoid Set allocation in binding
    var isLoading: Bool = false
    var didSucceed: Bool = false // Signal success to parent (UX_FLOW:396-405) - toast, not alert
    var errorMessage: String?
    var showTimestampWarning: Bool = false

    // Location state (DEBT-009: GPS Current Location)
    var isLoadingLocation: Bool = false
    var showLocationPermissionAlert: Bool = false
    var locationError: String?

    // Private state for timestamp confirmation flow
    @ObservationIgnored
    private var hasAcknowledgedOldTimestamp: Bool = false

    // Dependencies (injected)
    @ObservationIgnored
    private let logCravingUseCase: LogCravingUseCase
    @ObservationIgnored
    private let nowProvider: @Sendable () -> Date
    @ObservationIgnored
    private let locationService: LocationServiceProtocol?

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
        // Check for old timestamp warning (only if not already acknowledged)
        if isTimestampOld, !hasAcknowledgedOldTimestamp {
            showTimestampWarning = true
            return // Wait for user to confirm
        }

        guard canSubmit else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false } // Ensures cleanup regardless of exit path

        do {
            _ = try await logCravingUseCase.execute(
                timestamp: timestamp,
                intensity: Int(intensity),
                triggers: Array(selectedTriggers),
                notes: notes.isEmpty ? nil : notes,
                location: selectedLocation // BUG-004 FIX: Already optional, no conversion needed
            )

            // Trigger haptic + signal success (UX_FLOW:396-405)
            triggerSuccessFeedback()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func confirmOldTimestamp() async {
        // User confirmed they want to log old timestamp
        showTimestampWarning = false
        hasAcknowledgedOldTimestamp = true // Mark as acknowledged to prevent re-triggering
        await logCraving() // Reuse existing logic - no duplication
    }

    /// Signal success to parent (haptics handled by View via .sensoryFeedback)
    private func triggerSuccessFeedback() {
        // Signal success to parent (form will dismiss, parent shows toast)
        // Haptic feedback is now declaratively handled in the View layer
        // using .sensoryFeedback(.success, trigger: didSucceed)
        didSucceed = true
    }

    func resetForm() {
        intensity = 5
        timestamp = nowProvider()
        selectedTriggers = []
        notes = ""
        selectedLocation = nil // BUG-004 FIX: Reset to nil
        hasAcknowledgedOldTimestamp = false
        didSucceed = false
        isLoadingLocation = false
        showLocationPermissionAlert = false
        locationError = nil
    }

    // MARK: - Location Handling (DEBT-009)

    /// Handle location chip selection
    /// For "Current Location", requests GPS; for presets, stores directly
    func handleLocationSelection(_ selection: String?) async {
        // Clear any previous location error
        locationError = nil

        guard let selection else {
            selectedLocation = nil
            return
        }

        // Check if this is the "Current Location" chip
        guard LocationOptions.isCurrentLocationChip(selection) else {
            // Normal preset - store directly
            selectedLocation = selection
            return
        }

        // Current Location tapped - request GPS
        guard let locationService else {
            // No location service available (e.g., in tests without mock)
            locationError = "Location service unavailable"
            selectedLocation = nil
            return
        }

        isLoadingLocation = true
        defer { isLoadingLocation = false }

        let result = await locationService.requestCurrentLocation()

        switch result {
        case let .success(latitude, longitude):
            selectedLocation = LocationOptions.formatGPS(latitude: latitude, longitude: longitude)

        case .permissionDenied:
            showLocationPermissionAlert = true
            selectedLocation = nil

        case .permissionRestricted:
            locationError = "Location restricted by parental controls"
            selectedLocation = nil

        case .servicesDisabled:
            locationError = "Location Services disabled. Enable in Settings > Privacy."
            selectedLocation = nil

        case .timeout:
            locationError = "Couldn't get location. Try again."
            selectedLocation = nil

        case let .error(message):
            locationError = message
            selectedLocation = nil
        }
    }

    // MARK: - Computed Properties for UI

    /// Check if timestamp is >7 days old (DATA_MODEL_SPEC:117)
    var isTimestampOld: Bool {
        TimestampValidation.isOlderThanWarningThreshold(timestamp: timestamp, now: nowProvider())
    }

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

    /// BUG-006 FIX: Only show counter at 400+ chars (matches UsageLogViewModel)
    var shouldShowNotesCounter: Bool {
        notes.count >= 400
    }
}
