import Foundation
import XCTest
import APIKit
@testable import LicensePlistCore

class GitHubLicenseTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        TestUtil.setGitHubToken()
    }

    func testCollect() throws {
        let carthage = GitHub(name: "NativePopup", nameSpecified: nil, owner: "mono0926", version: nil)
        let license = try GitHubLicense.download(carthage).resultSync().get()
        XCTAssertEqual(license.library, carthage)
        XCTAssertTrue(license.body.hasPrefix("MIT License"))
        XCTAssertEqual(license.githubResponse.kind.spdxId, "MIT")
    }

    func testCollect_forked() throws {
        let carthage = GitHub(name: "vapor", nameSpecified: nil, owner: "mono0926", version: nil)
        let license = try GitHubLicense.download(carthage).resultSync().get()
        XCTAssertEqual(license.library, carthage)
        XCTAssertTrue(license.body.hasPrefix("The MIT License (MIT)"))
        XCTAssertEqual(license.githubResponse.kind.spdxId, "MIT")
    }
    func testCollect_invalid() {
        let carthage = GitHub(name: "abcde", nameSpecified: nil, owner: "invalid", version: nil)
        let license = GitHubLicense.download(carthage).result
        XCTAssertTrue(license == nil)
    }
}
