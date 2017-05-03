import Foundation
import XCTest
@testable import LicensePlistCore

classGitHubParserTests: XCTestCase {

    func testParse_empty() {
        let results = GitHub.parse("(　´･‿･｀)")
        XCTAssertTrue(results.isEmpty)
    }

    func testParse_one() {
        let results = GitHub.parse("github \"mono0926/NativePopup\"")
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, GitHub(name: "NativePopup", owner: "mono0926"))
    }

    func testParse_one_dot() {
        let results = GitHub.parse("github \"tephencelis/SQLite.swift\"")
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, GitHub(name: "SQLite.swift", owner: "tephencelis"))
    }

    func testParse_one_hyphen() {
        let results = GitHub.parse("github \"mono0926/ios-license-generator\"")
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, GitHub(name: "ios-license-generator", owner: "mono0926"))
    }

    func testParse_multiple() {
        let results = GitHub.parse("github \"mono0926/NativePopup\"\ngithub \"ReactiveX/RxSwift\"")
        XCTAssertTrue(results.count == 2)
        let result1 = results[0]
        XCTAssertEqual(result1, GitHub(name: "NativePopup", owner: "mono0926"))
        let result2 = results[1]
        XCTAssertEqual(result2, GitHub(name: "RxSwift", owner: "ReactiveX"))
    }
}
