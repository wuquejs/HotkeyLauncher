import SwiftUI

struct EmptyStateView: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "keyboard.badge.eye")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            Text("暂无快捷方式")
                .font(.title3)
                .fontWeight(.semibold)

            Button {
                onAdd()
            } label: {
                Label("添加应用", systemImage: "plus")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
