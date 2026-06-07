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
            return "Active"
        case .disabled:
            return "Disabled"
        case .missingApplication:
            return "Missing app"
        case .duplicate:
            return "Duplicate"
        case .conflict:
            return "Conflict"
        case .error:
            return "Error"
        }
    }

    var detail: String {
        switch self {
        case .registered:
            return "Registered and listening"
        case .disabled:
            return "Shortcut is disabled"
        case .missingApplication:
            return "Application path does not exist"
        case .duplicate:
            return "Another enabled shortcut uses the same keys"
        case .conflict(let code):
            return "macOS rejected this hotkey, status \(code)"
        case .error(let code):
            return "Registration failed, status \(code)"
        }
    }
}
