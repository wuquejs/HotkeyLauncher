// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "HotkeyLauncher",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "HotkeyLauncher", targets: ["HotkeyLauncher"])
    ],
    targets: [
        .executableTarget(
            name: "HotkeyLauncher",
            path: "Sources/HotkeyLauncher",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("Carbon")
            ]
        )
    ]
)
