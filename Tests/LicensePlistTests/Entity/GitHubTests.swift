import Foundation
@testable import LicensePlistCore
import XCTest

class GitHubTests: XCTestCase {
    func testParse_empty() {
        let results = GitHub.load(.carthage(content: "(　´･‿･｀)"))
        XCTAssertTrue(results.isEmpty)
    }

    func testParse_one() {
        let results = GitHub.load(.carthage(content: "github \"mono0926/NativePopup\""))
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, GitHub(name: "NativePopup", nameSpecified: nil, owner: "mono0926", version: nil))
    }

    func testParse_one_rename() {
        let results = GitHub.load(.carthage(content: "github \"mono0926/NativePopup\""), renames: ["NativePopup": "NativePopup2"])
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, GitHub(name: "NativePopup", nameSpecified: "NativePopup2", owner: "mono0926", version: nil))
    }

    func testParse_one_dot() {
        let results = GitHub.load(.carthage(content: "github \"tephencelis/SQLite.swift\""))
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, GitHub(name: "SQLite.swift", nameSpecified: nil, owner: "tephencelis", version: nil))
    }

    func testParse_one_hyphen() {
        let results = GitHub.load(.carthage(content: "github \"mono0926/ios-license-generator\""))
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, GitHub(name: "ios-license-generator", nameSpecified: nil, owner: "mono0926", version: nil))
    }

    func testParse_multiple() {
        let results = GitHub.load(.carthage(content: "github \"mono0926/NativePopup\"\ngithub \"ReactiveX/RxSwift\""))
        XCTAssertTrue(results.count == 2)
        let result1 = results[0]
        XCTAssertEqual(result1, GitHub(name: "NativePopup", nameSpecified: nil, owner: "mono0926", version: nil))
        let result2 = results[1]
        XCTAssertEqual(result2, GitHub(name: "RxSwift", nameSpecified: nil, owner: "ReactiveX", version: nil))
    }

    func testParse_one_versoin() {
        let results = GitHub.load(.carthage(content: "github \"mono0926/NativePopup\" \"1.8.4\""))
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, GitHub(name: "NativePopup", nameSpecified: nil, owner: "mono0926", version: "1.8.4"))
    }

    func testParse_one_versoin_v() {
        let results = GitHub.load(.carthage(content: "github \"mono0926/NativePopup\" \"v1.8.4\""))
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, GitHub(name: "NativePopup", nameSpecified: nil, owner: "mono0926", version: "v1.8.4"))
    }

    func testParse_one_hash() {
        let results = GitHub.load(.carthage(content: "github \"mono0926/NativePopup\" \"e64dcc63d4720f04eec8700b31ecaee188b6483a\""))
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, GitHub(name: "NativePopup", nameSpecified: nil, owner: "mono0926", version: "e64dcc6"))
    }
}
