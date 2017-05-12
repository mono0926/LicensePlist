// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "LicensePlist",
    targets: [
        Target(
            name: "LicensePlist",
            dependencies: ["LicensePlistCore"]
        ),
        Target(name: "LicensePlistCore")
    ],
    dependencies: [
        .Package(url: "https://github.com/kylef/Commander.git",
                 majorVersion: 0),
        .Package(url: "https://github.com/ikesyo/Himotoki.git",
                 majorVersion: 3),
        .Package(url: "https://github.com/ishkawa/APIKit.git",
                 majorVersion: 3),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git",
                 majorVersion: 1),
        .Package(url: "https://github.com/behrang/YamlSwift.git", 
                 majorVersion: 3)
    ]
)
