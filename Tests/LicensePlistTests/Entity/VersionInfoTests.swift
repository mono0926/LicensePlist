import Foundation
import XCTest
@testable import LicensePlistCore

class VersionInfoTests: XCTestCase {

    func testInit_empty() {
        let results = VersionInfo(podsManifest: "(　´･‿･｀)")
        XCTAssertTrue(results.dictionary.isEmpty)
    }

    func testInit() throws {
        let path = "https://raw.githubusercontent.com/mono0926/LicensePlist/master/Tests/LicensePlistTests/Resources/Manifest.lock"
        let content = try String(contentsOf: XCTUnwrap(URL(string: path)))
        let results = VersionInfo(podsManifest: content)
        XCTAssertFalse(results.dictionary.isEmpty)
        XCTAssertEqual(results.dictionary.count, 30)
        XCTAssertEqual(results.version(name: "FirebaseAnalytics"), "3.9.0")
        XCTAssertEqual(results.version(name: "GoogleToolboxForMac"), "2.1.1")
    }
}
