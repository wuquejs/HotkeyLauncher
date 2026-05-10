import AppKit
import Foundation

enum ApplicationLauncher {
    static func open(_ shortcut: HotkeyShortcut, completion: @escaping @Sendable (String?) -> Void) {
        let appURL = URL(fileURLWithPath: shortcut.appPath)
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        configuration.addsToRecentItems = false

        NSWorkspace.shared.openApplication(at: appURL, configuration: configuration) { app, error in
            if let error {
                completion(error.localizedDescription)
                return
            }

            guard let app else {
                completion(nil)
                return
            }

            _ = app.activate(options: [.activateAllWindows])
            completion(nil)
        }
    }
}
