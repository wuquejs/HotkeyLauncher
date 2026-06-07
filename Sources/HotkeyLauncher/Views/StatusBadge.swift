import SwiftUI

struct StatusBadge: View {
    let status: ShortcutStatus

    var body: some View {
        Label(status.title, systemImage: symbolName)
            .font(.caption)
            .foregroundStyle(tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tint.opacity(0.12), in: Capsule())
    }

    private var symbolName: String {
        switch status {
        case .registered:
            return "checkmark.circle.fill"
        case .disabled:
            return "pause.circle"
        case .missingApplication:
            return "questionmark.app"
        case .duplicate:
            return "square.on.square"
        case .conflict:
            return "exclamationmark.triangle.fill"
        case .error:
            return "xmark.octagon.fill"
        }
    }

    private var tint: Color {
        switch status {
        case .registered:
            return .green
        case .disabled:
            return .secondary
        case .missingApplication:
            return .orange
        case .duplicate, .conflict, .error:
            return .red
        }
    }
}

struct StatusDot: View {
    let status: ShortcutStatus

    var body: some View {
        Circle()
            .fill(tint)
            .frame(width: 8, height: 8)
            .help(status.detail)
    }

    private var tint: Color {
        switch status {
        case .registered:
            return .green
        case .disabled:
            return .secondary
        case .missingApplication:
            return .orange
        case .duplicate, .conflict, .error:
            return .red
        }
    }
}
