import Foundation

struct ShortcutStorage {
    var shortcutsURL: URL

    static let live = ShortcutStorage(
        shortcutsURL: FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/HotkeyLauncher/shortcuts.json")
    )

    func load() -> [HotkeyShortcut] {
        guard
            let data = try? Data(contentsOf: shortcutsURL),
            let shortcuts = try? JSONDecoder().decode([HotkeyShortcut].self, from: data)
        else {
            return []
        }

        return shortcuts
    }

    func save(_ shortcuts: [HotkeyShortcut]) throws {
        try FileManager.default.createDirectory(
            at: shortcutsURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(shortcuts)
        try data.write(to: shortcutsURL, options: .atomic)
    }
}
