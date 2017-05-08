import Foundation
import XCTest
@testable import LicensePlistCore

class HasNameTests: XCTestCase {

    func testfilterExcluded() {
        let config = Config(githubs: [], excludes: ["lib2"])
        let shouldBeIncluded = GitHub.init(name: "lib1", owner: "o1")
        let result = [shouldBeIncluded, GitHub.init(name: "lib2", owner: "o2")]
        .filterExcluded(config: config)
        XCTAssertEqual(result, [shouldBeIncluded])
    }
}
