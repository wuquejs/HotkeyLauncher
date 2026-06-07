import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject private var store: ShortcutStore

    var body: some View {
        Button("Open Hotkey Launcher") {
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
