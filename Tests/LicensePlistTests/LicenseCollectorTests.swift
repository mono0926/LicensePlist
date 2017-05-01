import Foundation
import XCTest
import APIKit
import RxSwift
@testable import LicensePlistCore

class LicenseCollectorTests: XCTestCase {
    private let target = LicenseCollector()
    private let github1 = LibraryName.gitHub(owner: "mono0926", repo: "NativePopup")
    private let githubForked = LibraryName.gitHub(owner: "gram30", repo: "ios_sdk")
    private let githubInvalid = LibraryName.gitHub(owner: "invalid", repo: "abcde")
    private let name1 = LibraryName.name("RxSwift")

    override class func setUp() {
        super.setUp()
        TestUtil.setGitHubToken()
    }

    func testCollect_github1() {
        let results = target.collect(with: github1).result()
        XCTAssertEqual(results.count, 1)
        let result = results.first!
        XCTAssertEqual(result.name, github1.repoName)
        XCTAssertTrue(result.license.hasPrefix("MIT License"))
    }
    func testCollect_forked() {
        let results = target.collect(with: githubForked).result()
        XCTAssertEqual(results.count, 1)
        let result = results.first!
        XCTAssertEqual(result.name, githubForked.repoName)
        XCTAssertTrue(result.license.hasPrefix("Copyright (c)"))
    }
    func testCollect_invalid() {
        let results = target.collect(with: githubInvalid).result()
        XCTAssertTrue(results.isEmpty)
    }
    func testCollect_multiple() {
        let results = target.collect(with: [github1, name1]).result()
        XCTAssertEqual(results.count, 2)
        let result1 = results[0]
        XCTAssertEqual(result1.name, github1.repoName)
        XCTAssertTrue(result1.license.hasPrefix("MIT License"))
        let result2 = results[1]
        XCTAssertEqual(result2.name, name1.repoName)
        XCTAssertTrue(result2.license.hasPrefix("**The MIT License**"))
    }
}
