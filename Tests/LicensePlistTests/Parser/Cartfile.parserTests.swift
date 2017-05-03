 import Foundation
import XCTest
@testable import LicensePlistCore

class CartfileParserTests: XCTestCase {

    func testParse_empty() {
        let results = Carthage.parse("(　´･‿･｀)")
        XCTAssertTrue(results.isEmpty)
    }

    func testParse_one() {
        let results = Carthage.parse("github \"mono0926/NativePopup\"")
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, Carthage(name: "NativePopup", owner: "mono0926"))
    }

    func testParse_multiple() {
        let results = Carthage.parse("github \"mono0926/NativePopup\"\ngithub \"ReactiveX/RxSwift\"")
        XCTAssertTrue(results.count == 2)
        let result1 = results[0]
        XCTAssertEqual(result1, Carthage(name: "NativePopup", owner: "mono0926"))
        let result2 = results[1]
        XCTAssertEqual(result2, Carthage(name: "RxSwift", owner: "ReactiveX"))
    }
}
