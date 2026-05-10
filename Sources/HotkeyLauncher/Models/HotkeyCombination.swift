import AppKit
import Carbon.HIToolbox
import Foundation

struct HotkeyCombination: Codable, Hashable, Sendable {
    var keyCode: UInt32
    var modifiers: UInt32

    var displayName: String {
        "\(modifierDisplayName)\(KeyboardKeyNames.name(for: keyCode))"
    }

    private var modifierDisplayName: String {
        var parts: [String] = []
        if modifiers & UInt32(controlKey) != 0 {
            parts.append("^")
        }
        if modifiers & UInt32(optionKey) != 0 {
            parts.append("⌥")
        }
        if modifiers & UInt32(shiftKey) != 0 {
            parts.append("⇧")
        }
        if modifiers & UInt32(cmdKey) != 0 {
            parts.append("⌘")
        }
        return parts.joined()
    }

    static func from(event: NSEvent) -> HotkeyCombination? {
        let modifiers = carbonModifiers(from: event.modifierFlags)
        guard modifiers != 0 else {
            return nil
        }

        let keyCode = UInt32(event.keyCode)
        guard KeyboardKeyNames.isSupported(keyCode: keyCode) else {
            return nil
        }

        return HotkeyCombination(keyCode: keyCode, modifiers: modifiers)
    }

    static func optionCommand(_ keyCode: Int) -> HotkeyCombination {
        HotkeyCombination(keyCode: UInt32(keyCode), modifiers: UInt32(optionKey | cmdKey))
    }

    private static func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        let activeFlags = flags.intersection(.deviceIndependentFlagsMask)
        var result: UInt32 = 0

        if activeFlags.contains(.control) {
            result |= UInt32(controlKey)
        }
        if activeFlags.contains(.option) {
            result |= UInt32(optionKey)
        }
        if activeFlags.contains(.shift) {
            result |= UInt32(shiftKey)
        }
        if activeFlags.contains(.command) {
            result |= UInt32(cmdKey)
        }

        return result
    }
}
