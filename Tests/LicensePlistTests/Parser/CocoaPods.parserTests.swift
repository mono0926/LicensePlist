import Foundation
import XCTest
@testable import LicensePlistCore
//
class CocoaPodsParserTests: XCTestCase {

    func testParse_empty() {
        let results = CocoaPodsLicense.parse("(　´･‿･｀)")
        XCTAssertTrue(results.isEmpty)
    }

    func testParse() {
        let content = try! String(contentsOf: URL(string: "https://raw.githubusercontent.com/mono0926/LicensePlist/master/Tests/LicensePlistTests/Resources/acknowledgements.plist")!)
        let results = CocoaPodsLicense.parse(content)
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.count, 11)
        let licenseFirst = results.first!
        XCTAssertEqual(licenseFirst.library, CocoaPods(name: "Firebase"))
        XCTAssertEqual(licenseFirst.body, "Copyright 2017 Google")
        let licenseLast = results.last!
        XCTAssertEqual(licenseLast.library, CocoaPods(name: "Protobuf"))
        XCTAssertTrue(licenseLast.body.hasPrefix("This license applies to all parts of Protocol Buffers except the following:"))
    }
}
