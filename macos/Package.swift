// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "CursorFatuus",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "CursorFatuus",
            path: "Sources/CursorFatuus"
        ),
    ]
)
