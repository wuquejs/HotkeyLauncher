import SwiftUI

struct SettingsView: View {
    @Binding var launchAtLogin: Bool
    @Binding var opensNewWindowWhenNoVisibleWindows: Bool
    @Binding var showsInDock: Bool

    let latestUpdate: UpdateInfo?
    let isCheckingForUpdates: Bool
    let isDownloadingUpdate: Bool
    let onImport: () -> Void
    let onExport: () -> Void
    let onCheckForUpdates: () -> Void
    let onDownloadUpdate: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                settingsSection("通用") {
                    Toggle("登录时启动", isOn: $launchAtLogin)
                        .toggleStyle(.switch)

                    VStack(alignment: .leading, spacing: 6) {
                        Toggle("在程序坞（Dock）中显示", isOn: $showsInDock)
                            .toggleStyle(.switch)

                        Text("关闭后应用会保留菜单栏图标，但不会出现在程序坞和应用切换器中。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Toggle("无可见窗口时新建窗口", isOn: $opensNewWindowWhenNoVisibleWindows)
                            .toggleStyle(.switch)

                        Text("适用于所有快捷方式。当目标应用已运行但没有可见窗口时，热键启动器会激活它并发送 Command+N。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                settingsSection("配置") {
                    HStack(spacing: 10) {
                        Button {
                            onImport()
                        } label: {
                            Label("导入", systemImage: "square.and.arrow.down")
                        }

                        Button {
                            onExport()
                        } label: {
                            Label("导出", systemImage: "square.and.arrow.up")
                        }
                    }

                    Text("将快捷方式和全局设置作为 JSON 配置包导入或导出。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                settingsSection("更新") {
                    AboutUpdateView(
                        latestUpdate: latestUpdate,
                        isCheckingForUpdates: isCheckingForUpdates,
                        isDownloadingUpdate: isDownloadingUpdate,
                        onCheckForUpdates: onCheckForUpdates,
                        onDownloadUpdate: onDownloadUpdate
                    )
                }
            }
            .padding(28)
            .frame(maxWidth: 720, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("设置")
                .font(.largeTitle)
                .fontWeight(.semibold)

            Text("管理应用级行为、配置文件和更新。")
                .foregroundStyle(.secondary)
        }
    }

    private func settingsSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                content()
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.separator, lineWidth: 1)
            }
        }
    }
}
