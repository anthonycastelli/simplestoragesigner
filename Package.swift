// swift-tools-version:4.0
// Managed by ice

import PackageDescription

let package = Package(
    name: "SimpleStorageSigner",
    products: [
        .library(name: "SimpleStorageSigner", targets: ["SimpleStorageSigner"]),
    ],
    targets: [
        .target(name: "SimpleStorageSigner", dependencies: []),
        .testTarget(name: "SimpleStorageSignerTests", dependencies: ["SimpleStorageSigner"]),
    ]
)
