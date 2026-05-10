import Foundation

struct AppSettings: Codable, Equatable {
    var opensNewWindowWhenNoVisibleWindows: Bool

    static let `default` = AppSettings(opensNewWindowWhenNoVisibleWindows: true)
}

struct ShortcutStorage {
    var shortcutsURL: URL
    var settingsURL: URL

    static let live = ShortcutStorage(
        shortcutsURL: FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/HotkeyLauncher/shortcuts.json"),
        settingsURL: FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/HotkeyLauncher/settings.json")
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

    func loadSettings() -> AppSettings {
        guard
            let data = try? Data(contentsOf: settingsURL),
            let settings = try? JSONDecoder().decode(AppSettings.self, from: data)
        else {
            return .default
        }

        return settings
    }

    func save(_ shortcuts: [HotkeyShortcut]) throws {
        try createSupportDirectory()

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(shortcuts)
        try data.write(to: shortcutsURL, options: .atomic)
    }

    func saveSettings(_ settings: AppSettings) throws {
        try createSupportDirectory()

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(settings)
        try data.write(to: settingsURL, options: .atomic)
    }

    private func createSupportDirectory() throws {
        try FileManager.default.createDirectory(
            at: shortcutsURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }
}
