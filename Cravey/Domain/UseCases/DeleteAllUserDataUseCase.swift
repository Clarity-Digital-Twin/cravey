/// Use Case: Permanently delete all user data stored by the app.
///
/// This includes local database records and any on-disk recording files.
protocol DeleteAllUserDataUseCase: Sendable {
    func execute() async throws
}
