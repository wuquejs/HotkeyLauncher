import SwiftUI

struct ShortcutDetailView: View {
    @Binding var shortcut: HotkeyShortcut

    let status: ShortcutStatus
    let onChooseApplication: () -> Void
    let onOpen: () -> Void
    let onRecordingChanged: (Bool) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header

                VStack(alignment: .leading, spacing: 16) {
                    detailRow("Name") {
                        TextField("Name", text: $shortcut.name)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 360)
                    }

                    detailRow("Application") {
                        HStack(spacing: 10) {
                            Text(shortcut.appPath)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)

                            Button {
                                onChooseApplication()
                            } label: {
                                Label("Choose", systemImage: "folder")
                            }
                        }
                    }

                    detailRow("Hotkey") {
                        HotkeyRecorderButton(
                            combination: $shortcut.hotkey,
                            onRecordingChanged: onRecordingChanged
                        )
                    }

                    detailRow("State") {
                        HStack(spacing: 12) {
                            Toggle("Enabled", isOn: $shortcut.isEnabled)
                                .toggleStyle(.switch)

                            StatusBadge(status: status)
                        }
                    }
                }

                Divider()

                HStack {
                    Button {
                        onOpen()
                    } label: {
                        Label("Open Now", systemImage: "arrow.up.forward.app")
                    }

                    Spacer()

                    Text(status.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(28)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            AppIconView(path: shortcut.appPath, size: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(shortcut.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                Text(shortcut.hotkey.displayName)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
    }

    private func detailRow<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Text(title)
                .foregroundStyle(.secondary)
                .frame(width: 90, alignment: .leading)

            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
