// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BoilerplateApp",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "BoilerplateApp",
            targets: ["BoilerplateApp"]
        )
    ],
    dependencies: [
        // Add external dependencies here
        // Example: .package(url: "https://github.com/hmlongco/Factory", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "BoilerplateApp",
            dependencies: [],
            path: "BoilerplateApp",
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
            name: "BoilerplateAppTests",
            dependencies: ["BoilerplateApp"],
            path: "BoilerplateAppTests"
        )
    ]
)
