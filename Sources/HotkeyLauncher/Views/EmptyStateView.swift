import SwiftUI

struct EmptyStateView: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "keyboard.badge.eye")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            Text("No Shortcuts")
                .font(.title3)
                .fontWeight(.semibold)

            Button {
                onAdd()
            } label: {
                Label("Add Application", systemImage: "plus")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
