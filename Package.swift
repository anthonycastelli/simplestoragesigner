// swift-tools-version:4.0
// Managed by ice

import PackageDescription

let package = Package(
    name: "SimpleStorageSigner",
    products: [
        .library(name: "SimpleStorageSigner", targets: ["SimpleStorageSigner"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/service.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/http.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/crypto.git", from: "3.1.0"),
    ],
    targets: [
        .target(name: "SimpleStorageSigner", dependencies: ["HTTP", "Crypto"]),
        .testTarget(name: "SimpleStorageSignerTests", dependencies: ["SimpleStorageSigner"]),
    ]
)
