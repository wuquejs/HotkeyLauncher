import Foundation

enum LoginItemInstaller {
    private static let label = "com.zjy.hotkeylauncher"

    static var launchAgentURL: URL {
        FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents/\(label).plist")
    }

    static func isEnabled(bundleURL: URL) -> Bool {
        guard
            let data = try? Data(contentsOf: launchAgentURL),
            let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
            let dictionary = plist as? [String: Any],
            let arguments = dictionary["ProgramArguments"] as? [String]
        else {
            return false
        }

        return arguments.contains(bundleURL.path)
    }

    static func setEnabled(_ enabled: Bool, bundleURL: URL) throws {
        if enabled {
            try install(bundleURL: bundleURL)
        } else {
            try remove()
        }
    }

    private static func install(bundleURL: URL) throws {
        let plist: [String: Any] = [
            "Label": label,
            "ProgramArguments": [
                "/usr/bin/open",
                "-gj",
                bundleURL.path
            ],
            "RunAtLoad": true,
            "StandardOutPath": FileManager.default
                .homeDirectoryForCurrentUser
                .appendingPathComponent("Library/Logs/HotkeyLauncher.log")
                .path,
            "StandardErrorPath": FileManager.default
                .homeDirectoryForCurrentUser
                .appendingPathComponent("Library/Logs/HotkeyLauncher.err.log")
                .path
        ]

        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try FileManager.default.createDirectory(
            at: launchAgentURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: launchAgentURL, options: .atomic)
    }

    private static func remove() throws {
        if FileManager.default.fileExists(atPath: launchAgentURL.path) {
            try FileManager.default.removeItem(at: launchAgentURL)
        }
    }
}
