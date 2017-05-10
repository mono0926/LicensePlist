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

    func testApply_filterExcluded() {
        let config = Config(githubs: [], excludes: ["lib2"], renames: [:])
        // TODO:
        let shouldBeIncluded = GitHub.init(name: "lib1", owner: "o1", version: "")
        // TODO:
        // TODO:
        let result = config.filterExcluded([shouldBeIncluded, GitHub(name: "lib2", owner: "o2", version: "")])
        XCTAssertEqual(result, [shouldBeIncluded])
    }

    func testApply_githubs() {
        // TODO:
        let github1 = GitHub(name: "github1", owner: "g1", version: "")
        let config = Config(githubs: [github1], excludes: ["lib2"], renames: [:])
        // TODO:
        let shouldBeIncluded = GitHub(name: "lib1", owner: "o1", version: "")
        // TODO:
        let result = config.apply(githubs: [shouldBeIncluded, GitHub(name: "lib2", owner: "o2", version: "")])
        XCTAssertEqual(result, [github1, shouldBeIncluded])
    }

    func testApply_rename() {
        // TODO:
        var cocoapod1 = CocoaPodsLicense(library: CocoaPods(name: "lib1", version: ""), body: "body")
        let config = Config(githubs: [], excludes: [], renames: ["lib1": "lib1_renamed"])
        let result = config.rename([cocoapod1])

        cocoapod1.name = "lib1_renamed"
        XCTAssertEqual(result, [cocoapod1])
    }
}
