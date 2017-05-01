import Foundation
import XCTest
@testable import LicensePlistCore

class TemplateManagerTests: XCTestCase {
    private var target = TemplateManager.shared

    func testTemplates() {
        XCTAssertTrue(target.license.content.hasPrefix("<?xml version"))
        XCTAssertTrue(target.licenseList.content.hasPrefix("<?xml version"))
        XCTAssertTrue(target.licenseListItem.content.hasPrefix("<dict>"))
    }
}

class TemplateTests: XCTestCase {

    func testApplied_empty() {
        let target = Template(content: "")
        XCTAssertEqual(target.applied([:]), "")
    }
    func testApplied_none() {
        let target = Template(content: "(　´･‿･｀)")
        XCTAssertEqual(target.applied([:]), "(　´･‿･｀)")
    }
    func testApplied_template() {
        let target = Template(content: "hello {{.target}}")
        XCTAssertEqual(target.applied([:]), "hello {{.target}}")
    }
    func testApplied_template_data() {
        let target = Template(content: "hello {{.target}}")
        XCTAssertEqual(target.applied(["target": "world"]), "hello world")
    }
}
