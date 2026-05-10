import AppKit
import Foundation

@MainActor
final class AppIconCache {
    static let shared = AppIconCache()

    private var icons: [String: NSImage] = [:]

    private init() {}

    func icon(for path: String) -> NSImage {
        if let cached = icons[path] {
            return cached
        }

        let icon = NSWorkspace.shared.icon(forFile: path)
        icon.size = NSSize(width: 64, height: 64)
        icons[path] = icon
        return icon
    }
}
