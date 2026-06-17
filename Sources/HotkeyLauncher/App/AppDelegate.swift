import AppKit
import Combine
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let store = ShortcutStore()
    private var window: NSWindow?
    private var statusItem: NSStatusItem?
    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        applyDockVisibility(showsInDock: store.showsInDock)
        observeDockVisibility()
        store.start()
        createWindow()
        createStatusItem()

        if !CommandLine.arguments.contains("--background") {
            showWindow()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showWindow()
        return true
    }

    @objc private func showWindow() {
        if window == nil {
            createWindow()
        }

        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func addApplication() {
        showWindow()
        store.addApplicationFromPanel()
    }

    @objc private func openSelected() {
        store.openSelectedShortcut()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    private func observeDockVisibility() {
        store.$showsInDock
            .removeDuplicates()
            .sink { [weak self] showsInDock in
                self?.applyDockVisibility(showsInDock: showsInDock)
            }
            .store(in: &cancellables)
    }

    private func applyDockVisibility(showsInDock: Bool) {
        NSApp.setActivationPolicy(showsInDock ? .regular : .accessory)
    }

    private func createWindow() {
        guard window == nil else {
            return
        }

        let content = ContentView()
            .environmentObject(store)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 560),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "热键启动器"
        window.minSize = NSSize(width: 700, height: 400)
        window.isReleasedWhenClosed = false
        window.contentViewController = NSHostingController(rootView: content)
        window.setFrameAutosaveName("HotkeyLauncherMainWindow")
        window.setFrame(NSRect(x: 0, y: 0, width: 900, height: 560), display: true)
        window.center()
        self.window = window
    }

    private func createStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "热键启动器")
        item.menu = makeStatusMenu()
        statusItem = item
    }

    private func makeStatusMenu() -> NSMenu {
        let menu = NSMenu()

        menu.addItem(
            withTitle: "打开热键启动器",
            action: #selector(showWindow),
            keyEquivalent: ""
        ).target = self

        menu.addItem(
            withTitle: "添加应用...",
            action: #selector(addApplication),
            keyEquivalent: ""
        ).target = self

        menu.addItem(.separator())

        menu.addItem(
            withTitle: "打开选中项",
            action: #selector(openSelected),
            keyEquivalent: ""
        ).target = self

        menu.addItem(.separator())

        menu.addItem(
            withTitle: "退出",
            action: #selector(quit),
            keyEquivalent: ""
        ).target = self

        return menu
    }
}
