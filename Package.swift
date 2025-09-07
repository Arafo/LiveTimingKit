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
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
        //.package(path: "../../signalr-client-swift")
        .package(url: "https://github.com/Arafo/signalr-client-swift", branch: "dev")
    ],
    targets: [
        .target(
            name: "LiveTimingKit",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "SignalRClient", package: "signalr-client-swift")
            ]),
        .testTarget(
            name: "LiveTimingKitTests",
            dependencies: ["LiveTimingKit"]),
    ]
) 
