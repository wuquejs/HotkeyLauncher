import SwiftUI

struct AppIconView: View {
    let path: String
    let size: CGFloat

    var body: some View {
        Image(nsImage: AppIconCache.shared.icon(for: path))
            .resizable()
            .frame(width: size, height: size)
    }
}
