// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CorporateEmpire",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "CorporateEmpire",
            targets: ["CorporateEmpire"]
        ),
    ],
    dependencies: [
        // Add external dependencies here when needed
        // .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "CorporateEmpire",
            dependencies: [],
            path: "CorporateEmpire"
        ),
        .testTarget(
            name: "CorporateEmpireTests",
            dependencies: ["CorporateEmpire"],
            path: "CorporateEmpireTests"
        ),
    ]
)
