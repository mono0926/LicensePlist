// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "LicensePlist",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "license-plist", targets: ["LicensePlist"]),
        .library(name: "LicensePlistCore", targets: ["LicensePlistCore"]),
        .plugin(name: "LicensePlistBuildTool", targets: ["LicensePlistBuildTool"]),
        .plugin(name: "GenerateAcknowledgementsCommand", targets: ["GenerateAcknowledgementsCommand"]),
        .plugin(name: "AddAcknowledgementsCopyScriptCommand", targets: ["AddAcknowledgementsCopyScriptCommand"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git",
                 from: "1.1.4"),
        .package(url: "https://github.com/ishkawa/APIKit.git",
                 from: "5.3.0"),
        .package(url: "https://github.com/Kitura/HeliumLogger.git",
                 from: "2.0.0"),
        .package(url: "https://github.com/Kitura/swift-html-entities.git",
                 from: "4.0.1"),
        .package(url: "https://github.com/YusukeHosonuma/SwiftParamTest",
                 .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/tomlokhorst/XcodeEdit.git",
                 from: "2.9.0"),
        .package(url: "https://github.com/jpsim/Yams.git",
                 from: "5.0.5")
    ],
    targets: [
        .executableTarget(
            name: "LicensePlist",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "LicensePlistCore",
                "HeliumLogger",
                "XcodeEdit"
            ]
        ),
        .target(
            name: "LicensePlistCore",
            dependencies: [
                "APIKit",
                "HeliumLogger",
                .product(name: "HTMLEntities", package: "swift-html-entities"),
                .product(name: "Yams", package: "Yams")
            ]
        ),
        .testTarget(
            name: "LicensePlistTests",
            dependencies: ["LicensePlistCore", "SwiftParamTest"],
            exclude: [
                "Resources",
                "XcodeProjects",
            ]
        ),
        .plugin(
            name: "LicensePlistBuildTool",
            capability: .buildTool(),
            dependencies: ["LicensePlistBinary"]
        ),
        .plugin(
            name: "GenerateAcknowledgementsCommand",
            capability: .command(
                intent: .custom(
                    verb: "license-plist",
                    description: "LicensePlist generates acknowledgements"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "LicensePlist generates acknowledgements inside the project directory")
                ]
            ),
            dependencies: ["LicensePlistBinary"]
        ),
        .plugin(
            name: "AddAcknowledgementsCopyScriptCommand",
            capability: .command(
                intent: .custom(
                    verb: "license-plist-add-copy-script",
                    description: "LicensePlist adds a copy script to build phases"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "LicensePlist updates project file")
                ]
            ),
            dependencies: ["LicensePlistBinary"]
        ),
        .binaryTarget(
            name: "LicensePlistBinary",
            url: "https://github.com/mono0926/LicensePlist/releases/download/3.27.1/LicensePlistBinary-macos.artifactbundle.zip",
            checksum: "24e066b23da58275a89a83cae05bf40cad8a48faacf10facbfa5c350efe02608"
        )
    ]
)
