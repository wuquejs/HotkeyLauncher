import AppKit
import Foundation

enum UpdateChecker {
    private static let latestInfoURL = URL(
        string: "https://github.com/zjy4fun/HotkeyLauncher/releases/latest/download/latest.json"
    )!
    private static let latestReleaseAPIURL = URL(
        string: "https://api.github.com/repos/zjy4fun/HotkeyLauncher/releases/latest"
    )!

    static func latestUpdate() async throws -> UpdateInfo {
        do {
            return try await latestUpdateFromMetadata()
        } catch {
            return try await latestUpdateFromGitHubAPI()
        }
    }

    static func openRelease(_ update: UpdateInfo) {
        NSWorkspace.shared.open(update.releaseURL)
    }

    static func downloadAndOpen(_ update: UpdateInfo) async throws {
        guard let downloadURL = update.downloadURL else {
            _ = await MainActor.run {
                NSWorkspace.shared.open(update.releaseURL)
            }
            return
        }

        let (downloadedURL, response) = try await URLSession.shared.download(from: downloadURL)
        try validate(response)

        let destinationURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(downloadURL.lastPathComponent.isEmpty ? "HotkeyLauncher-\(update.displayVersion).dmg" : downloadURL.lastPathComponent)

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }

        try FileManager.default.moveItem(at: downloadedURL, to: destinationURL)

        _ = await MainActor.run {
            NSWorkspace.shared.open(destinationURL)
        }
    }

    private static func latestUpdateFromMetadata() async throws -> UpdateInfo {
        let (data, response) = try await URLSession.shared.data(from: latestInfoURL)
        try validate(response)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(UpdateInfo.self, from: data)
    }

    private static func latestUpdateFromGitHubAPI() async throws -> UpdateInfo {
        var request = URLRequest(url: latestReleaseAPIURL)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("HotkeyLauncher", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let release = try decoder.decode(GitHubRelease.self, from: data)
        let downloadURL = release.assets.first { $0.name.hasSuffix(".dmg") }?.browserDownloadURL

        return UpdateInfo(
            version: release.tagName.trimmingCharacters(in: CharacterSet(charactersIn: "vV")),
            tagName: release.tagName,
            releaseURL: release.htmlURL,
            downloadURL: downloadURL,
            publishedAt: release.publishedAt
        )
    }

    private static func validate(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}

private struct GitHubRelease: Decodable {
    var tagName: String
    var htmlURL: URL
    var publishedAt: Date?
    var assets: [GitHubAsset]

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlURL = "html_url"
        case publishedAt = "published_at"
        case assets
    }
}

private struct GitHubAsset: Decodable {
    var name: String
    var browserDownloadURL: URL

    enum CodingKeys: String, CodingKey {
        case name
        case browserDownloadURL = "browser_download_url"
    }
}
