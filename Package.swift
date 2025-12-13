// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "KensIOSApp",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "KensIOSApp",
            targets: ["KensIOSApp"]
        )
    ],
    dependencies: [
        // Add external dependencies here
        // Example: .package(url: "https://github.com/hmlongco/Factory", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "KensIOSApp",
            dependencies: [],
            path: "KensIOSApp",
            exclude: ["Resources/Assets.xcassets"],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ImplicitOpenExistentials"),
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "KensIOSAppTests",
            dependencies: ["KensIOSApp"],
            path: "KensIOSAppTests"
        )
    ]
)
