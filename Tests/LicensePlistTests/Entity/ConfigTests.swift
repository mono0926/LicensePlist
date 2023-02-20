import Foundation
import XCTest
@testable import LicensePlistCore

class ConfigTests: XCTestCase {

    func testInit_empty_yaml() {
        XCTAssertEqual(Config(yaml: "", configBasePath: URL(fileURLWithPath: "")), Config(githubs: [], manuals: [], excludes: [Exclude](), renames: [:], options: .empty))
    }
    func testInit_sample() throws {
        let url = try XCTUnwrap(URL(string: "https://raw.githubusercontent.com/mono0926/LicensePlist/master/Tests/LicensePlistTests/Resources/license_plist.yml"))
        XCTAssertEqual(Config(yaml: try url.lp.download().resultSync().get(), configBasePath: url.deletingLastPathComponent()),
                       Config(githubs: [GitHub(name: "LicensePlist", nameSpecified: "License Plist", owner: "mono0926", version: "1.2.0"),
                                        GitHub(name: "NativePopup", nameSpecified: nil, owner: "mono0926", version: nil)],
                              manuals: [Manual(name: "WebRTC",
                                               source: "https://webrtc.googlesource.com/src",
                                               nameSpecified: "Web RTC",
                                               version: "M61"),
                                        Manual(name: "Dummy License File", source: nil, nameSpecified: nil, version: nil)],
                              excludes: ["RxSwift", "ios-license-generator", "/^Core.*$/"],
                              renames: ["LicensePlist": "License Plist", "WebRTC": "Web RTC"],
                              options: GeneralOptions(outputPath: "./com.mono0926.LicensePlist.Output",
                                                      cartfilePath: "Cartfile",
                                                      mintfilePath: "Mintfile",
                                                      podsPath: "Pods",
                                                      packagePaths: ["Package.swift"],
                                                      xcworkspacePath: "*.xcworkspace",
                                                      xcodeprojPath: "*.xcodeproj",
                                                      prefix: "com.mono0926.LicensePlist",
                                                      gitHubToken: "YOUR_GITHUB_TOKEN",
                                                      htmlPath: "acknowledgements.html",
                                                      markdownPath: "acknowledgements.md",
                                                      force: false,
                                                      addVersionNumbers: false,
                                                      suppressOpeningDirectory: false,
                                                      singlePage: false,
                                                      failIfMissingLicense: false,
                                                      addSources: false)))
    }

    func testExcludedGithubByName() {
        let github1 = GitHub(name: "LicensePlist", nameSpecified: nil, owner: "", version: nil)
        let github2 = GitHub(name: "SomethingElse", nameSpecified: nil, owner: "", version: nil)
        let target = Config(githubs: [github1, github2], manuals: [], excludes: ["LicensePlist"], renames: [:], options: .empty)
        XCTAssertTrue(target.excluded(github: github1))
        XCTAssertFalse(target.excluded(github: github2))
    }

    func testExcludedGithubByName_regex() {
        let github1 = GitHub(name: "LicensePlist", nameSpecified: nil, owner: "", version: nil)
        let github2 = GitHub(name: "SomethingElse", nameSpecified: nil, owner: "", version: nil)
        let target = Config(githubs: [github1, github2], manuals: [], excludes: ["/^LicensePlist$/"], renames: [:], options: .empty)
        XCTAssertTrue(target.excluded(github: github1))
        XCTAssertFalse(target.excluded(github: github2))
    }

    func testExcludedGithubByDict() {
        let github1 = GitHub(name: "LicensePlist", nameSpecified: nil, owner: "", version: nil)
        let github2 = GitHub(name: "SomethingElse", nameSpecified: nil, owner: "", version: nil)
        let target = Config(githubs: [github1, github2], manuals: [], excludes: [Exclude(name: "LicensePlist")], renames: [:], options: .empty)
        XCTAssertTrue(target.excluded(github: github1))
        XCTAssertFalse(target.excluded(github: github2))
    }

    func testExtractRegex() {
        XCTAssertEqual(Config.extractRegex("/^Core.*$/"), "^Core.*$")
        XCTAssertNil(Config.extractRegex("/^Core.*$/a"))
    }

    func testExcluded_regex() {
        let target = Config(githubs: [], manuals: [], excludes: ["/^lib.*$/"], renames: [:], options: .empty)
        XCTAssertTrue(target.excluded(name: "lib1"))
        XCTAssertTrue(target.excluded(name: "lib2"))
        XCTAssertFalse(target.excluded(name: "hello"))
    }

    func testExcluded_dict_name_regex() {
        let github1 = GitHub(name: "lib1", nameSpecified: nil, owner: "", version: nil)
        let github2 = GitHub(name: "lib2", nameSpecified: nil, owner: "", version: nil)
        let github3 = GitHub(name: "hello", nameSpecified: nil, owner: "", version: nil)
        let target = Config(githubs: [github1, github2, github3], manuals: [], excludes: [Exclude(name: "/^lib.*$/")], renames: [:], options: .empty)
        XCTAssertTrue(target.excluded(github: github1))
        XCTAssertTrue(target.excluded(name: github1.name))
        XCTAssertTrue(target.excluded(github: github2))
        XCTAssertTrue(target.excluded(name: github2.name))
        XCTAssertFalse(target.excluded(github: github3))
        XCTAssertFalse(target.excluded(name: github3.name))
    }

    func testExcluded_dict_owner() {
        let github1 = GitHub(name: "lib1", nameSpecified: nil, owner: "mono0926", version: nil)
        let github2 = GitHub(name: "lib2", nameSpecified: nil, owner: "mono0926", version: nil)
        let github3 = GitHub(name: "hello", nameSpecified: nil, owner: "another", version: nil)
        let target = Config(githubs: [github1, github2, github3], manuals: [], excludes: [Exclude(owner: "mono0926")], renames: [:], options: .empty)
        XCTAssertTrue(target.excluded(github: github1))
        XCTAssertTrue(target.excluded(github: github2))
        XCTAssertFalse(target.excluded(github: github3))
    }

    func testExcluded_dict_owner_regex() {
        let github1 = GitHub(name: "lib1", nameSpecified: nil, owner: "mono0926", version: nil)
        let github2 = GitHub(name: "lib2", nameSpecified: nil, owner: "mono9999", version: nil)
        let github3 = GitHub(name: "hello", nameSpecified: nil, owner: "another", version: nil)
        let target = Config(githubs: [github1, github2, github3], manuals: [], excludes: [Exclude(owner: "/^mono/")], renames: [:], options: .empty)
        XCTAssertTrue(target.excluded(github: github1))
        XCTAssertTrue(target.excluded(github: github2))
        XCTAssertFalse(target.excluded(github: github3))
    }

    func testExcluded_dict_source() {
        let github1 = GitHub(name: "lib1", nameSpecified: nil, owner: "mono0926", version: nil)
        let github2 = GitHub(name: "lib2", nameSpecified: nil, owner: "mono0926", version: nil)
        let target = Config(githubs: [github1, github2], manuals: [], excludes: [Exclude(source: "https://github.com/mono0926/lib1")], renames: [:], options: .empty)
        XCTAssertTrue(target.excluded(github: github1))
        XCTAssertFalse(target.excluded(github: github2))
    }

    func testExcluded_dict_source_regex() {
        let github1 = GitHub(name: "lib1", nameSpecified: nil, owner: "mono0926", version: nil)
        let github2 = GitHub(name: "lib2", nameSpecified: nil, owner: "mono0926", version: nil)
        let github3 = GitHub(name: "hello", nameSpecified: nil, owner: "another", version: nil)
        let target = Config(githubs: [github1, github2, github3], manuals: [], excludes: [Exclude(source: "/github.com/mono0926/")], renames: [:], options: .empty)
        XCTAssertTrue(target.excluded(github: github1))
        XCTAssertTrue(target.excluded(github: github2))
        XCTAssertFalse(target.excluded(github: github3))
    }

    func testExcluded_dict_licenseType() {
        let github1 = GitHub(name: "", nameSpecified: nil, owner: "", version: nil, licenseType: .unlicense)
        let github2 = GitHub(name: "", nameSpecified: nil, owner: "", version: nil, licenseType: .mit)
        let target = Config(githubs: [github1, github2], manuals: [], excludes: [Exclude(licenseType: LicenseType.unlicense.rawValue)], renames: [:], options: .empty)
        XCTAssertTrue(target.excluded(github: github1))
        XCTAssertFalse(target.excluded(github: github2))
    }

    func testExcluded_multiple_properties() {
        let github1 = GitHub(name: "LicensePlist", nameSpecified: nil, owner: "another", version: nil)
        let github2 = GitHub(name: "LicensePlist", nameSpecified: nil, owner: "mono0926", version: nil)
        let exclude = Exclude(name: "LicensePlist", owner: "another")
        let target = Config(githubs: [github1, github2], manuals: [], excludes: [exclude], renames: [:], options: .empty)
        XCTAssertTrue(target.excluded(github: github1))
        XCTAssertFalse(target.excluded(github: github2))
    }

    func testExcluded_negate_regex() {
        let github1 = GitHub(name: "", nameSpecified: nil, owner: "mycompany", version: nil, licenseType: .apache)
        let github2 = GitHub(name: "", nameSpecified: nil, owner: "mycompany", version: nil, licenseType: .mit)
        let exclude = Exclude(owner: "mycompany", licenseType: "/^(?!.*MIT).*$/")
        let target = Config(githubs: [github1, github2], manuals: [], excludes: [exclude], renames: [:], options: .empty)
        XCTAssertTrue(target.excluded(github: github1))
        XCTAssertFalse(target.excluded(github: github2))
    }

    func testExcluded_manual() {
        let manual1 = Manual(name: "lib1", source: "https://github.com/gh1/lib1", nameSpecified: nil, version: nil, licenseType: .unlicense)
        let manual2 = Manual(name: "lib2", source: "https://github.com/gh2/lib2", nameSpecified: nil, version: nil, licenseType: .mit)
        let manual3 = Manual(name: "lib3", source: "https://github.com/gh3/lib3", nameSpecified: nil, version: nil, licenseType: .mit)
        let manual4 = Manual(name: "lib4", source: "https://github.com/gh4/lib4", nameSpecified: nil, version: nil, licenseType: .mit)
        let excludes = [Exclude(licenseType: LicenseType.unlicense.rawValue), Exclude(name: "lib2"), Exclude(source: "/github.com/gh3/")]
        let target = Config(githubs: [], manuals: [manual1, manual2], excludes: excludes, renames: [:], options: .empty)
        XCTAssertTrue(target.excluded(manual: manual1))
        XCTAssertTrue(target.excluded(manual: manual2))
        XCTAssertTrue(target.excluded(manual: manual3))
        XCTAssertFalse(target.excluded(manual: manual4))
    }

    func testApply_filterExcluded_dict() {
        let config = Config(githubs: [], manuals: [], excludes: [Exclude(name: "lib2")], renames: [:], options: .empty)
        let shouldBeIncluded = GitHub(name: "lib1", nameSpecified: nil, owner: "o1", version: nil)
        let result = config.filterExcluded(githubs: [shouldBeIncluded, GitHub(name: "lib2", nameSpecified: nil, owner: "o2", version: nil)])
        XCTAssertEqual(result, [shouldBeIncluded])
    }

    func testApply_filterExcluded_name() {
        let config = Config(githubs: [], manuals: [], excludes: ["lib2"], renames: [:], options: .empty)
        let shouldBeIncluded = GitHub(name: "lib1", nameSpecified: nil, owner: "o1", version: nil)
        let result = config.filterExcluded(githubs: [shouldBeIncluded, GitHub(name: "lib2", nameSpecified: nil, owner: "o2", version: nil)])
        XCTAssertEqual(result, [shouldBeIncluded])
    }

    func testApply_githubs() {
        let github1 = GitHub(name: "github1", nameSpecified: nil, owner: "g1", version: nil)
        let config = Config(githubs: [github1], manuals: [], excludes: ["lib2"], renames: [:], options: .empty)
        let shouldBeIncluded = GitHub(name: "lib1", nameSpecified: nil, owner: "o1", version: nil)
        let result = config.apply(githubs: [shouldBeIncluded, GitHub(name: "lib2", nameSpecified: nil, owner: "o2", version: nil)])
        XCTAssertEqual(result, [github1, shouldBeIncluded])
    }

    func testApply_manuals() {
        let manual1 = Manual(name: "manual1", source: nil, nameSpecified: nil, version: nil)
        let config = Config(githubs: [], manuals: [manual1], excludes: ["lib2"], renames: [:], options: .empty)
        let shouldBeIncluded = Manual(name: "lib1", source: nil, nameSpecified: nil, version: nil)
        let result = config.applyManual(manuals: [shouldBeIncluded, Manual(name: "lib2", source: nil, nameSpecified: nil, version: nil)])
        XCTAssertEqual(result, [manual1, shouldBeIncluded])
    }

}
