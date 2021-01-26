import Foundation
@testable import LicensePlistCore
import XCTest

class LicenseTests: XCTestCase {
    func testBodyEscaped() {
        let target = CocoaPodsLicense(library: CocoaPods(name: "",
                                                         nameSpecified: nil,
                                                         version: nil),
                                      body: "body&\"'><")
        XCTAssertEqual(target.bodyEscaped, "body&amp;&quot;&#x27;&gt;&lt;")
    }

    func testName_withVersion1() {
        let target = CocoaPodsLicense(library: CocoaPods(name: "name",
                                                         nameSpecified: nil,
                                                         version: nil),
                                      body: "body&\"'><")
        XCTAssertEqual(target.name(withVersion: true), "name")
    }

    func testName_withVersion2() {
        let target = CocoaPodsLicense(library: CocoaPods(name: "name",
                                                         nameSpecified: "nameSpecified",
                                                         version: "1.2.3"),
                                      body: "body&\"'><")
        XCTAssertEqual(target.name(withVersion: true), "nameSpecified (1.2.3)")
    }

    func testName_withVersion3() {
        let target = CocoaPodsLicense(library: CocoaPods(name: "name",
                                                         nameSpecified: nil,
                                                         version: "1.2.3"),
                                      body: "body&\"'><")
        XCTAssertEqual(target.name(withVersion: false), "name")
    }

    func testName_withVersion4() {
        let target = CocoaPodsLicense(library: CocoaPods(name: "name",
                                                         nameSpecified: "nameSpecified",
                                                         version: nil),
                                      body: "body&\"'><")
        XCTAssertEqual(target.name(withVersion: false), "nameSpecified")
    }
}
