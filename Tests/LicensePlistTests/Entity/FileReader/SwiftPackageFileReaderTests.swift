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
          "pins" : [
            {
              "identity" : "apikit",
              "kind" : "remoteSourceControl",
              "location" : "https://github.com/ishkawa/APIKit.git",
              "state" : {
                "revision" : "4e7f42d93afb787b0bc502171f9b5c12cf49d0ca",
                "version" : "5.3.0"
              }
            },
            {
              "identity" : "flatten",
              "kind" : "remoteSourceControl",
              "location" : "https://github.com/YusukeHosonuma/Flatten.git",
              "state" : {
                "revision" : "5286148aa255f57863e0d7e2b827ca6b91677051",
                "version" : "0.1.0"
              }
            },
            {
              "identity" : "heliumlogger",
              "kind" : "remoteSourceControl",
              "location" : "https://github.com/Kitura/HeliumLogger.git",
              "state" : {
                "revision" : "fc2a71597ae974da5282d751bcc11965964bccce",
                "version" : "2.0.0"
              }
            },
            {
              "identity" : "loggerapi",
              "kind" : "remoteSourceControl",
              "location" : "https://github.com/Kitura/LoggerAPI.git",
              "state" : {
                "revision" : "4e6b45e850ffa275e8e26a24c6454fd709d5b6ac",
                "version" : "2.0.0"
              }
            },
            {
              "identity" : "shlist",
              "kind" : "remoteSourceControl",
              "location" : "https://github.com/YusukeHosonuma/SHList.git",
              "state" : {
                "revision" : "6c61f5382dd07a64d76bc8b7fad8cec0d8a4ff7a",
                "version" : "0.1.0"
              }
            },
            {
              "identity" : "swift-argument-parser",
              "kind" : "remoteSourceControl",
              "location" : "https://github.com/apple/swift-argument-parser.git",
              "state" : {
                "revision" : "9f39744e025c7d377987f30b03770805dcb0bcd1",
                "version" : "1.1.4"
              }
            },
            {
              "identity" : "swift-html-entities",
              "kind" : "remoteSourceControl",
              "location" : "https://github.com/Kitura/swift-html-entities.git",
              "state" : {
                "revision" : "d8ca73197f59ce260c71bd6d7f6eb8bbdccf508b",
                "version" : "4.0.1"
              }
            },
            {
              "identity" : "swift-log",
              "kind" : "remoteSourceControl",
              "location" : "https://github.com/apple/swift-log.git",
              "state" : {
                "revision" : "5d66f7ba25daf4f94100e7022febf3c75e37a6c7",
                "version" : "1.4.2"
              }
            },
            {
              "identity" : "swiftparamtest",
              "kind" : "remoteSourceControl",
              "location" : "https://github.com/YusukeHosonuma/SwiftParamTest",
              "state" : {
                "revision" : "f513e1dbbdd86e2ca2b672537f4bcb4417f94c27",
                "version" : "2.2.1"
              }
            },
            {
              "identity" : "xcodeedit",
              "kind" : "remoteSourceControl",
              "location" : "https://github.com/tomlokhorst/XcodeEdit.git",
              "state" : {
                "revision" : "cd466d6e8c5ffd2f2b61165d37b0646f09068e1e",
                "version" : "2.9.0"
              }
            },
            {
              "identity" : "yamlswift",
              "kind" : "remoteSourceControl",
              "location" : "https://github.com/behrang/YamlSwift.git",
              "state" : {
                "revision" : "287f5cab7da0d92eb947b5fd8151b203ae04a9a3",
                "version" : "3.4.4"
              }
            }
          ],
          "version" : 2
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
