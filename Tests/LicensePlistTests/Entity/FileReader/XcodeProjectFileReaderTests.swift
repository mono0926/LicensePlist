//
//  XcodeProjectFileReaderTests.swift
//  LicensePlistTests
//
//  Created by yosshi4486 on 2021/04/06.
//

import XCTest
@testable import LicensePlistCore

class XcodeProjectFileReaderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testReadXcodeProject() throws {
        #warning("TODO: This should be replcased to \"https://github.com/yosshi4486/LicensePlist/mono0926/master/Tests/LicensePlistTests/XcodeProjects/SwiftPackageManagerTestProject/SwiftPackageManagerTestProject.xcodeproj\" until I create pull request.")

        let githubXcodeprojURL = URL(string: "https://github.com/yosshi4486/LicensePlist/tree/fix-spm-licenses-gen/Tests/LicensePlistTests/XcodeProjects/SwiftPackageManagerTestProject/SwiftPackageManagerTestProject.xcodeproj")!
        let result = readXcodeProject(path: githubXcodeprojURL)
        XCTAssertNotNil(result)
    }

}
