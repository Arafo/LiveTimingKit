// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LiveTimingKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "LiveTimingKit",
            targets: ["LiveTimingKit"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Arafo/signalr-client-swift",
            revision: "7b27fe48b1a4b77efb6423c4dbf938b9f063076a"
        ),
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.6.4"
        ),
        .package(
            url: "https://github.com/tsolomko/SWCompression.git", 
            from: "4.8.6"
        ),
    ],
    targets: [
        .target(
            name: "LiveTimingKit",
            dependencies: [
                .product(name: "SignalRClient", package: "signalr-client-swift"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SWCompression", package: "SWCompression")
            ]),
        .testTarget(
            name: "LiveTimingKitTests",
            dependencies: ["LiveTimingKit"]),
    ]
) 
