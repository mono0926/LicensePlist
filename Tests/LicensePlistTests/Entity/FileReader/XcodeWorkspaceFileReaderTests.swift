import XCTest
@testable import LicensePlistCore

@available(OSX 10.11, *)
class XcodeWorkspaceFileReaderTests: XCTestCase {

    var workspaceFileURL: URL!
    var wildcardFileURL: URL!

    override func setUpWithError() throws {
        workspaceFileURL = URL(fileURLWithPath: "\(TestUtil.testProjectsPath)/SwiftPackageManagerTestProject/SwiftPackageManagerTestProject.xcworkspace")
        wildcardFileURL = URL(fileURLWithPath: "\(TestUtil.testProjectsPath)/SwiftPackageManagerTestProject/*")

        print("fileURL: \(String(describing: workspaceFileURL))")
        print("wildcardURL: \(String(describing: wildcardFileURL))")
    }

    override func tearDownWithError() throws {
        workspaceFileURL = nil
        wildcardFileURL = nil
    }

    func testProjectPathWhenSpecifiesCorrectFilePath() throws {
        let fileReader = XcodeWorkspaceFileReader(path: workspaceFileURL)
        XCTAssertEqual(fileReader.workspacePath, workspaceFileURL)
    }

    func testProjectPathWhenSpecifiesWildcard() throws {
        let fileReader = XcodeWorkspaceFileReader(path: wildcardFileURL)
        XCTAssertEqual(fileReader.workspacePath, workspaceFileURL)
    }

    func testReadNotNil() throws {
        let fileReader = XcodeWorkspaceFileReader(path: workspaceFileURL)
        XCTAssertNotNil(try fileReader.read())
    }
}
