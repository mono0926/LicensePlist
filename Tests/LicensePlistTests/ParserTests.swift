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
        XCTAssertEqual(result, LibraryName.gitHub(owner: "mono0926", repo: "NativePopup"))
    }

    func testParse_duplicated() {
        let results = target.parse(content: "github \"mono0926/NativePopup\"\ngithub \"mono0926/NativePopup\"")
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, LibraryName.gitHub(owner: "mono0926", repo: "NativePopup"))
    }

    func testParse_multiple() {
        let results = target.parse(content: "github \"mono0926/NativePopup\"\ngithub \"ReactiveX/RxSwift\"")
        XCTAssertTrue(results.count == 2)
        let result1 = results[0]
        XCTAssertEqual(result1, LibraryName.gitHub(owner: "mono0926", repo: "NativePopup"))
        let result2 = results[1]
        XCTAssertEqual(result2, LibraryName.gitHub(owner: "ReactiveX", repo: "RxSwift"))
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
        XCTAssertEqual(result, LibraryName.name("SwipeView"))
    }

    func testParse_duplicated() {
        let results = target.parse(content: "pod 'SwipeView'\npod 'SwipeView'")
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, LibraryName.name("SwipeView"))
    }

    func testParse_multiple() {
        let results = target.parse(content: "pod 'SwipeView'\npod 'RxSwift'")
        XCTAssertTrue(results.count == 2)
        let result1 = results[0]
        XCTAssertEqual(result1, LibraryName.name("RxSwift"))
        let result2 = results[1]
        XCTAssertEqual(result2, LibraryName.name("SwipeView"))
    }

    func testParse_slash() {
        let results = target.parse(content: "pod 'Firebase/Core'")
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, LibraryName.name("Firebase"))
    }

    func testParse_double_quotes() {
        let results = target.parse(content: "pod \"SwipeView\"")
        XCTAssertTrue(results.count == 1)
        let result = results.first
        XCTAssertEqual(result, LibraryName.name("SwipeView"))
    }
}
