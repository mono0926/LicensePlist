import XCTest
@testable import LicensePlistCore

final class PlistInfoWithSourcePackagesTests: XCTestCase {
    private let github = GitHub(name: "R.swift", nameSpecified: "rswit", owner: "mac-cain13", version: "0.5.4")
    private let sourcePackagesPath = TestUtil.testResourceDir.appendingPathComponent("SourcePackages").lp.fileURL
    
    func testReadLicenseFromDisk() throws {
        var target = plistInfo()

        XCTAssertNil(target.githubLicenses)
        target.loadGitHubLicenses()
        let licenses = try XCTUnwrap(target.githubLicenses)
        XCTAssertEqual(licenses.count, 1)
        let license = licenses.first

        XCTAssertEqual(license?.library, github)
        XCTAssertEqual(license?.body, "license text")
        XCTAssertNil(license?.githubResponse)
    }
    
    func testReadLicenseMDFromDisk() throws {
        var target = plistInfo(licenseFileNames: ["LICENSE.md"])

        target.loadGitHubLicenses()
        let license = target.githubLicenses?.first

        XCTAssertEqual(license?.body, "license.md text")
    }
    
    func testReadLicenseWithAsteriskFromDisk() throws {
        var target = plistInfo(licenseFileNames: ["LICENSE.*"])

        target.loadGitHubLicenses()
        let license = target.githubLicenses?.first

        XCTAssertEqual(license?.body, "license.md text")
    }
    
    func testReadMissedLicenseFromDisk() throws {
        var target = PlistInfo(options: options(licenseFileNames: ["Not-a-license"]))
        target.githubLibraries = [github]

        target.loadGitHubLicenses()
        let licenses = try XCTUnwrap(target.githubLicenses)

        XCTAssertTrue(licenses.isEmpty)
    }
    
    // MARK: Helpers
    
    private func plistInfo(licenseFileNames: [String] = ["LICENSE"]) -> PlistInfo {
        var target = PlistInfo(options: options(licenseFileNames: licenseFileNames))
        target.githubLibraries = [github]
        return target
    }
    
    private func options(licenseFileNames: [String]) -> Options {
        return Options(outputPath: URL(fileURLWithPath: "test_result_dir"),
                       cartfilePath: URL(fileURLWithPath: "test_result_dir"),
                       mintfilePath: URL(fileURLWithPath: "test_result_dir"),
                       podsPath: URL(fileURLWithPath: "test_result_dir"),
                       packagePaths: [URL(fileURLWithPath: "test_result_dir")],
                       packageSourcesPath: sourcePackagesPath,
                       xcworkspacePath: URL(fileURLWithPath: "test_result_dir"),
                       xcodeprojPath: URL(fileURLWithPath: "test_result_dir"),
                       prefix: Consts.prefix,
                       gitHubToken: nil,
                       htmlPath: nil,
                       markdownPath: nil,
                       licenseFileNames: licenseFileNames,
                       config: .empty)
    }
}
