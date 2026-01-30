import SwiftUI

/// Generic delete confirmation dialog modifier (DEBT-028)
/// Reduces duplicate confirmation dialog code in list views
struct DeleteConfirmationModifier<Item: Identifiable>: ViewModifier {
    @Binding var itemToDelete: Item?
    let title: String
    let message: String
    let onDelete: (Item) -> Void

    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                title,
                isPresented: Binding(
                    get: { itemToDelete != nil },
                    set: { if !$0 { itemToDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    guard let item = itemToDelete else { return }
                    itemToDelete = nil
                    onDelete(item)
                }
                Button("Cancel", role: .cancel) {
                    itemToDelete = nil
                }
            } message: {
                Text(message)
            }
    }
}

extension View {
    /// Adds generic delete confirmation dialog
    func deleteConfirmation<Item: Identifiable>(
        itemToDelete: Binding<Item?>,
        title: String = "Delete?",
        message: String = "This cannot be undone.",
        onDelete: @escaping (Item) -> Void
    ) -> some View {
        modifier(DeleteConfirmationModifier(
            itemToDelete: itemToDelete,
            title: title,
            message: message,
            onDelete: onDelete
        ))
    }
}
