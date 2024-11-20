
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
            targets: ["crashBug"].
            dependencies: ["crashBug"]
        ),
    ],
    targets: [
        .target(
            name: "crashBug",
            dependencies: ["crashBug"],
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
