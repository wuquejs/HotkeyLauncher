import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var store: ShortcutStore

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(store.shortcuts) { shortcut in
                    ShortcutRowView(
                        shortcut: shortcut,
                        status: store.status(for: shortcut.id)
                    )
                    .onTapGesture {
                        store.selectShortcut(id: shortcut.id)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(selectionBackground(for: shortcut.id))
                }
            }
            .listStyle(.sidebar)

            Divider()

            HStack(spacing: 8) {
                Button {
                    store.addApplicationFromPanel()
                } label: {
                    Label("添加", systemImage: "plus")
                }

                Button {
                    store.removeSelectedShortcut()
                } label: {
                    Label("移除", systemImage: "trash")
                }
                .disabled(store.selectedShortcut == nil)

                Spacer()
            }
            .padding(10)

            Divider()

            Label("设置", systemImage: "gearshape")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .contentShape(Rectangle())
                .onTapGesture {
                    store.showSettings()
                }
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
