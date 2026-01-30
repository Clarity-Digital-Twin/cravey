import SwiftUI
import UIKit

/// Location permission denied alert modifier (DEBT-025)
/// Opens Settings app when user needs to enable location access
struct LocationPermissionAlertModifier: ViewModifier {
    @Environment(\.openURL) private var openURL
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        content
            .alert("Location Permission Required", isPresented: $isPresented) {
                Button("Open Settings") {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    openURL(url)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enable location access in Settings to use Current Location.")
            }
    }
}

extension View {
    /// Adds location permission denied alert
    func locationPermissionAlert(isPresented: Binding<Bool>) -> some View {
        modifier(LocationPermissionAlertModifier(isPresented: isPresented))
    }
}
