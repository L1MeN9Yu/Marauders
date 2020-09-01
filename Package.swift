// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Marauders",
    products: [
        .library(name: "Marauders", targets: ["Marauders"]),
    ],
    targets: [
        .target(name: "Marauders", dependencies: ["CMarauders"]),
        .target(name: "CMarauders"),
        .testTarget(name: "MaraudersTests", dependencies: ["Marauders"]),
    ]
)
