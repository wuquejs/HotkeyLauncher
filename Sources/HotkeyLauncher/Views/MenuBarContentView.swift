import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject private var store: ShortcutStore
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Open Hotkey Launcher") {
            openWindow(id: "main")
            WindowActivator.activateSoon()
        }

        Divider()

        ForEach(store.shortcuts.prefix(8)) { shortcut in
            Button("\(shortcut.hotkey.displayName)  \(shortcut.name)") {
                store.openShortcut(id: shortcut.id)
            }
            .disabled(store.status(for: shortcut.id) == .missingApplication)
        }

        Divider()

        Button("Quit") {
            NSApp.terminate(nil)
        }
        .onAppear {
            store.start()
        }
    }
}
