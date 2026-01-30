import Observation
import SwiftUI

/// GPS-aware location chip selector with loading indicator (DEBT-026)
/// Extracts location selection UI from form views
struct LocationSelector<ViewModel: AnyObject & LocationHandling & Observable>: View {
    @Bindable var viewModel: ViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            OptionalSingleSelectChipSelector(
                title: "Location",
                options: LocationOptions.presets,
                selectedValue: Binding(
                    get: {
                        // Show "📍 Current" chip as selected if we have GPS coords
                        if let loc = viewModel.selectedLocation, LocationOptions.isGPS(loc) {
                            return LocationOptions.currentLocationKey
                        }
                        return viewModel.selectedLocation
                    },
                    set: { newValue in
                        Task {
                            await viewModel.handleLocationSelection(newValue)
                        }
                    }
                )
            )
            .overlay {
                if viewModel.isLoadingLocation {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 8)
                }
            }

            // Show location error inline if present
            if let locationError = viewModel.locationError {
                Text(locationError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .onDisappear {
            // Ensure we don't keep a location request alive after the form closes.
            viewModel.locationTask?.cancel()
            viewModel.locationTask = nil
            viewModel.isLoadingLocation = false
        }
    }
}

#Preview {
    @Previewable @State var viewModel = DependencyContainer.preview.makeCravingLogViewModel()

    LocationSelector(viewModel: viewModel)
        .padding()
}
