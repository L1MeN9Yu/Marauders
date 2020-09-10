// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Marauders",
    products: [
        .library(name: "Marauders", targets: ["Marauders"]),
        .executable(name: "MaraudersCLI", targets: ["MaraudersCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
        .package(url: "https://github.com/L1MeN9Yu/Senna", from: "2.0.0"),
    ],
    targets: [
        .target(name: "MaraudersCLI", dependencies: [
            .target(name: "Marauders"),
            "Senna",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
        .target(name: "Marauders", dependencies: ["CMarauders"]),
        .target(name: "CMarauders"),
        .testTarget(name: "MaraudersTests", dependencies: ["Marauders"]),
    ]
)
