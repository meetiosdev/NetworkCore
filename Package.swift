// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NetworkCore",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(name: "NetworkCore", targets: ["NetworkCore"])
    ],
    targets: [
        .target(
            name: "NetworkCore",
            path: "Sources/NetworkCore",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "NetworkCoreTests",
            dependencies: ["NetworkCore"],
            path: "Tests/NetworkCoreTests"
        )
    ]
)
