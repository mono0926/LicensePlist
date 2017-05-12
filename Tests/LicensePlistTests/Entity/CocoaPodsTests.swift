import Foundation
import XCTest
@testable import LicensePlistCore

class CocoaPodsTests: XCTestCase {

    func testParse_empty() {
        let results = CocoaPodsLicense.load("(　´･‿･｀)", versionInfo: VersionInfo())
        XCTAssertTrue(results.isEmpty)
    }

    func testParse() {
        let path = "https://raw.githubusercontent.com/mono0926/LicensePlist/master/Tests/LicensePlistTests/Resources/acknowledgements.plist"
        let content = try! String(contentsOf: URL(string: path)!)
        let results = CocoaPodsLicense.load(content, versionInfo: VersionInfo(dictionary: ["Firebase": "1.2.3"]))
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.count, 11)
        let licenseFirst = results.first!
        XCTAssertEqual(licenseFirst.library, CocoaPods(name: "Firebase", version: "1.2.3"))
        XCTAssertEqual(licenseFirst.body, "Copyright 2017 Google")
        let licenseLast = results.last!
        XCTAssertEqual(licenseLast.library, CocoaPods(name: "Protobuf", version: nil))
        XCTAssertTrue(licenseLast.body.hasPrefix("This license applies to all parts of Protocol Buffers except the following:"))
    }
}
