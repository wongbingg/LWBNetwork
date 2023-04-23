// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "LWBNetwork",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "LWBNetwork",
                 targets: ["LWBNetwork"])
    ],
    targets: [
        .target(name: "LWBNetwork",
                path: "LWBNetwork/Classes")
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
