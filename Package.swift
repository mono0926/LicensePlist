// swift-tools-version:4.1

import PackageDescription

let package = Package(
    name: "LicensePlist",
    products: [
        .executable(name: "license-plist", targets: ["LicensePlist"]),
        .library(name: "LicensePlistCore", targets: ["LicensePlistCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git",
                 from: "0.4.2"),
        .package(url: "https://github.com/ishkawa/APIKit.git",
                 from: "5.2.0"),
        .package(url: "https://github.com/Kitura/HeliumLogger.git",
                 from: "1.9.0"),
        .package(url: "https://github.com/behrang/YamlSwift.git",
                 from: "3.4.4"),
        .package(url: "https://github.com/Kitura/swift-html-entities.git",
                 from: "3.0.14"),
    ],
    targets: [
        .target(
            name: "LicensePlist",
            dependencies: [
                "LicensePlistCore",
                "ArgumentParser",
                "HeliumLogger",
            ]
        ),
        .target(
            name: "LicensePlistCore",
            dependencies: [
                "APIKit",
                "HeliumLogger",
                "HTMLEntities",
                "Yaml",
            ]
        ),
        .testTarget(
            name: "LicensePlistTests",
            dependencies: ["LicensePlistCore"],
            exclude: [
                "XcodeProjects",
            ]
        ),
    ]
)
