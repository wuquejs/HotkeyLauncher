import AppKit
import Foundation

enum AppResolver {
    static func metadata(for appURL: URL) -> (name: String, bundleIdentifier: String?) {
        let bundle = Bundle(url: appURL)
        let info = bundle?.infoDictionary

        let displayName = info?["CFBundleDisplayName"] as? String
        let bundleName = info?["CFBundleName"] as? String
        let fileName = appURL.deletingPathExtension().lastPathComponent

        return (
            name: displayName ?? bundleName ?? fileName,
            bundleIdentifier: bundle?.bundleIdentifier
        )
    }

    static func applicationExists(at path: String) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
}
