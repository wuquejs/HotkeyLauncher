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
                    Text("HotkeyLauncher")
                        .font(.headline)

                    Text("Version \(AppVersion.current)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    onCheckForUpdates()
                } label: {
                    Label(
                        isCheckingForUpdates ? "Checking" : "Check",
                        systemImage: "arrow.triangle.2.circlepath"
                    )
                }
                .disabled(isCheckingForUpdates)

                Button {
                    onDownloadUpdate()
                } label: {
                    Label(
                        isDownloadingUpdate ? "Downloading" : "Download",
                        systemImage: "square.and.arrow.down"
                    )
                }
                .disabled(latestUpdate == nil || isDownloadingUpdate)
            }

            if let latestUpdate {
                Text("Latest: \(latestUpdate.displayVersion)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
    }
}
