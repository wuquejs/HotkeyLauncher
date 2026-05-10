import Foundation

enum ShortcutStatus: Equatable {
    case registered
    case disabled
    case missingApplication
    case duplicate
    case conflict(Int32)
    case error(Int32)

    var title: String {
        switch self {
        case .registered:
            "Active"
        case .disabled:
            "Disabled"
        case .missingApplication:
            "Missing app"
        case .duplicate:
            "Duplicate"
        case .conflict:
            "Conflict"
        case .error:
            "Error"
        }
    }

    var detail: String {
        switch self {
        case .registered:
            "Registered and listening"
        case .disabled:
            "Shortcut is disabled"
        case .missingApplication:
            "Application path does not exist"
        case .duplicate:
            "Another enabled shortcut uses the same keys"
        case .conflict(let code):
            "macOS rejected this hotkey, status \(code)"
        case .error(let code):
            "Registration failed, status \(code)"
        }
    }
}
