// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "StoneMacApp",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "StoneMacApp", targets: ["StoneMacApp"])
    ],
    targets: [
        .executableTarget(
            name: "StoneMacApp",
            path: "Sources/StoneMacApp",
            resources: [
                // If you later add assets, you can include them here
                // .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("IOBluetooth"),
                .linkedFramework("AppKit")
            ]
        )
    ]
)