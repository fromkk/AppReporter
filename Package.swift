// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppReporter",
    platforms: [.macOS(.v13)],
    products: [
      .executable(name: "AppReporter", targets: ["AppReporter"]),
      .library(name: "APIClient", targets: ["APIClient"]),
    ],
    dependencies: [
      .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
      .package(url: "https://github.com/apple/swift-format.git", from: "510.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
          name: "AppReporter",
          dependencies: [
            "APIClient",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
          ]
        ),
        .target(
          name: "APIClient",
          dependencies: []
        )
    ]
)
