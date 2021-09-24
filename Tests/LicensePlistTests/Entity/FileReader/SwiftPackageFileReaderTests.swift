//
//  SwiftPackageFileReaderTests.swift
//  LicensePlistTests
//
//  Created by yosshi4486 on 2021/04/06.
//

import XCTest
@testable import LicensePlistCore

class SwiftPackageFileReaderTests: XCTestCase {

    var fileURL: URL!

    var packageResolvedText: String {
        return #"""
        {
          "object": {
            "pins": [
              {
                "package": "APIKit",
                "repositoryURL": "https://github.com/ishkawa/APIKit.git",
                "state": {
                  "branch": null,
                  "revision": "c8f5320d84c4c34c0fd965da3c7957819a1ccdd4",
                  "version": "5.2.0"
                }
              },
              {
                "package": "HeliumLogger",
                "repositoryURL": "https://github.com/Kitura/HeliumLogger.git",
                "state": {
                  "branch": null,
                  "revision": "55fd2f0b70793017acee853c53cfcf8da0bd8d8d",
                  "version": "1.9.200"
                }
              },
              {
                "package": "LoggerAPI",
                "repositoryURL": "https://github.com/Kitura/LoggerAPI.git",
                "state": {
                  "branch": null,
                  "revision": "e82d34eab3f0b05391082b11ea07d3b70d2f65bb",
                  "version": "1.9.200"
                }
              },
              {
                "package": "swift-argument-parser",
                "repositoryURL": "https://github.com/apple/swift-argument-parser.git",
                "state": {
                  "branch": null,
                  "revision": "d2930e8fcf9c33162b9fcc1d522bc975e2d4179b",
                  "version": "1.0.1"
                }
              },
              {
                "package": "HTMLEntities",
                "repositoryURL": "https://github.com/Kitura/swift-html-entities.git",
                "state": {
                  "branch": null,
                  "revision": "2b14531d0c36dbb7c1c45a4d38db9c2e7898a307",
                  "version": "3.0.200"
                }
              },
              {
                "package": "swift-log",
                "repositoryURL": "https://github.com/apple/swift-log.git",
                "state": {
                  "branch": null,
                  "revision": "5d66f7ba25daf4f94100e7022febf3c75e37a6c7",
                  "version": "1.4.2"
                }
              },
              {
                "package": "Yaml",
                "repositoryURL": "https://github.com/behrang/YamlSwift.git",
                "state": {
                  "branch": null,
                  "revision": "287f5cab7da0d92eb947b5fd8151b203ae04a9a3",
                  "version": "3.4.4"
                }
              }
            ]
          },
          "version": 1
        }
        """#
    }

    override func setUpWithError() throws {
        fileURL = URL(fileURLWithPath: "\(TestUtil.testProjectsPath)/SwiftPackageManagerTestProject/SwiftPackageManagerTestProject.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved")
    }

    override func tearDownWithError() throws {
        fileURL = nil
    }

    func testInvalidPath() throws {
        let invalidFilePath = fileURL.deletingLastPathComponent().appendingPathComponent("Podfile.lock")
        let reader = SwiftPackageFileReader(path: invalidFilePath)
        XCTAssertThrowsError(try reader.read())
    }

    func testPackageSwift() throws {
        // Path for this package's Package.swift.
        let packageSwiftPath = TestUtil.sourceDir.appendingPathComponent("Package.swift").lp.fileURL
        let reader = SwiftPackageFileReader(path: packageSwiftPath)
        XCTAssertEqual(
            try reader.read()?.trimmingCharacters(in: .whitespacesAndNewlines),
            packageResolvedText.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    func testPackageResolved() throws {
        // Path for this package's Package.resolved.
        let packageResolvedPath = TestUtil.sourceDir.appendingPathComponent("Package.resolved").lp.fileURL
        let reader = SwiftPackageFileReader(path: packageResolvedPath)
        XCTAssertEqual(
            try reader.read()?.trimmingCharacters(in: .whitespacesAndNewlines),
            packageResolvedText.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

}
