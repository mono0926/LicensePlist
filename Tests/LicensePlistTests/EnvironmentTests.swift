import Foundation
import XCTest
@testable import LicensePlistCore

class EnvironmentTests: XCTestCase {
    func testSubscript() throws {
        let env = Environment()
        
        XCTAssertEqual(env[.term], ProcessInfo.processInfo.environment["TERM"])
        XCTAssertEqual(env[.githubToken], ProcessInfo.processInfo.environment["LICENSE_PLIST_GITHUB_TOKEN"])
        XCTAssertEqual(env[.noColor], ProcessInfo.processInfo.environment["NO_COLOR"])
    }
}
