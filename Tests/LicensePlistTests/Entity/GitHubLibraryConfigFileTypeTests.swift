import XCTest
@testable import LicensePlistCore

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

        // nest
        do {
            let type = GitHubLibraryConfigFileType.nest
            XCTAssertEqual(type.regexString(version: false), "reference: ([\\w\\.\\-]+)/([\\w\\.\\-]+)")
            XCTAssertEqual(type.regexString(version: true), "reference: ([\\w\\.\\-]+)/([\\w\\.\\-]+)(?:[^-]*?\\n\\s*version: ([\\w\\.\\-]+))")
        }

        // licensePlist
        do {
            let type = GitHubLibraryConfigFileType.licensePlist
            XCTAssertEqual(type.regexString(version: false), "([\\w\\.\\-]+)/([\\w\\.\\-]+)")
            XCTAssertEqual(type.regexString(version: true), "([\\w\\.\\-]+)/([\\w\\.\\-]+) ([\\w\\.\\-]+)")
        }
    }
}
