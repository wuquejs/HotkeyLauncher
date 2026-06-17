import SwiftUI

struct AboutUpdateView: View {
    let latestUpdate: UpdateInfo?
    let isCheckingForUpdates: Bool
    let isDownloadingUpdate: Bool
    let onCheckForUpdates: () -> Void
    let onDownloadUpdate: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("热键启动器")
                        .font(.headline)

                    Text("版本 \(AppVersion.current)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    onCheckForUpdates()
                } label: {
                    Label(
                        isCheckingForUpdates ? "检查中" : "检查",
                        systemImage: "arrow.triangle.2.circlepath"
                    )
                }
                .disabled(isCheckingForUpdates)

                Button {
                    onDownloadUpdate()
                } label: {
                    Label(
                        isDownloadingUpdate ? "下载中" : "下载",
                        systemImage: "square.and.arrow.down"
                    )
                }
                .disabled(latestUpdate == nil || isDownloadingUpdate)
            }

            if let latestUpdate {
                Text("最新版本：\(latestUpdate.displayVersion)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
    }
}
