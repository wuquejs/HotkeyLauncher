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

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case appPath
        case bundleIdentifier
        case hotkey
        case isEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.appPath = try container.decode(String.self, forKey: .appPath)
        self.bundleIdentifier = try container.decodeIfPresent(String.self, forKey: .bundleIdentifier)
        self.hotkey = try container.decode(HotkeyCombination.self, forKey: .hotkey)
        self.isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
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
