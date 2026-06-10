import SwiftUI

struct ShortcutRowView: View {
    let shortcut: HotkeyShortcut
    let status: ShortcutStatus

    var body: some View {
        HStack(spacing: 10) {
            AppIconView(path: shortcut.appPath, size: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(shortcut.name)
                    .lineLimit(1)

                Text(shortcut.hotkey.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            StatusDot(status: status)
                .allowsHitTesting(false)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
