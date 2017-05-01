import Foundation
import XCTest
@testable import LicensePlistCore

class TransformerTests: XCTestCase {
    private var target = Transformer()
    private let github1 = Library(source: .cartfile, name: "RepoA", owner: "OwnerA")
    private let github2 = Library(source: .cartfile, name: "RepoB", owner: "OwnerA")
    private let github3 = Library(source: .cartfile, name: "RepoA", owner: "OwnerB")
    private let name1 = Library(source: .podfile, name: "RepoA", owner: nil)

    func testNormalize_empty() {
        XCTAssertEqual(target.normalize([]), [])
    }
    func testNormalize_one() {
        XCTAssertEqual(target.normalize([github1]), [github1])
    }
    func testNormalize_one_one_same() {
        XCTAssertEqual(target.normalize([github1], [github1]), [github1])
    }
    func testNormalize_one_one_other() {
        XCTAssertEqual(target.normalize([github1], [github2]), [github1, github2])
    }
    func testNormalize_one_one_same_repo_name() {
        XCTAssertEqual(target.normalize([github1], [github3]), [github1])
    }
    func testNormalize_one_name() {
        XCTAssertEqual(target.normalize([name1]), [name1])
    }
    func testNormalize_one_one_name() {
        XCTAssertEqual(target.normalize([name1], [github1]), [github1])
    }
    func testNormalize_one_one_name2() {
        XCTAssertEqual(target.normalize([name1], [github2]), [name1, github2])
    }
}
