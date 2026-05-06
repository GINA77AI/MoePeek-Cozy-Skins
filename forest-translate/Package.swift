// swift-tools-version: 5.11
import PackageDescription

let package = Package(
    name: "ForestTranslate",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "ForestTranslate",
            path: "Sources"
        ),
    ]
)
