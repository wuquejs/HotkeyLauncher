import Foundation

struct UpdateInfo: Codable, Equatable, Sendable {
    var version: String
    var tagName: String
    var releaseURL: URL
    var downloadURL: URL?
    var publishedAt: Date?

    var displayVersion: String {
        version.isEmpty ? tagName : version
    }
}
