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
        )
    ],
    targets: [
        .target(
            name: "LiveTimingKit",
            dependencies: [
                .product(name: "SignalRClient", package: "signalr-client-swift")
            ]),
        .testTarget(
            name: "LiveTimingKitTests",
            dependencies: ["LiveTimingKit"]),
    ]
) 
