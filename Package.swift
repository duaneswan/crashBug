
// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "crashBug",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .framework(
            name: "crashBug",
            targets: ["crashBug"]
        ),
    ],
    targets: [
        .target(
            name: "crashBug",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "crashBugTests",
            dependencies: ["crashBug"]
        ),
    ]
)
