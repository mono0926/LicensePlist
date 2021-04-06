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
                  "revision": "86d51ecee0bc0ebdb53fb69b11a24169a69097ba",
                  "version": "4.1.0"
                }
              },
              {
                "package": "HeliumLogger",
                "repositoryURL": "https://github.com/IBM-Swift/HeliumLogger.git",
                "state": {
                  "branch": null,
                  "revision": "146a36c2a91270e4213fa7d7e8192cd2e55d0ace",
                  "version": "1.9.0"
                }
              },
              {
                "package": "LoggerAPI",
                "repositoryURL": "https://github.com/IBM-Swift/LoggerAPI.git",
                "state": {
                  "branch": null,
                  "revision": "3357dd9526cdf9436fa63bb792b669e6efdc43da",
                  "version": "1.9.0"
                }
              },
              {
                "package": "Result",
                "repositoryURL": "https://github.com/antitypical/Result.git",
                "state": {
                  "branch": null,
                  "revision": "2ca499ba456795616fbc471561ff1d963e6ae160",
                  "version": "4.1.0"
                }
              },
              {
                "package": "swift-argument-parser",
                "repositoryURL": "https://github.com/apple/swift-argument-parser.git",
                "state": {
                  "branch": null,
                  "revision": "92646c0cdbaca076c8d3d0207891785b3379cbff",
                  "version": "0.3.1"
                }
              },
              {
                "package": "HTMLEntities",
                "repositoryURL": "https://github.com/IBM-Swift/swift-html-entities.git",
                "state": {
                  "branch": null,
                  "revision": "744c094976355aa96ca61b9b60ef0a38e979feb7",
                  "version": "3.0.14"
                }
              },
              {
                "package": "swift-log",
                "repositoryURL": "https://github.com/apple/swift-log.git",
                "state": {
                  "branch": null,
                  "revision": "eba9b323b5ba542c119ff17382a4ce737bcdc0b8",
                  "version": "0.0.0"
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
        let packageSwiftPath = TestUtil.sourceDir.appendingPathComponent("Package.swift").fileURL
        let reader = SwiftPackageFileReader(path: packageSwiftPath)
        XCTAssertEqual(
            try reader.read()?.trimmingCharacters(in: .whitespacesAndNewlines),
            packageResolvedText.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    func testPackageResolved() throws {
        // Path for this package's Package.resolved.
        let packageResolvedPath = TestUtil.sourceDir.appendingPathComponent("Package.resolved").fileURL
        let reader = SwiftPackageFileReader(path: packageResolvedPath)
        XCTAssertEqual(
            try reader.read()?.trimmingCharacters(in: .whitespacesAndNewlines),
            packageResolvedText.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

}
