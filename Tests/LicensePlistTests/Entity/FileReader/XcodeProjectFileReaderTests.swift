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

    func testOldPackageResolvedNotUsed() throws {
        let fileReader = XcodeProjectFileReader(path: projectFileURL)
        let data = try Data(contentsOf: TestUtil.testResourceDir.appendingPathComponent("OldExpectedPackage.resolved").lp.fileURL)
        let oldExpectedPackageResolved = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertNotEqual(try fileReader.read(), oldExpectedPackageResolved)
    }

    func testNewPackageResolvedUsed() throws {
        let fileReader = XcodeProjectFileReader(path: projectFileURL)
        let data = try Data(contentsOf: TestUtil.testResourceDir.appendingPathComponent("NewExpectedPackage.resolved").lp.fileURL)
        let newExpectedPackageResolved = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertEqual(try fileReader.read(), newExpectedPackageResolved)
    }

    /// Test Xcode update either xcodeproj one or the other one.
    ///
    /// The problem is occurred when developer adds additional xcworkspace from the middle of project process.
    /// Licenses should be latest, but this behavior cause unlisted OSS software.
    func testTwoDifferentPackageResolvedAreExist() throws {
        let projectXcworkspacePackageResolvedFileURL = try XCTUnwrap(projectFileURL)
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
