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

    func testReadLicenseFromSymlinkedCheckout() throws {
        let fileManager = FileManager.default
        let temporaryDirectory = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let sourceDirectory = temporaryDirectory.appendingPathComponent("source", isDirectory: true)
        let checkoutDirectory = temporaryDirectory
            .appendingPathComponent("checkouts", isDirectory: true)
        let sourcePackageDirectory = sourceDirectory.appendingPathComponent("R.swift", isDirectory: true)
        let checkoutPackageDirectory = checkoutDirectory
            .appendingPathComponent("R.swift", isDirectory: true)

        defer {
            try? fileManager.removeItem(at: temporaryDirectory)
        }

        try fileManager.createDirectory(at: sourcePackageDirectory, withIntermediateDirectories: true)
        try "license text".write(
            to: sourcePackageDirectory.appendingPathComponent("LICENSE"),
            atomically: true,
            encoding: .utf8
        )
        try fileManager.createDirectory(at: checkoutDirectory, withIntermediateDirectories: true)
        try fileManager.createSymbolicLink(at: checkoutPackageDirectory, withDestinationURL: sourcePackageDirectory)

        var target = plistInfo(sourcePackagesPath: temporaryDirectory)
        target.loadGitHubLicenses()

        let license = try XCTUnwrap(target.githubLicenses?.first)
        XCTAssertEqual(license.body, "license text")
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
        var target = PlistInfo(
            options: options(
                licenseFileNames: ["Not-a-license"],
                sourcePackagesPath: sourcePackagesPath
            )
        )
        target.githubLibraries = [github]

        target.loadGitHubLicenses()
        let licenses = try XCTUnwrap(target.githubLicenses)

        XCTAssertTrue(licenses.isEmpty)
    }

    // MARK: Helpers

    private func plistInfo(
        licenseFileNames: [String] = ["LICENSE"],
        sourcePackagesPath: URL? = nil
    ) -> PlistInfo {
        var target = PlistInfo(
            options: options(
                licenseFileNames: licenseFileNames,
                sourcePackagesPath: sourcePackagesPath ?? self.sourcePackagesPath
            )
        )
        target.githubLibraries = [github]
        return target
    }

    private func options(licenseFileNames: [String], sourcePackagesPath: URL) -> Options {
        return Options(outputPath: URL(fileURLWithPath: "test_result_dir"),
                       cartfilePath: URL(fileURLWithPath: "test_result_dir"),
                       mintfilePath: URL(fileURLWithPath: "test_result_dir"),
                       nestfilePath: URL(fileURLWithPath: "test_result_dir"),
                       misePath: URL(fileURLWithPath: "test_result_dir"),
                       podsPath: URL(fileURLWithPath: "test_result_dir"),
                       packagePaths: [URL(fileURLWithPath: "test_result_dir")],
                       packageSourcesPath: sourcePackagesPath,
                       xcworkspacePath: URL(fileURLWithPath: "test_result_dir"),
                       xcodeprojPath: URL(fileURLWithPath: "test_result_dir"),
                       prefix: Consts.prefix,
                       gitHubToken: nil,
                       htmlPath: nil,
                       markdownPath: nil,
                       csvPath: nil,
                       licenseFileNames: licenseFileNames,
                       config: .empty)
    }
}
