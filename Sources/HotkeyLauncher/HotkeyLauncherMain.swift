import AppKit

@main
struct HotkeyLauncherMain {
    @MainActor
    static func main() {
        let app = NSApplication.shared
        let appDelegate = AppDelegate()
        app.delegate = appDelegate
        app.run()
    }
}
