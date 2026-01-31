import Observation
import SwiftUI

/// GPS-aware location chip selector with loading indicator (DEBT-026)
/// Extracts location selection UI from form views
struct LocationSelector<ViewModel: AnyObject & LocationHandling & Observable>: View {
    @Bindable var viewModel: ViewModel
    var showTitle: Bool = true

    /// Computed selected value that maps GPS coords to "📍 Current" chip
    private var displayedSelection: String? {
        if let loc = viewModel.selectedLocation, LocationOptions.isGPS(loc) {
            return LocationOptions.currentLocationKey
        }
        return viewModel.selectedLocation
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showTitle {
                Text("Location")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Row 1: Current, Home, Work
            FlowLayout(spacing: 8) {
                ForEach(LocationOptions.presetsRow1, id: \.self) { option in
                    ChipButton(
                        title: option,
                        isSelected: displayedSelection == option,
                        action: { handleSelection(option) }
                    )
                }
            }

            // Row 2: Out, Other
            FlowLayout(spacing: 8) {
                ForEach(LocationOptions.presetsRow2, id: \.self) { option in
                    ChipButton(
                        title: option,
                        isSelected: displayedSelection == option,
                        action: { handleSelection(option) }
                    )
                }
            }

            // Show location error inline if present
            if let locationError = viewModel.locationError {
                Text(locationError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .overlay {
            if viewModel.isLoadingLocation {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 8)
            }
        }
        .onDisappear {
            // Ensure we don't keep a location request alive after the form closes.
            viewModel.locationTask?.cancel()
            viewModel.locationTask = nil
            viewModel.isLoadingLocation = false
        }
    }

    private func handleSelection(_ option: String) {
        Task {
            // Toggle off if already selected, otherwise select
            if displayedSelection == option {
                await viewModel.handleLocationSelection(nil)
            } else {
                await viewModel.handleLocationSelection(option)
            }
        }
    }
}

#Preview {
    @Previewable @State var viewModel = DependencyContainer.preview.makeCravingLogViewModel()

    LocationSelector(viewModel: viewModel)
        .padding()
}
