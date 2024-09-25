// swift-tools-version: 5.6

import PackageDescription

let products: [PackageDescription.Product] = [
    .executable(
        name: "swift-sweep",
        targets: ["swift-sweep"]
    ),
    .plugin(
        name: "SwiftSweep",
        targets: ["SwiftSweepPlugin"]
    ),
]

let targets: [PackageDescription.Target] = [
    .executableTarget(
        name: "swift-sweep",
        dependencies: ["SwiftSweepCore",
                       .product(name: "ArgumentParser", package: "swift-argument-parser")]
    ),
    .target(name: "SwiftSweepCore",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ]),
    .testTarget(
        name: "SwiftSweepCoreTests",
        dependencies: ["SwiftSweepCore"]
    ),
    .plugin(
        name: "SwiftSweepPlugin",
        capability: .command(
            intent: .custom(
                verb: "swift-sweep",
                description: "Find unused symbols"
            )
        ),
        dependencies: ["swift-sweep"]
    ),
]

let package = Package(
    name: "SwiftSweep",
    platforms: [
        .macOS(.v12)
    ],
    products: products,
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", .upToNextMajor(from: "510.0.1"))
    ],
    targets: targets
)
