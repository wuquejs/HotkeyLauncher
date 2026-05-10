import Carbon.HIToolbox
import Foundation

final class GlobalHotKeyCenter {
    private var hotKeyRefs: [EventHotKeyRef] = []
    private var eventHandlerRef: EventHandlerRef?
    private var hotKeyIDToShortcutID: [UInt32: UUID] = [:]
    private var nextHotKeyID: UInt32 = 1
    private let callback: (UUID) -> Void

    init(callback: @escaping (UUID) -> Void) {
        self.callback = callback
        installHandler()
    }

    deinit {
        unregisterAll()
        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
        }
    }

    func register(shortcuts: [HotkeyShortcut]) -> [UUID: ShortcutStatus] {
        unregisterAll()

        var results: [UUID: ShortcutStatus] = [:]
        for shortcut in shortcuts {
            let hotKeyID = EventHotKeyID(
                signature: Self.signature,
                id: nextHotKeyID
            )
            nextHotKeyID += 1

            var hotKeyRef: EventHotKeyRef?
            let status = RegisterEventHotKey(
                shortcut.hotkey.keyCode,
                shortcut.hotkey.modifiers,
                hotKeyID,
                GetApplicationEventTarget(),
                0,
                &hotKeyRef
            )

            guard status == noErr, let hotKeyRef else {
                if status == eventHotKeyExistsErr {
                    results[shortcut.id] = .conflict(status)
                    AppLog.write("conflict \(shortcut.hotkey.displayName) \(shortcut.name) status=\(status)")
                } else {
                    results[shortcut.id] = .error(status)
                    AppLog.write("error \(shortcut.hotkey.displayName) \(shortcut.name) status=\(status)")
                }
                continue
            }

            hotKeyRefs.append(hotKeyRef)
            hotKeyIDToShortcutID[hotKeyID.id] = shortcut.id
            results[shortcut.id] = .registered
            AppLog.write("registered \(shortcut.hotkey.displayName) \(shortcut.name)")
        }

        return results
    }

    func unregisterAll() {
        for hotKeyRef in hotKeyRefs {
            UnregisterEventHotKey(hotKeyRef)
        }
        hotKeyRefs.removeAll(keepingCapacity: true)
        hotKeyIDToShortcutID.removeAll(keepingCapacity: true)
    }

    private func installHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        let handler: EventHandlerUPP = { _, event, userData in
            guard let event, let userData else {
                return noErr
            }

            let center = Unmanaged<GlobalHotKeyCenter>
                .fromOpaque(userData)
                .takeUnretainedValue()
            center.handle(event: event)
            return noErr
        }

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            handler,
            1,
            &eventType,
            selfPointer,
            &eventHandlerRef
        )
        AppLog.write("installed handler status=\(status)")
    }

    private func handle(event: EventRef) {
        var hotKeyID = EventHotKeyID()
        let status = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
        )

        guard status == noErr, let shortcutID = hotKeyIDToShortcutID[hotKeyID.id] else {
            AppLog.write("unknown hotkey event status=\(status) id=\(hotKeyID.id)")
            return
        }

        AppLog.write("pressed shortcutID=\(shortcutID)")
        callback(shortcutID)
    }

    private static let signature: OSType = {
        var result: UInt32 = 0
        for scalar in "HKLN".unicodeScalars {
            result = (result << 8) + scalar.value
        }
        return result
    }()
}
