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
            "checkmark.circle.fill"
        case .disabled:
            "pause.circle"
        case .missingApplication:
            "questionmark.app"
        case .duplicate:
            "square.on.square"
        case .conflict:
            "exclamationmark.triangle.fill"
        case .error:
            "xmark.octagon.fill"
        }
    }

    private var tint: Color {
        switch status {
        case .registered:
            .green
        case .disabled:
            .secondary
        case .missingApplication:
            .orange
        case .duplicate, .conflict, .error:
            .red
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
            .green
        case .disabled:
            .secondary
        case .missingApplication:
            .orange
        case .duplicate, .conflict, .error:
            .red
        }
    }
}
