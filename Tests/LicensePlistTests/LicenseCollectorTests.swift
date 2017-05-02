import Foundation
import XCTest
import APIKit
import RxSwift
import RxBlocking
@testable import LicensePlistCore

class LicenseCollectorTests: XCTestCase {
    private let target = LicenseCollector()
    private let github1 = Library(source: .cartfile, name: "NativePopup", owner: "mono0926")
    private let githubForked = Library(source: .cartfile, name: "ios_sdk", owner: "gram30")
    private let githubInvalid = Library(source: .cartfile, name: "abcde", owner: "invalid")
    private let name1 = Library(source: .podfile, name: "RxSwift", owner: nil)

    override class func setUp() {
        super.setUp()
        TestUtil.setGitHubToken()
    }

    func testCollect_github1() {
        let result = try! target.collect(with: github1).toBlocking().single()!
        XCTAssertEqual(result.library.name, github1.name)
        XCTAssertTrue(result.body.hasPrefix("MIT License"))
        XCTAssertEqual(result.license.downloadUrl, URL(string: "https://raw.githubusercontent.com/mono0926/NativePopup/master/LICENSE"))
        XCTAssertEqual(result.license.kind.spdxId, "MIT")
    }

    func testCollect_forked() {
        let result = try! target.collect(with: githubForked).toBlocking().single()!
        XCTAssertEqual(result.library.name, githubForked.name)
        XCTAssertTrue(result.body.hasPrefix("Copyright (c)"))
        XCTAssertEqual(result.license.downloadUrl, URL(string: "https://raw.githubusercontent.com/adjust/ios_sdk/master/MIT-LICENSE"))
        XCTAssertEqual(result.license.kind.spdxId, "MIT")
    }
    func testCollect_invalid() {
        let result = try! target.collect(with: githubInvalid).toBlocking().first()
        XCTAssertNil(result)
    }
    func testCollect_multiple() {
        let results = try! target.collect(with: [github1, name1]).toBlocking().toArray()
        XCTAssertEqual(results.count, 2)
        let result1 = results[0]
        XCTAssertEqual(result1.library.name, github1.name)
        XCTAssertTrue(result1.body.hasPrefix("MIT License"))
        XCTAssertEqual(result1.license.downloadUrl, URL(string: "https://raw.githubusercontent.com/mono0926/NativePopup/master/LICENSE"))
        XCTAssertEqual(result1.license.kind.spdxId, "MIT")
        let result2 = results[1]
        XCTAssertEqual(result2.library.name, name1.name)
        XCTAssertTrue(result2.body.hasPrefix("**The MIT License**"))
        XCTAssertEqual(result2.license.downloadUrl, URL(string: "https://raw.githubusercontent.com/ReactiveX/RxSwift/master/LICENSE.md"))
        XCTAssertEqual(result2.license.kind.spdxId, "MIT")
    }
}
