import AppKit
import Carbon.HIToolbox
import Foundation
import UniformTypeIdentifiers

@MainActor
final class ShortcutStore: ObservableObject {
    @Published private(set) var shortcuts: [HotkeyShortcut]
    @Published private(set) var statuses: [UUID: ShortcutStatus] = [:]
    @Published var selectedID: UUID?
    @Published var launchAtLogin: Bool
    @Published var opensNewWindowWhenNoVisibleWindows: Bool
    @Published var alert: AlertItem?

    private let storage: ShortcutStorage
    private var hotKeyCenter: GlobalHotKeyCenter?
    private var registrationsSuspended = false
    private var didStart = false

    init(storage: ShortcutStorage = .live) {
        self.storage = storage

        let savedShortcuts = storage.load()
        let initialShortcuts = savedShortcuts.isEmpty ? HotkeyShortcut.defaultShortcuts() : savedShortcuts

        self.shortcuts = initialShortcuts
        self.selectedID = initialShortcuts.first?.id
        self.launchAtLogin = LoginItemInstaller.isEnabled(bundleURL: Bundle.main.bundleURL)
        self.opensNewWindowWhenNoVisibleWindows = storage.loadSettings().opensNewWindowWhenNoVisibleWindows
    }

    func start() {
        guard !didStart else {
            return
        }

        didStart = true
        AppLog.write("store start")
        self.hotKeyCenter = GlobalHotKeyCenter { [weak self] shortcutID in
            Task { @MainActor in
                self?.openShortcut(id: shortcutID)
            }
        }

        persist()
        refreshRegistrations()
    }

    var selectedShortcut: HotkeyShortcut? {
        guard let selectedID else {
            return nil
        }
        return shortcuts.first(where: { $0.id == selectedID })
    }

    func shortcut(id: UUID) -> HotkeyShortcut? {
        shortcuts.first(where: { $0.id == id })
    }

    func status(for shortcutID: UUID) -> ShortcutStatus {
        statuses[shortcutID] ?? .disabled
    }

    func updateShortcut(_ shortcut: HotkeyShortcut) {
        guard let index = shortcuts.firstIndex(where: { $0.id == shortcut.id }) else {
            return
        }

        shortcuts[index] = shortcut
        persist()
        refreshRegistrations()
    }

    func removeSelectedShortcut() {
        guard let selectedID else {
            return
        }

        shortcuts.removeAll { $0.id == selectedID }
        self.selectedID = shortcuts.first?.id
        persist()
        refreshRegistrations()
    }

    func addApplicationFromPanel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.applicationBundle]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.directoryURL = URL(fileURLWithPath: "/Applications")

        guard panel.runModal() == .OK, let url = panel.url else {
            return
        }

        addApplication(url)
    }

    func chooseApplication(for shortcutID: UUID) {
        guard var shortcut = shortcut(id: shortcutID) else {
            return
        }

        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.applicationBundle]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.directoryURL = URL(fileURLWithPath: "/Applications")

        guard panel.runModal() == .OK, let url = panel.url else {
            return
        }

        let metadata = AppResolver.metadata(for: url)
        shortcut.name = metadata.name
        shortcut.appPath = url.path
        shortcut.bundleIdentifier = metadata.bundleIdentifier
        updateShortcut(shortcut)
    }

    func addApplication(_ url: URL) {
        let metadata = AppResolver.metadata(for: url)
        let shortcut = HotkeyShortcut(
            name: metadata.name,
            appPath: url.path,
            bundleIdentifier: metadata.bundleIdentifier,
            hotkey: .optionCommand(kVK_ANSI_A),
            isEnabled: false
        )

        shortcuts.append(shortcut)
        selectedID = shortcut.id
        persist()
        refreshRegistrations()
    }

    func openSelectedShortcut() {
        guard let selectedID else {
            return
        }
        openShortcut(id: selectedID)
    }

    func openShortcut(id: UUID) {
        guard let shortcut = shortcut(id: id) else {
            return
        }

        AppLog.write("open \(shortcut.name)")
        ApplicationLauncher.open(
            shortcut,
            opensNewWindowWhenNoVisibleWindows: opensNewWindowWhenNoVisibleWindows
        ) { [weak self] errorMessage in
            guard let errorMessage else {
                return
            }

            Task { @MainActor in
                self?.alert = AlertItem(
                    title: "Open Failed",
                    message: errorMessage
                )
            }
        }
    }

    func setOpensNewWindowWhenNoVisibleWindows(_ enabled: Bool) {
        opensNewWindowWhenNoVisibleWindows = enabled
        persistSettings()
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            try LoginItemInstaller.setEnabled(enabled, bundleURL: Bundle.main.bundleURL)
            launchAtLogin = enabled
        } catch {
            alert = AlertItem(title: "Login Item Failed", message: error.localizedDescription)
            launchAtLogin = LoginItemInstaller.isEnabled(bundleURL: Bundle.main.bundleURL)
        }
    }

    func setRecordingActive(_ active: Bool) {
        registrationsSuspended = active
        if active {
            hotKeyCenter?.unregisterAll()
        } else {
            refreshRegistrations()
        }
    }

    func refreshRegistrations() {
        guard !registrationsSuspended else {
            return
        }

        var nextStatuses: [UUID: ShortcutStatus] = [:]
        var candidates: [HotkeyShortcut] = []

        for shortcut in shortcuts {
            if !shortcut.isEnabled {
                nextStatuses[shortcut.id] = .disabled
            } else if !AppResolver.applicationExists(at: shortcut.appPath) {
                nextStatuses[shortcut.id] = .missingApplication
            } else {
                candidates.append(shortcut)
            }
        }

        let groupedByHotkey = Dictionary(grouping: candidates, by: { $0.hotkey })
        let duplicateIDs = Set(
            groupedByHotkey
                .filter { $0.value.count > 1 }
                .flatMap { $0.value.map(\.id) }
        )

        for duplicateID in duplicateIDs {
            nextStatuses[duplicateID] = .duplicate
        }

        let registerable = candidates.filter { !duplicateIDs.contains($0.id) }
        guard let hotKeyCenter else {
            for shortcut in registerable {
                nextStatuses[shortcut.id] = .disabled
            }
            statuses = nextStatuses
            return
        }

        let registrationStatuses = hotKeyCenter.register(shortcuts: registerable)

        for shortcut in registerable {
            nextStatuses[shortcut.id] = registrationStatuses[shortcut.id] ?? .error(-1)
        }

        statuses = nextStatuses
    }

    private func persist() {
        do {
            try storage.save(shortcuts)
        } catch {
            alert = AlertItem(title: "Save Failed", message: error.localizedDescription)
        }
    }

    private func persistSettings() {
        do {
            try storage.saveSettings(
                AppSettings(opensNewWindowWhenNoVisibleWindows: opensNewWindowWhenNoVisibleWindows)
            )
        } catch {
            alert = AlertItem(title: "Save Failed", message: error.localizedDescription)
        }
    }
}
