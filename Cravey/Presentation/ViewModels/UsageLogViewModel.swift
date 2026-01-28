import Foundation

@Observable
@MainActor
final class UsageLogViewModel: Identifiable {
    @ObservationIgnored
    let id = UUID() // For Identifiable conformance (sheet binding)

    // Dependencies
    @ObservationIgnored
    private let logUsageUseCase: LogUsageUseCase
    @ObservationIgnored
    private let locationService: LocationServiceProtocol?
    @ObservationIgnored
    private let nowProvider: @Sendable () -> Date

    // Form fields (required)
    var timestamp: Date = .init()
    var selectedMethod: String = "Bowls" {
        didSet {
            // Auto-update amount to first valid option when method changes
            updateAmountForMethod()
        }
    }

    var amount: Double = 0.5 // Default to first valid option for Bowls (DATA_MODEL_SPEC:166)

    // Form fields (optional)
    var selectedTriggers: Set<String> = []
    var selectedLocation: String?
    var notes: String = "" {
        didSet {
            // Enforce 500 char limit (DATA_MODEL_SPEC:122, UX_FLOW:391)
            if notes.count > 500 {
                notes = String(notes.prefix(500))
            }
        }
    }

    // UI state
    var didSucceed: Bool = false // Signal success to parent (UX_FLOW:396-405)
    var showTimestampWarning: Bool = false // >7 days warning (DATA_MODEL_SPEC:117)
    var errorMessage: String?
    var isLoading: Bool = false

    // Location state (DEBT-009: GPS Current Location)
    var isLoadingLocation: Bool = false
    var showLocationPermissionAlert: Bool = false
    var locationError: String?

    // Private state for timestamp confirmation flow
    @ObservationIgnored
    private var hasAcknowledgedOldTimestamp: Bool = false

    init(
        logUsageUseCase: LogUsageUseCase,
        locationService: LocationServiceProtocol? = nil,
        nowProvider: @escaping @Sendable () -> Date = Date.init
    ) {
        self.logUsageUseCase = logUsageUseCase
        self.locationService = locationService
        self.nowProvider = nowProvider
        timestamp = nowProvider()
    }

    /// Validate form can be submitted
    var canSubmit: Bool {
        !selectedMethod.isEmpty && amount > 0
    }

    /// Character count for notes (show counter at 400+ chars)
    var notesCharacterCount: Int {
        notes.count
    }

    /// Show notes character counter (at 400+ chars per UX_FLOW:391)
    var shouldShowNotesCounter: Bool {
        notes.count >= 400
    }

    /// Check if timestamp is >7 days old (DATA_MODEL_SPEC:117)
    var isTimestampOld: Bool {
        TimestampValidation.isOlderThanWarningThreshold(timestamp: timestamp, now: nowProvider())
    }

    /// Log usage via use case
    func logUsage() async {
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
            let request = LogUsageRequest(
                timestamp: timestamp,
                method: selectedMethod,
                amount: amount,
                triggers: Array(selectedTriggers),
                location: selectedLocation,
                notes: notes.isEmpty ? nil : notes
            )
            _ = try await logUsageUseCase.execute(request)

            // Trigger haptic + toast + reset form (UX_FLOW:396-405)
            triggerSuccessFeedback()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Confirm old timestamp and proceed with logging
    func confirmOldTimestamp() async {
        showTimestampWarning = false
        hasAcknowledgedOldTimestamp = true // Mark as acknowledged to prevent re-triggering
        await logUsage() // Proceed with save
    }

    /// Signal success to parent (haptics handled by View via .sensoryFeedback)
    private func triggerSuccessFeedback() {
        // Signal success to parent (form will dismiss, parent shows toast)
        // Haptic feedback is now declaratively handled in the View layer
        // using .sensoryFeedback(.success, trigger: didSucceed)
        didSucceed = true
    }

    /// Reset amount to first valid option when method changes
    /// Called automatically via didSet on selectedMethod
    func updateAmountForMethod() {
        let validAmounts = ROAAmountRange.range(for: selectedMethod)
        if let firstAmount = validAmounts.first {
            amount = firstAmount
        }
    }

    /// Reset form to defaults (called when form reopens)
    func resetForm() {
        timestamp = nowProvider()
        selectedMethod = "Bowls"
        amount = 0.5 // First valid option for Bowls
        selectedTriggers = []
        selectedLocation = nil
        notes = ""
        showTimestampWarning = false
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
}
