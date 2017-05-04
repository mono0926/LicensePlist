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
        .Package(url: "git@github.com:kylef/Commander.git",
                 majorVersion: 0),
        .Package(url: "git@github.com:ikesyo/Himotoki.git",
                 majorVersion: 3),
        .Package(url: "git@github.com:ishkawa/APIKit.git",
                 majorVersion: 3),
        .Package(url: "git@github.com:IBM-Swift/HeliumLogger.git",
                 majorVersion: 1),
        .Package(url: "git@github.com:drmohundro/SWXMLHash.git",
                 majorVersion: 3)
    ]
)
