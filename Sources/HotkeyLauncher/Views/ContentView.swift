import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: ShortcutStore

    var body: some View {
        NavigationSplitView {
            SidebarView()
                .environmentObject(store)
                .navigationSplitViewColumnWidth(min: 260, ideal: 300)
        } detail: {
            if let shortcut = store.selectedShortcut {
                ShortcutDetailView(
                    shortcut: binding(for: shortcut),
                    status: store.status(for: shortcut.id),
                    launchAtLogin: Binding(
                        get: { store.launchAtLogin },
                        set: { store.setLaunchAtLogin($0) }
                    ),
                    opensNewWindowWhenNoVisibleWindows: Binding(
                        get: { store.opensNewWindowWhenNoVisibleWindows },
                        set: { store.setOpensNewWindowWhenNoVisibleWindows($0) }
                    ),
                    onChooseApplication: {
                        store.chooseApplication(for: shortcut.id)
                    },
                    onOpen: {
                        store.openShortcut(id: shortcut.id)
                    },
                    onRecordingChanged: { active in
                        store.setRecordingActive(active)
                    }
                )
                .id(shortcut.id)
            } else {
                EmptyStateView {
                    store.addApplicationFromPanel()
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    store.addApplicationFromPanel()
                } label: {
                    Label("Add", systemImage: "plus")
                }

                Button {
                    store.removeSelectedShortcut()
                } label: {
                    Label("Remove", systemImage: "minus")
                }
                .disabled(store.selectedShortcut == nil)
            }
        }
        .alert(item: $store.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            store.start()
        }
    }

    private func binding(for shortcut: HotkeyShortcut) -> Binding<HotkeyShortcut> {
        Binding(
            get: {
                store.shortcut(id: shortcut.id) ?? shortcut
            },
            set: { updatedShortcut in
                store.updateShortcut(updatedShortcut)
            }
        )
    }
}
