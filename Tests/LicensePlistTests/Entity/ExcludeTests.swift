import Foundation
import XCTest
import Yams
@testable import LicensePlistCore

class ExcludeTests: XCTestCase {

    func testInit_yaml_dictionary() {
        let node: Node = [
            "name": "LicensePlist",
            "owner": "mono0926",
            "source": "https://github.com/mono0926/LicensePlist",
            "licenseType": "MIT"
        ]
        let exclude = Exclude(from: node)
        XCTAssertNotNil(exclude)
        XCTAssertEqual(exclude!.name, node.mapping!["name"]!.string)
        XCTAssertEqual(exclude!.owner, node.mapping!["owner"]!.string)
        XCTAssertEqual(exclude!.source, node.mapping!["source"]!.string)
        XCTAssertEqual(exclude!.licenseType, node.mapping!["licenseType"]!.string)
    }

    func testInit_yaml_dictionary_missing_some_properties() {
        let node: Node = [
            "name": "LicensePlist",
            "owner": "mono0926"
        ]
        let exclude = Exclude(from: node)
        XCTAssertNotNil(exclude)
        XCTAssertEqual(exclude!.name, node.mapping!["name"]!.string)
        XCTAssertEqual(exclude!.owner, node.mapping!["owner"]!.string)
        XCTAssertNil(exclude!.source)
        XCTAssertNil(exclude!.licenseType)
    }

    func testInit_yaml_no_properties() {
        let node: Node = [:]
        let exclude = Exclude(from: node)
        XCTAssertNil(exclude)
    }

    func testInit_yaml_invalid_properties() {
        let node: Node = ["invalid": "invalid"]
        let exclude = Exclude(from: node)
        XCTAssertNil(exclude)
    }

    func testInit_yaml_string() {
        let testString = "LicensePlist"
        let node = Node(testString)
        let exclude = Exclude(from: node)
        XCTAssertNotNil(exclude)
        XCTAssertEqual(exclude!.name, testString)
        XCTAssertNil(exclude!.owner)
        XCTAssertNil(exclude!.source)
        XCTAssertNil(exclude!.licenseType)
    }

    func testInit_yaml_invalid_yaml_type() {
        let node = Node([Node]())
        let exclude = Exclude(from: node)
        XCTAssertNil(exclude)
    }

    func testInit_yaml_invalid_license_type() {
        let node: Node = [
            "licenseType": "invalid"
        ]
        let exclude = Exclude(from: node)
        XCTAssertNotNil(exclude)
    }
}
