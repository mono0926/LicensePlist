import Foundation
import XCTest
@testable import LicensePlistCore

class CartfileParserTests: XCTestCase {
    private var target = CartfileParser()

    func testParse_empty() {
        let results = target.parse(content: "(　´･‿･｀)")
        XCTAssertTrue(results.isEmpty)
    }

    func testParse_one() {
        let results = target.parse(content: "github \"mono0926/NativePopup\"")
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, Library(source: .cartfile, name: "NativePopup", owner: "mono0926"))
    }

    func testParse_duplicated() {
        let results = target.parse(content: "github \"mono0926/NativePopup\"\ngithub \"mono0926/NativePopup\"")
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, Library(source: .cartfile, name: "NativePopup", owner: "mono0926"))
    }

    func testParse_multiple() {
        let results = target.parse(content: "github \"mono0926/NativePopup\"\ngithub \"ReactiveX/RxSwift\"")
        XCTAssertTrue(results.count == 2)
        let result1 = results[0]
        XCTAssertEqual(result1, Library(source: .cartfile, name: "NativePopup", owner: "mono0926"))
        let result2 = results[1]
        XCTAssertEqual(result2, Library(source: .cartfile, name: "RxSwift", owner: "ReactiveX"))
    }
}

class PodfileParserTests: XCTestCase {
    private var target = PodfileParser()

    func testParse_empty() {
        let results = target.parse(content: "(　´･‿･｀)")
        XCTAssertTrue(results.isEmpty)
    }

    func testParse_one() {
        let results = target.parse(content: "pod 'SwipeView'")
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, Library(source: .podfile, name: "SwipeView", owner: nil))
    }

    func testParse_duplicated() {
        let results = target.parse(content: "pod 'SwipeView'\npod 'SwipeView'")
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, Library(source: .podfile, name: "SwipeView", owner: nil))
    }

    func testParse_multiple() {
        let results = target.parse(content: "pod 'SwipeView'\npod 'RxSwift'")
        XCTAssertTrue(results.count == 2)
        let result1 = results[0]
        XCTAssertEqual(result1, Library(source: .podfile, name: "RxSwift", owner: nil))
        let result2 = results[1]
        XCTAssertEqual(result2, Library(source: .podfile, name: "SwipeView", owner: nil))
    }

    func testParse_slash() {
        let results = target.parse(content: "pod 'Firebase/Core'")
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, Library(source: .podfile, name: "Firebase", owner: nil))
    }

    func testParse_double_quotes() {
        let results = target.parse(content: "pod \"SwipeView\"")
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, Library(source: .podfile, name: "SwipeView", owner: nil))
    }
}
