@testable import LicensePlistCore
import XCTest

class GitHubLibraryConfigFileTests: XCTestCase {
    func testInit() {
        XCTAssertEqual(GitHubLibraryConfigFile.carthage(content: "content"), GitHubLibraryConfigFile(type: .carthage, content: "content"))
        XCTAssertEqual(GitHubLibraryConfigFile.mint(content: "content"), GitHubLibraryConfigFile(type: .mint, content: "content"))
        XCTAssertEqual(GitHubLibraryConfigFile.licensePlist(content: "content"), GitHubLibraryConfigFile(type: .licensePlist, content: "content"))
    }
}
