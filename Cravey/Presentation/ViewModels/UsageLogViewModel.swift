import Foundation

/// ViewModel for logging cannabis usage
/// Conforms to shared protocols for DRY code (DEBT-022, 023, 024)
@Observable
@MainActor
final class UsageLogViewModel: Identifiable, LocationHandling, TimestampWarning, FormSubmission {
    @ObservationIgnored
    let id = UUID() // For Identifiable conformance (sheet binding)

    // MARK: - Form Fields (Required)

    var timestamp: Date = .init()
    var selectedMethod: String = "Bowls" {
        didSet {
            // Auto-update amount to first valid option when method changes
            updateAmountForMethod()
        }
    }

    /// Default to first valid option for Bowls (DATA_MODEL_SPEC:166)
    var amount: Double = AppConstants.FormDefaults.usageAmount

    // MARK: - Form Fields (Optional)

    var selectedTriggers: Set<String> = []
    var notes: String = "" {
        didSet {
            // Enforce char limit (DATA_MODEL_SPEC:122, UX_FLOW:391)
            if notes.count > ValidationLimits.notesMaxLength {
                notes = String(notes.prefix(ValidationLimits.notesMaxLength))
            }
        }
    }

    // MARK: - LocationHandling Protocol

    var selectedLocation: String?
    var isLoadingLocation: Bool = false
    var showLocationPermissionAlert: Bool = false
    var locationError: String?

    @ObservationIgnored
    private(set) var locationService: LocationServiceProtocol?

    /// Task handle for in-flight location requests (BUG-034)
    @ObservationIgnored
    var locationTask: Task<Void, Never>?

    // MARK: - FormSubmission Protocol

    var isLoading: Bool = false
    var didSucceed: Bool = false // Signal success to parent (UX_FLOW:396-405)
    var errorMessage: String?

    // MARK: - TimestampWarning Protocol

    var showTimestampWarning: Bool = false // >7 days warning (DATA_MODEL_SPEC:117)

    @ObservationIgnored
    var hasAcknowledgedOldTimestampInternal: Bool = false

    @ObservationIgnored
    private(set) var nowProvider: @Sendable () -> Date

    // MARK: - Dependencies

    @ObservationIgnored
    private let logUsageUseCase: LogUsageUseCase

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

    // MARK: - Computed Properties

    /// Validate form can be submitted
    var canSubmit: Bool {
        !selectedMethod.isEmpty && amount > 0
    }

    /// Character count for notes (show counter at 400+ chars)
    var notesCharacterCount: Int {
        notes.count
    }

    /// Show notes character counter (at threshold per UX_FLOW:391)
    var shouldShowNotesCounter: Bool {
        notes.count >= ValidationLimits.notesCounterThreshold
    }

    // MARK: - Actions

    /// Log usage via use case
    func logUsage() async {
        // Check for old timestamp warning (uses protocol extension)
        if shouldShowTimestampWarning() {
            showTimestampWarning = true
            return // Wait for user to confirm
        }

        guard canSubmit else { return }

        do {
            _ = try await withLoadingState {
                let request = LogUsageRequest(
                    timestamp: self.timestamp,
                    method: self.selectedMethod,
                    amount: self.amount,
                    triggers: Array(self.selectedTriggers),
                    location: self.selectedLocation,
                    notes: self.notes.isEmpty ? nil : self.notes
                )
                return try await self.logUsageUseCase.execute(request)
            }
            // Trigger haptic + toast + reset form (UX_FLOW:396-405)
            markSuccess()
        } catch {
            // Error already set to errorMessage by withLoadingState; no additional handling needed
        }
    }

    /// Confirm old timestamp and proceed with logging
    func confirmOldTimestamp() async {
        // Uses protocol extension
        acknowledgeOldTimestamp()
        await logUsage() // Proceed with save
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
        // Cancel any in-flight location request (BUG-034)
        locationTask?.cancel()
        locationTask = nil

        timestamp = nowProvider()
        selectedMethod = "Bowls"
        amount = AppConstants.FormDefaults.usageAmount // First valid option for Bowls
        selectedTriggers = []
        selectedLocation = nil
        notes = ""
        showTimestampWarning = false
        hasAcknowledgedOldTimestampInternal = false
        didSucceed = false
        isLoadingLocation = false
        showLocationPermissionAlert = false
        locationError = nil
    }
}
