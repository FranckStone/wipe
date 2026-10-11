// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Wipe",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "Wipe", path: "Sources/Wipe")
    ]
)
