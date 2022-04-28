import Foundation
import XCTest
import Yaml
@testable import LicensePlistCore

class ExcludeTests: XCTestCase {

    func testInit_yaml_dictionary() {
        let testDict: [Yaml: Yaml] = [
            "name": "LicensePlist",
            "owner": "mono0926",
            "source": "https://github.com/mono0926/LicensePlist",
            "licenseType": "MIT"
        ]
        let yaml = Yaml.dictionary(testDict)
        let exclude = Exclude(from: yaml)
        XCTAssertNotNil(exclude)
        XCTAssertEqual(exclude!.name, yaml["name"].string)
        XCTAssertEqual(exclude!.owner, yaml["owner"].string)
        XCTAssertEqual(exclude!.source, yaml["source"].string)
        XCTAssertEqual(exclude!.licenseType, yaml["licenseType"].string)
    }

    func testInit_yaml_dictionary_missing_some_properties() {
        let testDict: [Yaml: Yaml] = [
            "name": "LicensePlist",
            "owner": "mono0926"
        ]
        let yaml = Yaml.dictionary(testDict)
        let exclude = Exclude(from: yaml)
        XCTAssertNotNil(exclude)
        XCTAssertEqual(exclude!.name, yaml["name"].string)
        XCTAssertEqual(exclude!.owner, yaml["owner"].string)
        XCTAssertNil(exclude!.source)
        XCTAssertNil(exclude!.licenseType)
    }

    func testInit_yaml_no_properties() {
        let testDict: [Yaml: Yaml] = [:]
        let yaml = Yaml.dictionary(testDict)
        let exclude = Exclude(from: yaml)
        XCTAssertNil(exclude)
    }

    func testInit_yaml_invalid_properties() {
        let testDict: [Yaml: Yaml] = ["invalid": "invalid"]
        let yaml = Yaml.dictionary(testDict)
        let exclude = Exclude(from: yaml)
        XCTAssertNil(exclude)
    }

    func testInit_yaml_string() {
        let testString = "LicensePlist"
        let yaml = Yaml.string(testString)
        let exclude = Exclude(from: yaml)
        XCTAssertNotNil(exclude)
        XCTAssertEqual(exclude!.name, testString)
        XCTAssertNil(exclude!.owner)
        XCTAssertNil(exclude!.source)
        XCTAssertNil(exclude!.licenseType)
    }

    func testInit_yaml_invalid_yaml_type() {
        let yaml = Yaml.bool(true)
        let exclude = Exclude(from: yaml)
        XCTAssertNil(exclude)
    }

    func testInit_yaml_invalid_license_type() {
        let testDict: [Yaml: Yaml] = [
            "licenseType": "invalid"
        ]
        let yaml = Yaml.dictionary(testDict)
        let exclude = Exclude(from: yaml)
        XCTAssertNotNil(exclude)
    }
}
