// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Cadence",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "CadenceKit", targets: ["CadenceKit"]),
        .executable(name: "Cadence", targets: ["Cadence"]),
        .executable(name: "Tempo", targets: ["Tempo"])
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
        .executableTarget(
            name: "Tempo",
            dependencies: ["CadenceKit"],
            path: "Sources/Tempo"
        ),
        .testTarget(
            name: "CadenceKitTests",
            dependencies: ["CadenceKit"],
            path: "Tests/CadenceKitTests"
        ),
        .testTarget(
            name: "TempoTests",
            dependencies: ["Tempo"],
            path: "Tests/TempoTests"
        )
    ]
)
