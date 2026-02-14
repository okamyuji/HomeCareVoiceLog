// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HomeCareVoiceLogCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "HomeCareVoiceLogCore",
            targets: ["HomeCareVoiceLogCore"]
        ),
    ],
    targets: [
        .target(
            name: "HomeCareVoiceLogCore"
        ),
        .testTarget(
            name: "HomeCareVoiceLogCoreTests",
            dependencies: ["HomeCareVoiceLogCore"]
        ),
    ]
)
