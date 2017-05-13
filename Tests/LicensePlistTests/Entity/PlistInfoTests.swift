import Foundation
import XCTest
@testable import LicensePlistCore

class PlistInfoTests: XCTestCase {
    private let options = Options(outputPath: URL(fileURLWithPath: "outputPath"),
                                  cartfilePath: URL(fileURLWithPath: "outputPath"),
                                  podsPath: URL(fileURLWithPath: "outputPath"),
                                  gitHubToken: nil,
                                  config: Config(githubs: [GitHub(name: "facebook-ios-sdk",
                                                                  nameSpecified: nil,
                                                                  owner: "facebook",
                                                                  version: "sdk-version-4.21.0"),
                                                           GitHub(name: "exclude",
                                                                  nameSpecified: nil,
                                                                  owner: "owner",
                                                                  version: nil)],
                                                 excludes: ["exclude"],
                                                 renames: ["Himotoki": "Himotoki2"]))


    func testLoadCocoaPodsLicense() {
        var target = PlistInfo(options: options)
        XCTAssertNil(target.cocoaPodsLicenses)
        let path = "https://raw.githubusercontent.com/mono0926/LicensePlist/master/Tests/LicensePlistTests/Resources/acknowledgements.plist"
        let content = try! String(contentsOf: URL(string: path)!)
        target.loadCocoaPodsLicense(acknowledgements: [content])
        let licenses = target.cocoaPodsLicenses!
        XCTAssertEqual(licenses.count, 11)
        let licenseFirst = licenses.first!
        XCTAssertEqual(licenseFirst.library, CocoaPods(name: "Firebase", nameSpecified: nil, version: nil))
        XCTAssertEqual(licenseFirst.body, "Copyright 2017 Google")
    }

    func testLoadCocoaPodsLicense_empty() {
        var target = PlistInfo(options: options)
        XCTAssertNil(target.cocoaPodsLicenses)
        target.loadCocoaPodsLicense(acknowledgements: [])
        XCTAssertEqual(target.cocoaPodsLicenses!, [])
    }

    func testLoadGitHubLibraries() {
        var target = PlistInfo(options: options)
        XCTAssertNil(target.githubLibraries)
        target.loadGitHubLibraries(cartfile: "github \"ikesyo/Himotoki\" \"3.0.1\"")
        let libraries = target.githubLibraries!
        XCTAssertEqual(libraries.count, 2)
        let lib1 = libraries[0]
        XCTAssertEqual(lib1, GitHub(name: "facebook-ios-sdk", nameSpecified: nil, owner: "facebook", version: "sdk-version-4.21.0"))
        let lib2 = libraries[1]
        XCTAssertEqual(lib2, GitHub(name: "Himotoki", nameSpecified: "Himotoki2", owner: "ikesyo", version: "3.0.1"))
    }

    func testLoadGitHubLibraries_empty() {
        var target = PlistInfo(options: options)
        XCTAssertNil(target.githubLibraries)
        target.loadGitHubLibraries(cartfile: nil)
        let libraries = target.githubLibraries!
        XCTAssertEqual(libraries.count, 1)
        let lib1 = libraries[0]
        XCTAssertEqual(lib1, GitHub(name: "facebook-ios-sdk", nameSpecified: nil, owner: "facebook", version: "sdk-version-4.21.0"))
    }
    // TODO:
}
