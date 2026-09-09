import Foundation
import XCTest
@testable import LicensePlistCore

class OptionalExtensionTests: XCTestCase {

    func testAsPathURL() {
        let noneString: String? = nil
        XCTAssertNil(noneString.asPathURL())

        let someString: String? = "/path/to/dir"
        let url = someString.asPathURL()
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.standardizedFileURL.path, "/path/to/dir")
    }

    func testAsPathURLWithOtherAndDefault_selfTakesPrecedence() {
        let root = URL(fileURLWithPath: "/project/root", isDirectory: true)
        let cliPath: String? = "sub/output"
        let yamlURL = URL(fileURLWithPath: "yaml/output", relativeTo: root)

        let result = cliPath.asPathURL(other: yamlURL, default: "default/output", relativeTo: root)
        XCTAssertEqual(result.standardizedFileURL.path, "/project/root/sub/output")
    }

    func testAsPathURLWithOtherAndDefault_otherUsedWhenSelfNil() {
        let root = URL(fileURLWithPath: "/project/root", isDirectory: true)
        let cliPath: String? = nil
        let yamlURL = URL(fileURLWithPath: "yaml/output", relativeTo: root)

        let result = cliPath.asPathURL(other: yamlURL, default: "default/output", relativeTo: root)
        XCTAssertEqual(result.standardizedFileURL.path, "/project/root/yaml/output")
    }

    func testAsPathURLWithOtherAndDefault_defaultUsedWhenBothNil() {
        let root = URL(fileURLWithPath: "/project/root", isDirectory: true)
        let cliPath: String? = nil
        let yamlURL: URL? = nil

        let result = cliPath.asPathURL(other: yamlURL, default: "default/output", relativeTo: root)
        XCTAssertEqual(result.standardizedFileURL.path, "/project/root/default/output")
    }

    func testAsPathURLWithOtherAndDefault_nilRootFallback() {
        let cliPath: String? = nil
        let yamlURL: URL? = nil

        let result = cliPath.asPathURL(other: yamlURL, default: "default/output", relativeTo: nil)
        XCTAssertEqual(result.path, URL(fileURLWithPath: "default/output").path)
    }

    func testAsPathURLWithOther_optionalResult() {
        let root = URL(fileURLWithPath: "/project/root", isDirectory: true)
        let nonePath: String? = nil
        let noneOther: URL? = nil
        XCTAssertNil(nonePath.asPathURL(other: noneOther, relativeTo: root))

        let someOther = URL(fileURLWithPath: "other", relativeTo: root)
        XCTAssertEqual(nonePath.asPathURL(other: someOther, relativeTo: root)?.standardizedFileURL.path, "/project/root/other")

        let somePath: String? = "cli/path"
        XCTAssertEqual(somePath.asPathURL(other: someOther, relativeTo: root)?.standardizedFileURL.path, "/project/root/cli/path")
    }
}
