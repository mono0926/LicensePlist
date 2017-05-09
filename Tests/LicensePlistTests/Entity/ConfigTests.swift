import Foundation
import XCTest
@testable import LicensePlistCore

class ConfigTests: XCTestCase {

    func testExcluded() {
        let target = Config(githubs: [], excludes: ["lib1"], renames: [:])
        XCTAssertTrue(target.excluded(name: "lib1"))
        XCTAssertFalse(target.excluded(name: "lib2"))
    }

    func testExtractRegex() {
        XCTAssertEqual(Config.extractRegex("/^Core.*$/"), "^Core.*$")
        XCTAssertNil(Config.extractRegex("/^Core.*$/a"))
    }

    func testExcluded_regex() {
        let target = Config(githubs: [], excludes: ["/^lib.*$/"], renames: [:])
        XCTAssertTrue(target.excluded(name: "lib1"))
        XCTAssertTrue(target.excluded(name: "lib2"))
        XCTAssertFalse(target.excluded(name: "hello"))
    }

    func testApply_names() {
        let config = Config(githubs: [], excludes: ["lib2"], renames: [:])
        let shouldBeIncluded = GitHub.init(name: "lib1", owner: "o1")
        let result = config.apply(names: [shouldBeIncluded, GitHub(name: "lib2", owner: "o2")])
        XCTAssertEqual(result, [shouldBeIncluded])
    }

    func testApply_githubs() {
        let github1 = GitHub(name: "github1", owner: "g1")
        let config = Config(githubs: [github1], excludes: ["lib2"], renames: [:])
        let shouldBeIncluded = GitHub.init(name: "lib1", owner: "o1")
        let result = config.apply(githubs: [shouldBeIncluded, GitHub(name: "lib2", owner: "o2")])
        XCTAssertEqual(result, [github1, shouldBeIncluded])
    }
}
