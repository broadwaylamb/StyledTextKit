// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "StyledTextKit",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(name: "StyledTextKit", targets: ["StyledTextKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/uber/ios-snapshot-test-case.git", from: "8.0.0")
    ],
    targets: [
        .target(name: "StyledTextKit"),
        .testTarget(
            name: "StyledTextKitTests",
            dependencies: [
                "StyledTextKit",
                .product(name: "iOSSnapshotTestCase", package: "ios-snapshot-test-case")
            ],
            resources: [
                .copy("ReferenceImages_64"),
                .process("octoface@2x.png"),
                .process("octoface@3x.png"),
            ],
        ),
    ],
)
