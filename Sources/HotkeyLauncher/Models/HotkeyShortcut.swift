import Carbon.HIToolbox
import Foundation

struct HotkeyShortcut: Codable, Identifiable, Equatable, Sendable {
    var id: UUID
    var name: String
    var appPath: String
    var bundleIdentifier: String?
    var hotkey: HotkeyCombination
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        name: String,
        appPath: String,
        bundleIdentifier: String? = nil,
        hotkey: HotkeyCombination,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.appPath = appPath
        self.bundleIdentifier = bundleIdentifier
        self.hotkey = hotkey
        self.isEnabled = isEnabled
    }

    static func defaultShortcuts() -> [HotkeyShortcut] {
        [
            HotkeyShortcut(
                name: "FlowDeck",
                appPath: "/Applications/FlowDeck.app",
                bundleIdentifier: "com.flowdeck.app",
                hotkey: .optionCommand(kVK_ANSI_T)
            ),
            HotkeyShortcut(
                name: "Google Chrome",
                appPath: "/Applications/Google Chrome.app",
                bundleIdentifier: "com.google.Chrome",
                hotkey: .optionCommand(kVK_ANSI_C)
            ),
            HotkeyShortcut(
                name: "Codex",
                appPath: "/Applications/Codex.app",
                bundleIdentifier: "com.openai.codex",
                hotkey: .optionCommand(kVK_ANSI_X)
            ),
            HotkeyShortcut(
                name: "Fork",
                appPath: "/Applications/Fork.app",
                bundleIdentifier: "com.DanPristupov.Fork",
                hotkey: .optionCommand(kVK_ANSI_F)
            )
        ]
    }
}
