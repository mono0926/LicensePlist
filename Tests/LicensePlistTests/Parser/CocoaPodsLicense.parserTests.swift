import Foundation
import XCTest
@testable import LicensePlistCore
//
class CocoaPodsLicenseParserTests: XCTestCase {

    func testParse_empty() {
        let results = CocoaPodsLicense.parse("(　´･‿･｀)")
        XCTAssertTrue(results.isEmpty)
    }

    func testParse() {
        let path = "https://raw.githubusercontent.com/mono0926/LicensePlist/master/Tests/LicensePlistTests/Resources/acknowledgements.plist"
        let content = try! String(contentsOf: URL(string: path)!)
        let results = CocoaPodsLicense.parse(content)
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.count, 11)
        let licenseFirst = results.first!
        // TODO:
        XCTAssertEqual(licenseFirst.library, CocoaPods(name: "Firebase", version: nil))
        XCTAssertEqual(licenseFirst.body, "Copyright 2017 Google")
        let licenseLast = results.last!
        // TODO:
        XCTAssertEqual(licenseLast.library, CocoaPods(name: "Protobuf", version: nil))
        XCTAssertTrue(licenseLast.body.hasPrefix("This license applies to all parts of Protocol Buffers except the following:"))
    }
}
