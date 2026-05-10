import SwiftUI

struct ShortcutDetailView: View {
    @Binding var shortcut: HotkeyShortcut

    let status: ShortcutStatus
    @Binding var launchAtLogin: Bool
    @Binding var opensNewWindowWhenNoVisibleWindows: Bool
    let onChooseApplication: () -> Void
    let onOpen: () -> Void
    let onRecordingChanged: (Bool) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header

                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 16) {
                    GridRow {
                        Text("Name")
                            .foregroundStyle(.secondary)
                        TextField("Name", text: $shortcut.name)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 360)
                    }

                    GridRow {
                        Text("Application")
                            .foregroundStyle(.secondary)
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

                    GridRow {
                        Text("Hotkey")
                            .foregroundStyle(.secondary)
                        HotkeyRecorderButton(
                            combination: $shortcut.hotkey,
                            onRecordingChanged: onRecordingChanged
                        )
                    }

                    GridRow {
                        Text("State")
                            .foregroundStyle(.secondary)
                        HStack(spacing: 12) {
                            Toggle("Enabled", isOn: $shortcut.isEnabled)
                                .toggleStyle(.switch)

                            StatusBadge(status: status)
                        }
                    }

                    GridRow {
                        Text("Startup")
                            .foregroundStyle(.secondary)
                        Toggle("Launch at Login", isOn: $launchAtLogin)
                            .toggleStyle(.switch)
                    }

                    GridRow {
                        Text("Windows")
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 4) {
                            Toggle("New window when none are visible", isOn: $opensNewWindowWhenNoVisibleWindows)
                                .toggleStyle(.switch)

                            Text("Applies to all shortcuts. When the app is already running with no visible windows, Hotkey Launcher activates it and sends Command+N.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: 420, alignment: .leading)
                    }
                }
                .gridColumnAlignment(.leading)

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
}
