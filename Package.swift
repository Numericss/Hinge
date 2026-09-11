// swift-tools-version: 6.0
import PackageDescription
let package = Package(name: "Hinge", platforms: [.macOS(.v14)], products: [
    .executable(name: "Hinge", targets: ["Hinge"])
], targets: [
    .target(name: "FoldCore"),
    .executableTarget(name: "Hinge", dependencies: ["FoldCore"], swiftSettings: [.swiftLanguageMode(.v5)]),
    .testTarget(name: "FoldCoreTests", dependencies: ["FoldCore"]),
    .testTarget(name: "HingeTests", dependencies: ["Hinge", "FoldCore"])
])
