import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var store: ShortcutStore

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(store.shortcuts) { shortcut in
                    Button {
                        store.selectShortcut(id: shortcut.id)
                    } label: {
                        ShortcutRowView(
                            shortcut: shortcut,
                            status: store.status(for: shortcut.id)
                        )
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(selectionBackground(for: shortcut.id))
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

            Divider()

            Button {
                store.showSettings()
            } label: {
                Label("Settings", systemImage: "gearshape")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(10)
            .background(store.isShowingSettings ? Color.accentColor.opacity(0.16) : Color.clear)
        }
    }

    @ViewBuilder
    private func selectionBackground(for shortcutID: UUID) -> some View {
        if store.selectedID == shortcutID && !store.isShowingSettings {
            Color.accentColor.opacity(0.16)
        } else {
            Color.clear
        }
    }
}
