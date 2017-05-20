import Foundation
import XCTest
import APIKit
@testable import LicensePlistCore

class GitHubLicenseTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        TestUtil.setGitHubToken()
    }

    func testCollect() {
        let carthage = GitHub(name: "NativePopup", nameSpecified: nil, owner: "mono0926", version: nil)
        let license = GitHubLicense.download(carthage).resultSync().value!
        XCTAssertEqual(license.library, carthage)
        XCTAssertTrue(license.body.hasPrefix("MIT License"))
        XCTAssertEqual(license.githubResponse.kind.spdxId, "MIT")
    }

    func testCollect_forked() {
        let carthage = GitHub(name: "ios_sdk", nameSpecified: nil, owner: "gram30", version: nil)
        let license = GitHubLicense.download(carthage).resultSync().value!
        var forked = carthage
        forked.owner = "adjust"
        XCTAssertEqual(license.library, forked)
        XCTAssertTrue(license.body.hasPrefix("Copyright (c)"))
        XCTAssertEqual(license.githubResponse.kind.spdxId, "MIT")
    }
    func testCollect_invalid() {
        let carthage = GitHub(name: "abcde", nameSpecified: nil, owner: "invalid", version: nil)
        let license = GitHubLicense.download(carthage).result
        XCTAssertTrue(license == nil)
    }
}
