import Foundation
import XCTest
@testable import LicensePlistCore

class CocoaPodsTests: XCTestCase {

    func testParse_empty() {
        let results = CocoaPodsLicense.load("(　´･‿･｀)", versionInfo: VersionInfo(), config: Config.empty)
        XCTAssertTrue(results.isEmpty)
    }

    func testParse() throws {
        let path = "https://raw.githubusercontent.com/mono0926/LicensePlist/master/Tests/LicensePlistTests/Resources/acknowledgements.plist"
        let content = try String(contentsOf: XCTUnwrap(URL(string: path)))
        let results = CocoaPodsLicense.load(content,
                                            versionInfo: VersionInfo(dictionary: ["Firebase": "1.2.3"]),
                                            config: Config(githubs: [], manuals: [], excludes: [], renames: ["Firebase": "Firebase2"]))
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.count, 11)
        let licenseFirst = try XCTUnwrap(results.first)
        XCTAssertEqual(licenseFirst.library, CocoaPods(name: "Firebase", nameSpecified: "Firebase2", version: "1.2.3"))
        XCTAssertEqual(licenseFirst.body, "Copyright 2017 Google")
        let licenseLast = try XCTUnwrap(results.last)
        XCTAssertEqual(licenseLast.library, CocoaPods(name: "Protobuf", nameSpecified: nil, version: nil))
        XCTAssertTrue(licenseLast.body.hasPrefix("This license applies to all parts of Protocol Buffers except the following:"))
    }
}
