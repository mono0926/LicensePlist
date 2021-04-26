import Foundation
import XCTest
@testable import LicensePlistCore

class LicensePlistHolderTests: XCTestCase {
    func testLoad_empty() throws {
        let result = LicensePlistHolder.load(licenses: [], options: Options.empty)
        let (root, items) = result.deserialized()
        let rootItems = try XCTUnwrap(root["PreferenceSpecifiers"])
        XCTAssertTrue(rootItems.isEmpty)
        XCTAssertTrue(items.isEmpty)
    }
    func testLoad_one() throws {
        let pods = CocoaPods(name: "name", nameSpecified: nil, version: nil)
        let podsLicense = CocoaPodsLicense(library: pods, body: "'<body>")
        let result = LicensePlistHolder.load(licenses: [podsLicense], options: Options.empty)
        let (root, items) = result.deserialized()
        let rootItems = try XCTUnwrap(root["PreferenceSpecifiers"])
        XCTAssertEqual(rootItems.count, 2)
        XCTAssertEqual(items.count, 1)

        let rootItems1 = rootItems[0]
        XCTAssertEqual(rootItems1["Type"], "PSGroupSpecifier")
        XCTAssertEqual(rootItems1["Title"], "Licenses")

        let rootItems2 = rootItems[1]
        XCTAssertEqual(rootItems2["Type"], "PSChildPaneSpecifier")
        XCTAssertEqual(rootItems2["Title"], "name")
        XCTAssertEqual(rootItems2["File"], "com.mono0926.LicensePlist/name")

        let item1 = try XCTUnwrap(items.first).1
        let item1_1 = try XCTUnwrap(item1["PreferenceSpecifiers"]?.first)
        XCTAssertEqual(item1_1["Type"], "PSGroupSpecifier")
        XCTAssertEqual(item1_1["FooterText"], "\'<body>")
    }
    func testLoad_allToRoot() throws {
        let pods = CocoaPods(name: "name", nameSpecified: nil, version: nil)
        let podsLicense = CocoaPodsLicense(library: pods, body: "'<body>")
        let result = LicensePlistHolder.loadAllToRoot(licenses: [podsLicense])
        let (root, items) = result.deserialized()
        let rootItems = try XCTUnwrap(root["PreferenceSpecifiers"])
        XCTAssertEqual(rootItems.count, 1)
        XCTAssertEqual(items.count, 0)

        let rootItems1 = rootItems[0]
        XCTAssertEqual(rootItems1["Type"], "PSGroupSpecifier")
        XCTAssertEqual(rootItems1["Title"], "name")
        XCTAssertEqual(rootItems1["FooterText"], "'<body>")
    }
    func testLoad_splitByHorizontalLine() throws {
        let pods = CocoaPods(name: "name", nameSpecified: nil, version: nil)
        let firstPart = "1\n2\n\n3\n---"
        let secondPart = "a"
        let thirdPart = "b"
        let separator = String(repeating: "-", count: 40)
        let podsLicense = CocoaPodsLicense(library: pods, body: "\(firstPart)\n\n\n---\n\n\(secondPart)\n\n==========\n\n\(thirdPart)")
        let result = LicensePlistHolder.load(licenses: [podsLicense], options: Options.empty)
        let (_, items) = result.deserialized()

        let item1 = items.first?.1
        let groupArray = try XCTUnwrap(item1?["PreferenceSpecifiers"])
        XCTAssertEqual(groupArray.count, 5)
        let item1_0 = groupArray[0]
        XCTAssertEqual(item1_0["Type"], "PSGroupSpecifier")
        XCTAssertEqual(item1_0["FooterText"], firstPart)
        let item1_1 = groupArray[1]
        XCTAssertEqual(item1_1["Type"], "PSGroupSpecifier")
        XCTAssertEqual(item1_1["FooterText"], separator)
        let item1_2 = groupArray[2]
        XCTAssertEqual(item1_2["Type"], "PSGroupSpecifier")
        XCTAssertEqual(item1_2["FooterText"], secondPart)
        let item1_3 = groupArray[3]
        XCTAssertEqual(item1_3["Type"], "PSGroupSpecifier")
        XCTAssertEqual(item1_3["FooterText"], separator)
        let item1_4 = groupArray[4]
        XCTAssertEqual(item1_4["Type"], "PSGroupSpecifier")
        XCTAssertEqual(item1_4["FooterText"], thirdPart)
    }
}
