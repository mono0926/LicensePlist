import Foundation
import XCTest
@testable import LicensePlistCore

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

    func testParse_nest_one() {
        let results = GitHub.load(
            .nest(
                content: """
                targets:
                    - reference: mtj0928/nest
                      version: 0.1.0
                """
            )
        )
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, GitHub(name: "nest", nameSpecified: nil, owner: "mtj0928", version: "0.1.0"))
    }

    func testParse_nest_multiple() {
        let results = GitHub.load(
            .nest(
                content: """
                targets:
                    - reference: mtj0928/nest
                      version: 0.1.0
                    - reference: mono0926/NativePopup
                      version: v1.8.4
                """
            )
        )
        XCTAssertTrue(results.count == 2)
        let result1 = results[0]
        XCTAssertEqual(result1, GitHub(name: "nest", nameSpecified: nil, owner: "mtj0928", version: "0.1.0"))
        let result2 = results[1]
        XCTAssertEqual(result2, GitHub(name: "NativePopup", nameSpecified: nil, owner: "mono0926", version: "v1.8.4"))
    }

    func testParse_nest_no_version() {
        let results = GitHub.load(
            .nest(
                content: """
                targets:
                    - reference: mtj0928/nest
                    - reference: mono0926/NativePopup
                """
            )
        )
        XCTAssertTrue(results.count == 2)
        let result1 = results[0]
        XCTAssertEqual(result1, GitHub(name: "nest", nameSpecified: nil, owner: "mtj0928", version: nil))
        let result2 = results[1]
        XCTAssertEqual(result2, GitHub(name: "NativePopup", nameSpecified: nil, owner: "mono0926", version: nil))
    }

    func testParse_mise_string() {
        let results = GitHub.load(
            .mise(
                content: """
                [tools]
                "ubi:BurntSushi/ripgrep" = "14.1.0"
                """
            )
        )
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, GitHub(name: "ripgrep", nameSpecified: nil, owner: "BurntSushi", version: "14.1.0"))
    }

    func testParse_mise_inlineTable() {
        let results = GitHub.load(
            .mise(
                content: """
                [tools]
                "github:SwiftGen/SwiftGen" = { version = "6.6.3", os = ["macos"] }
                """
            )
        )
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, GitHub(name: "SwiftGen", nameSpecified: nil, owner: "SwiftGen", version: "6.6.3"))
    }

    func testParse_mise_tableHeader() {
        let results = GitHub.load(
            .mise(
                content: """
                [tools."aqua:cli/cli"]
                version = "2.40.0"
                """
            )
        )
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, GitHub(name: "cli", nameSpecified: nil, owner: "cli", version: "2.40.0"))
    }

    func testParse_mise_skipsUnsupportedBackend() {
        let results = GitHub.load(
            .mise(
                content: """
                [tools]
                node = "20.11.0"
                "npm:eslint" = "9.0.0"
                "github:realm/SwiftLint" = "0.55.1"
                """
            )
        )
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, GitHub(name: "SwiftLint", nameSpecified: nil, owner: "realm", version: "0.55.1"))
    }

    func testParse_mise_rename() {
        let results = GitHub.load(
            .mise(
                content: """
                [tools]
                "ubi:BurntSushi/ripgrep" = "14.1.0"
                """
            ),
            renames: ["ripgrep": "ripgrep2"]
        )
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, GitHub(name: "ripgrep", nameSpecified: "ripgrep2", owner: "BurntSushi", version: "14.1.0"))
    }
}
