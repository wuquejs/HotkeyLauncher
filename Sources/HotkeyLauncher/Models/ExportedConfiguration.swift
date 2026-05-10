import Foundation

struct ExportedConfiguration: Codable {
    var version: Int
    var exportedAt: Date
    var settings: AppSettings
    var shortcuts: [HotkeyShortcut]

    init(settings: AppSettings, shortcuts: [HotkeyShortcut]) {
        self.version = 1
        self.exportedAt = Date()
        self.settings = settings
        self.shortcuts = shortcuts
    }
}
