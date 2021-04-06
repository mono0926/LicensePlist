//
//  XcodeProjectFileReaderTests.swift
//  LicensePlistTests
//
//  Created by yosshi4486 on 2021/04/06.
//

import XCTest
@testable import LicensePlistCore

@available(OSX 10.11, *)
class XcodeProjectFileReaderTests: XCTestCase {

    var projectFileURL: URL!
    var wildcardFileURL: URL!

    override func setUpWithError() throws {
        projectFileURL = URL(fileURLWithPath: "\(TestUtil.testProjectsPath)/SwiftPackageManagerTestProject/SwiftPackageManagerTestProject.xcodeproj")
        wildcardFileURL = URL(fileURLWithPath: "\(TestUtil.testProjectsPath)/SwiftPackageManagerTestProject/*")

        print("fileURL: \(String(describing: projectFileURL))")
        print("wildcardURL: \(String(describing: wildcardFileURL))")
    }

    override func tearDownWithError() throws {
        projectFileURL = nil
        wildcardFileURL = nil
    }

    func testProjectPathWhenSpecifiesCorrectFilePath() throws {
        let fileReader = XcodeProjectFileReader(path: projectFileURL)
        XCTAssertEqual(fileReader.projectPath, projectFileURL)
    }

    func testProjectPathWhenSpecifiesWildcard() throws {
        let fileReader = XcodeProjectFileReader(path: wildcardFileURL)
        XCTAssertEqual(fileReader.projectPath, projectFileURL)
    }

    func testReadNotNil() throws {
        let fileReader = XcodeProjectFileReader(path: projectFileURL)
        XCTAssertNotNil(try fileReader.read())
    }

    func testReadPackageResolved() throws {
        let fileReader = XcodeProjectFileReader(path: projectFileURL)
        let expected = #"""
        {
          "object": {
            "pins": [
              {
                "package": "APIKit",
                "repositoryURL": "https://github.com/ishkawa/APIKit",
                "state": {
                  "branch": null,
                  "revision": "c8f5320d84c4c34c0fd965da3c7957819a1ccdd4",
                  "version": "5.2.0"
                }
              },
              {
                "package": "Commander",
                "repositoryURL": "https://github.com/kylef/Commander.git",
                "state": {
                  "branch": null,
                  "revision": "4b6133c3071d521489a80c38fb92d7983f19d438",
                  "version": "0.9.1"
                }
              },
              {
                "package": "rswift",
                "repositoryURL": "https://github.com/mac-cain13/R.swift",
                "state": {
                  "branch": null,
                  "revision": "18ad905c6f8f0865042e1d1ee4effc7291aa899d",
                  "version": "5.4.0"
                }
              },
              {
                "package": "Spectre",
                "repositoryURL": "https://github.com/kylef/Spectre.git",
                "state": {
                  "branch": null,
                  "revision": "f79d4ecbf8bc4e1579fbd86c3e1d652fb6876c53",
                  "version": "0.9.2"
                }
              },
              {
                "package": "Swinject",
                "repositoryURL": "https://github.com/Swinject/Swinject",
                "state": {
                  "branch": null,
                  "revision": "8a76d2c74bafbb455763487cc6a08e91bad1f78b",
                  "version": "2.7.1"
                }
              },
              {
                "package": "XcodeEdit",
                "repositoryURL": "https://github.com/tomlokhorst/XcodeEdit",
                "state": {
                  "branch": null,
                  "revision": "dab519997ca05833470c88f0926b27498911ecbf",
                  "version": "2.7.7"
                }
              }
            ]
          },
          "version": 1
        }
        """#
        XCTAssertEqual(
            try fileReader.read()?.trimmingCharacters(in: .whitespacesAndNewlines),
            expected.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    /// Test Xcode update either xcodeproj one or the other one.
    ///
    /// The problem is occured when developer adds additional xcworkspace from the middle of project processt.
    /// Licenses should be latest, but this behaviour cause unlisted OSS software.
    func testTwoDifferentPackageResolvedAreExist() throws {
        let projectXcworkspacePackageResolvedFileURL = projectFileURL!
            .appendingPathComponent("project.xcworkspace")
            .appendingPathComponent("xcshareddata")
            .appendingPathComponent("swiftpm")
            .appendingPathComponent("Package.resolved")

        let cocoapodsXcworkspacePackageResolvedFIleURL = projectFileURL
            .deletingPathExtension()
            .appendingPathExtension("xcworkspace")
            .appendingPathComponent("xcshareddata")
            .appendingPathComponent("swiftpm")
            .appendingPathComponent("Package.resolved")


        // URLResourceKey
        // https://developer.apple.com/documentation/foundation/urlresourcekey

        let projectPackageResolvedFileModificationDate = try projectXcworkspacePackageResolvedFileURL
            .resourceValues(forKeys: [.attributeModificationDateKey])
            .attributeModificationDate

        let cocoapodPackageResolvedFileModificationDate = try cocoapodsXcworkspacePackageResolvedFIleURL
            .resourceValues(forKeys: [.attributeModificationDateKey])
            .attributeModificationDate

        XCTAssertNotEqual(projectPackageResolvedFileModificationDate, cocoapodPackageResolvedFileModificationDate)
    }

}
