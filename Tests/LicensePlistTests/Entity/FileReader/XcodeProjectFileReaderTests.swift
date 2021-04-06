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

    var testURLBase: URL!
    var fileURL: URL!
    var wildcardFileURL: URL!

    override func setUpWithError() throws {
        let testFilePath = #file

        // The url deeply depends on this file location and XcodeProjects location. If any fix will be added, please fix this baseURL.
        let baseURL = URL(string: testFilePath)!
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("XcodeProjects")

        fileURL = URL(fileURLWithPath: "\(baseURL)/SwiftPackageManagerTestProject/SwiftPackageManagerTestProject.xcodeproj")
        wildcardFileURL = URL(fileURLWithPath: "\(baseURL)/SwiftPackageManagerTestProject/*")

        print("fileURL: \(String(describing: fileURL))")
        print("wildcardURL: \(String(describing: wildcardFileURL))")
    }

    override func tearDownWithError() throws {
        fileURL = nil
        wildcardFileURL = nil
    }

    func testProjectPathWhenSpecifiesCorrectFilePath() throws {
        let fileReader = XcodeProjectFileReader(path: fileURL)
        XCTAssertEqual(fileReader.projectPath, fileURL)
    }

    func testProjectPathWhenSpecifiesWildcard() throws {
        let fileReader = XcodeProjectFileReader(path: wildcardFileURL)
        XCTAssertEqual(fileReader.projectPath, fileURL)
    }

}
