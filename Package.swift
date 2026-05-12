// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Cadence",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "CadenceKit", targets: ["CadenceKit"]),
        .executable(name: "Cadence", targets: ["Cadence"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CadenceKit",
            path: "Sources/CadenceKit",
            resources: [.process("Resources")]
        ),
        .executableTarget(
            name: "Cadence",
            dependencies: ["CadenceKit"],
            path: "Sources/Cadence"
        ),
        .testTarget(
            name: "CadenceKitTests",
            dependencies: ["CadenceKit"],
            path: "Tests/CadenceKitTests"
        )
    ]
)
