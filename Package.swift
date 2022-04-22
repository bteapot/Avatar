// swift-tools-version: 5.6

import PackageDescription


let package = Package(
    name: "Avatar",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "Avatar",
            targets: ["Avatar"]
        ),
    ],
    targets: [
        .target(
            name: "Avatar",
            dependencies: []
        ),
    ]
)
