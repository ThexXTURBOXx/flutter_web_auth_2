// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_web_auth_2",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "flutter-web-auth-2", targets: ["flutter_web_auth_2"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "flutter_web_auth_2",
            dependencies: [],
            resources: []
        )
    ]
)
