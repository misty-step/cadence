// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Cadence",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Cadence", targets: ["CadenceApp"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "CadenceApp",
            path: "Sources/CadenceApp"
        )
    ]
)
