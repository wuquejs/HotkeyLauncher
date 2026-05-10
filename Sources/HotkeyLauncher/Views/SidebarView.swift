import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var store: ShortcutStore

    var body: some View {
        VStack(spacing: 0) {
            List(selection: $store.selectedID) {
                ForEach(store.shortcuts) { shortcut in
                    ShortcutRowView(
                        shortcut: shortcut,
                        status: store.status(for: shortcut.id)
                    )
                    .tag(shortcut.id)
                }
            }
            .listStyle(.sidebar)

            Divider()

            HStack(spacing: 8) {
                Button {
                    store.addApplicationFromPanel()
                } label: {
                    Label("Add", systemImage: "plus")
                }

                Button {
                    store.removeSelectedShortcut()
                } label: {
                    Label("Remove", systemImage: "trash")
                }
                .disabled(store.selectedShortcut == nil)

                Spacer()
            }
            .padding(10)
        }
    }
}
