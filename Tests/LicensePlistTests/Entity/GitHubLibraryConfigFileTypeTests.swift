@testable import LicensePlistCore
import XCTest

class GitHubLibraryConfigFileTypeTests: XCTestCase {
    func testRegexString() {
        // carthage
        do {
            let type = GitHubLibraryConfigFileType.carthage
            XCTAssertEqual(type.regexString(version: false), "github \"([\\w\\.\\-]+)/([\\w\\.\\-]+)\"")
            XCTAssertEqual(type.regexString(version: true), "github \"([\\w\\.\\-]+)/([\\w\\.\\-]+)\" \"([\\w\\.\\-]+)\"")
        }

        // mint
        do {
            let type = GitHubLibraryConfigFileType.mint
            XCTAssertEqual(type.regexString(version: false), "([\\w\\.\\-]+)/([\\w\\.\\-]+)")
            XCTAssertEqual(type.regexString(version: true), "([\\w\\.\\-]+)/([\\w\\.\\-]+)@([\\w\\.\\-]+)")
        }

        // licensePlist
        do {
            let type = GitHubLibraryConfigFileType.licensePlist
            XCTAssertEqual(type.regexString(version: false), "([\\w\\.\\-]+)/([\\w\\.\\-]+)")
            XCTAssertEqual(type.regexString(version: true), "([\\w\\.\\-]+)/([\\w\\.\\-]+) ([\\w\\.\\-]+)")
        }
    }
}
