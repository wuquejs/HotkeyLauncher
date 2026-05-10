import AppKit
import Foundation

enum ApplicationLauncher {
    static func open(
        _ shortcut: HotkeyShortcut,
        opensNewWindowWhenNoVisibleWindows: Bool,
        completion: @escaping @Sendable (String?) -> Void
    ) {
        let appURL = URL(fileURLWithPath: shortcut.appPath)
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        configuration.addsToRecentItems = false
        let runningApp = runningApplication(for: shortcut)
        let hadVisibleWindows = runningApp.map(hasVisibleWindows) ?? true

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
            openNewWindowIfNeeded(
                for: app,
                shortcut: shortcut,
                enabled: opensNewWindowWhenNoVisibleWindows,
                appWasAlreadyRunning: runningApp != nil,
                hadVisibleWindows: hadVisibleWindows
            )
            completion(nil)
        }
    }

    private static func runningApplication(for shortcut: HotkeyShortcut) -> NSRunningApplication? {
        if let bundleIdentifier = shortcut.bundleIdentifier, !bundleIdentifier.isEmpty {
            return NSWorkspace.shared.runningApplications.first {
                $0.bundleIdentifier == bundleIdentifier
            }
        }

        let appURL = URL(fileURLWithPath: shortcut.appPath).standardizedFileURL
        return NSWorkspace.shared.runningApplications.first {
            $0.bundleURL?.standardizedFileURL == appURL
        }
    }

    private static func openNewWindowIfNeeded(
        for app: NSRunningApplication,
        shortcut: HotkeyShortcut,
        enabled: Bool,
        appWasAlreadyRunning: Bool,
        hadVisibleWindows: Bool
    ) {
        guard enabled, appWasAlreadyRunning, !hadVisibleWindows else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            guard !hasVisibleWindows(for: app) else {
                return
            }

            _ = app.activate(options: [.activateAllWindows])
            sendCommandN()
            AppLog.write("new-window \(shortcut.name)")
        }
    }

    private static func hasVisibleWindows(for app: NSRunningApplication) -> Bool {
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        guard let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            return true
        }

        return windowList.contains { info in
            guard
                let ownerPID = info[kCGWindowOwnerPID as String] as? pid_t,
                ownerPID == app.processIdentifier,
                let layer = info[kCGWindowLayer as String] as? Int,
                layer == 0,
                let bounds = info[kCGWindowBounds as String] as? [String: Any],
                let width = bounds["Width"] as? Double,
                let height = bounds["Height"] as? Double,
                width > 1,
                height > 1
            else {
                return false
            }

            return true
        }
    }

    private static func sendCommandN() {
        let keyCodeForN: CGKeyCode = 45
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCodeForN, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCodeForN, keyDown: false)

        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
}
