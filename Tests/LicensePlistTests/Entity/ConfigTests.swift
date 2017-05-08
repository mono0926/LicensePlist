import Foundation
import XCTest
@testable import LicensePlistCore

class ConfigTests: XCTestCase {

    func testExcluded_true() {
        let target = Config(githubs: [], excludes: ["lib1"])
        XCTAssertTrue(target.excluded(name: "lib1"))
    }

    func testExcluded_false() {
        let target = Config(githubs: [], excludes: ["lib1"])
        XCTAssertFalse(target.excluded(name: "lib2"))
    }
}
