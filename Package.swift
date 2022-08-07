// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "ASAPTY_SDK",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "ASAPTY_SDK", targets: ["ASAPTY_SDK"])
    ],
    targets: [
        .target(
            name: "ASAPTY_SDK",
            path: "Sources"
        ),
        .testTarget(
            name: "ASAPTY_SDK_TESTS",
            dependencies: ["ASAPTY_SDK"],
            path: "Tests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
