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
            revision: "7bba94f88d6af74e91f4ebefdab8062c2666747b"
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
                .product(name: "SWCompression", package: "SWCompression")
            ]),
        .testTarget(
            name: "LiveTimingKitTests",
            dependencies: ["LiveTimingKit"]),
    ]
) 
