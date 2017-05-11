import Foundation
import XCTest
@testable import LicensePlistCore

class LicenseTests: XCTestCase {
    func testBodyEscaped() {
        let target = CocoaPodsLicense(library: CocoaPods(name: "", version: nil), body: "body&\"'><")
        XCTAssertEqual(target.bodyEscaped, "body&amp;&quot;&#x27;&gt;&lt;")
    }
}
