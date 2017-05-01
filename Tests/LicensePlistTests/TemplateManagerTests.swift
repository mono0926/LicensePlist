import Foundation
import XCTest
@testable import LicensePlistCore

class TemplateManagerTests: XCTestCase {
    private var target = TemplateManager.shared

    func testTemplates() {
        XCTAssertTrue(target.license.hasPrefix("<?xml version"))
        XCTAssertTrue(target.licenseList.hasPrefix("<?xml version"))
        XCTAssertTrue(target.licenseListItem.hasPrefix("<dict>"))
    }
}
