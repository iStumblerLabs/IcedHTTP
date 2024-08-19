// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "IcedHTTP",
    platforms: [.macOS(.v10_14), .iOS(.v14), .tvOS(.v14)],
    products: [
        .library( name: "IcedHTTP", type: .dynamic, targets: ["IcedHTTP"])
    ],
    targets: [
        .target(
            name: "IcedHTTP"
        )
    ]
)
