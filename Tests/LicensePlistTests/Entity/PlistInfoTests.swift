import Foundation
import XCTest

@testable import LicensePlistCore

class PlistInfoTests: XCTestCase {

  override class func setUp() {
    super.setUp()
    TestUtil.setGitHubToken()
  }

  private let options = Options(
    outputPath: URL(fileURLWithPath: "test_result_dir"),
    cartfilePath: URL(fileURLWithPath: "test_result_dir"),
    mintfilePath: URL(fileURLWithPath: "test_result_dir"),
    nestfilePath: URL(fileURLWithPath: "test_result_dir"),
    podsPath: URL(fileURLWithPath: "test_result_dir"),
    packagePaths: [URL(fileURLWithPath: "test_result_dir")],
    packageSourcesPath: nil,
    xcworkspacePath: URL(fileURLWithPath: "test_result_dir"),
    xcodeprojPath: URL(fileURLWithPath: "test_result_dir"),
    prefix: Consts.prefix,
    gitHubToken: nil,
    htmlPath: nil,
    markdownPath: nil,
    csvPath: nil,
    licenseFileNames: [],
    config: Config(
      githubs: [
        GitHub(
          name: "facebook-ios-sdk",
          nameSpecified: nil,
          owner: "facebook",
          version: "sdk-version-4.21.0"),
        GitHub(
          name: "exclude",
          nameSpecified: nil,
          owner: "owner",
          version: nil),
      ],
      manuals: [],
      excludes: ["exclude"],
      renames: ["Himotoki": "Himotoki2"],
      options: .empty))

  func testLoadCocoaPodsLicense() throws {
    var target = PlistInfo(options: options)
    XCTAssertNil(target.cocoaPodsLicenses)
    let path =
      "https://raw.githubusercontent.com/mono0926/LicensePlist/master/Tests/LicensePlistTests/Resources/acknowledgements.plist"
    let content = try String(contentsOf: XCTUnwrap(URL(string: path)))
    target.loadCocoaPodsLicense(acknowledgements: [content])
    let licenses = try XCTUnwrap(target.cocoaPodsLicenses)
    XCTAssertEqual(licenses.count, 11)
    let licenseFirst = try XCTUnwrap(licenses.first)
    XCTAssertEqual(
      licenseFirst.library, CocoaPods(name: "Firebase", nameSpecified: nil, version: nil))
    XCTAssertEqual(licenseFirst.body, "Copyright 2017 Google")
  }

  func testLoadCocoaPodsLicense_empty() {
    var target = PlistInfo(options: options)
    XCTAssertNil(target.cocoaPodsLicenses)
    target.loadCocoaPodsLicense(acknowledgements: [])
    XCTAssertEqual(target.cocoaPodsLicenses, [])
  }

  func testLoadGitHubLibraries() throws {
    var target = PlistInfo(options: options)
    XCTAssertNil(target.githubLibraries)
    target.loadGitHubLibraries(file: .carthage(content: "github \"ikesyo/Himotoki\" \"3.0.1\""))
    let libraries = try XCTUnwrap(target.githubLibraries)
    XCTAssertEqual(libraries.count, 2)
    let lib1 = libraries[0]
    XCTAssertEqual(
      lib1,
      GitHub(
        name: "facebook-ios-sdk", nameSpecified: nil, owner: "facebook",
        version: "sdk-version-4.21.0"))
    let lib2 = libraries[1]
    XCTAssertEqual(
      lib2, GitHub(name: "Himotoki", nameSpecified: "Himotoki2", owner: "ikesyo", version: "3.0.1"))
  }

  func testLoadGitHubLibraries_empty() throws {
    var target = PlistInfo(options: options)
    XCTAssertNil(target.githubLibraries)
    target.loadGitHubLibraries(file: .carthage(content: nil))
    let libraries = try XCTUnwrap(target.githubLibraries)
    XCTAssertEqual(libraries.count, 1)
    let lib1 = libraries[0]
    XCTAssertEqual(
      lib1,
      GitHub(
        name: "facebook-ios-sdk", nameSpecified: nil, owner: "facebook",
        version: "sdk-version-4.21.0"))
  }

  func testCompareWithLatestSummary() {
    var target = PlistInfo(options: options)
    target.cocoaPodsLicenses = []
    target.manualLicenses = []
    target.githubLibraries = []

    XCTAssertNil(target.summary)
    XCTAssertNil(target.summaryPath)
    target.compareWithLatestSummary()

    XCTAssertNotNil(target.summaryPath)
  }

  func testDownloadGitHubLicenses() throws {
    var target = PlistInfo(options: options)
    let github = GitHub(name: "LicensePlist", nameSpecified: nil, owner: "mono0926", version: nil)
    target.githubLibraries = [github]

    XCTAssertNil(target.githubLicenses)
    target.loadGitHubLicenses()
    let licenses = try XCTUnwrap(target.githubLicenses)
    XCTAssertEqual(licenses.count, 1)
    let license = licenses.first

    XCTAssertEqual(license?.library, github)
    XCTAssertNotNil(license?.body)
    XCTAssertNotNil(license?.githubResponse)
  }

  func testCollectLicenseInfos() throws {
    var target = PlistInfo(options: options)
    let github = GitHub(
      name: "LicensePlist", nameSpecified: "LicensePlist", owner: "mono0926", version: "0.0.1")
    let githubLicense = GitHubLicense(
      library: github,
      body: "body",
      githubResponse: LicenseResponse(
        content: "",
        encoding: "",
        kind: LicenseKindResponse(
          name: "name",
          spdxId: nil)))
    target.cocoaPodsLicenses = []
    let manual = Manual(
      name: "FooBar", source: "https://foo.bar", nameSpecified: "FooBar", version: "0.0.1")
    let manualLicense = ManualLicense(
      library: manual,
      body: "body")
    target.manualLicenses = [manualLicense]
    target.githubLicenses = [githubLicense]
    let expectedSummary = """
      name: LicensePlist, nameSpecified: LicensePlist, owner: mono0926, version: 0.0.1, source: https://github.com/mono0926/LicensePlist

      name: FooBar, nameSpecified: FooBar, version: 0.0.1
      body: body…

      add-version-numbers: false

      LicensePlist Version: 3.27.1
      """

    XCTAssertNil(target.licenses)
    target.collectLicenseInfos()
    let licenses = try XCTUnwrap(target.licenses)
    XCTAssertEqual(licenses.count, 2)
    let license = licenses.last
    XCTAssertEqual(license?.name, "LicensePlist")
    XCTAssertEqual(target.summary, expectedSummary)
  }

  // MEMO: No result assertions
  func testOutputPlist() {
    var target = PlistInfo(options: options)
    let github = GitHub(name: "LicensePlist", nameSpecified: nil, owner: "mono0926", version: nil)
    let githubLicense = GitHubLicense(
      library: github,
      body: "body",
      githubResponse: LicenseResponse(
        content: "",
        encoding: "",
        kind: LicenseKindResponse(
          name: "name",
          spdxId: nil)))
    target.licenses = [githubLicense]
    target.outputPlist()
  }

  func testReportMissings() {
    var target = PlistInfo(options: options)
    let github = GitHub(name: "LicensePlist", nameSpecified: nil, owner: "mono0926", version: nil)
    let githubLicense = GitHubLicense(
      library: github,
      body: "body",
      githubResponse: LicenseResponse(
        content: "",
        encoding: "",
        kind: LicenseKindResponse(
          name: "name",
          spdxId: nil)))
    target.githubLibraries = [github]
    target.licenses = [githubLicense]
    target.reportMissings()
  }

  func testFinish() {
    var target = PlistInfo(options: options)
    let github = GitHub(name: "LicensePlist", nameSpecified: nil, owner: "mono0926", version: nil)
    let githubLicense = GitHubLicense(
      library: github,
      body: "body",
      githubResponse: LicenseResponse(
        content: "",
        encoding: "",
        kind: LicenseKindResponse(
          name: "name",
          spdxId: nil)))
    target.githubLibraries = [github]
    target.githubLicenses = [githubLicense]
    let podsLicense = CocoaPodsLicense(
      library: CocoaPods(name: "", nameSpecified: nil, version: nil), body: "body")
    target.cocoaPodsLicenses = [podsLicense]
    let manualLicense = ManualLicense(
      library: Manual(name: "", source: nil, nameSpecified: nil, version: nil), body: "body")
    target.manualLicenses = [manualLicense]
    target.licenses = [githubLicense, podsLicense]
    target.summary = ""
    target.summaryPath = URL(fileURLWithPath: "")

    target.finish()
  }
}
