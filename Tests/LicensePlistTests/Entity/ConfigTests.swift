import Foundation
import XCTest
@testable import LicensePlistCore

class ConfigTests: XCTestCase {

    func testInit_empty_yaml() {
        XCTAssertEqual(Config(yaml: ""), Config(githubs: [], excludes: [], renames: [:]))
    }
    func testInit_sample() {
        let path = "https://raw.githubusercontent.com/mono0926/LicensePlist/master/Tests/LicensePlistTests/Resources/license_plist.yml"
        XCTAssertEqual(Config(yaml: URL(string: path)!.downloadContent().resultSync().value!),
                       Config(githubs: [GitHub(name: "LicensePlist", owner: "mono0926", version: "1.2.0"),
                                        GitHub(name: "NativePopup", owner: "mono0926", version: nil)],
                              excludes: ["RxSwift", "ios-license-generator", "/^Core.*$/"],
                              renames: ["LicensePlist": "License Plist"]))
    }

    func testExcluded() {
        let target = Config(githubs: [], excludes: ["lib1"], renames: [:])
        XCTAssertTrue(target.excluded(name: "lib1"))
        XCTAssertFalse(target.excluded(name: "lib2"))
    }

    func testExtractRegex() {
        XCTAssertEqual(Config.extractRegex("/^Core.*$/"), "^Core.*$")
        XCTAssertNil(Config.extractRegex("/^Core.*$/a"))
    }

    func testExcluded_regex() {
        let target = Config(githubs: [], excludes: ["/^lib.*$/"], renames: [:])
        XCTAssertTrue(target.excluded(name: "lib1"))
        XCTAssertTrue(target.excluded(name: "lib2"))
        XCTAssertFalse(target.excluded(name: "hello"))
    }

    func testApply_filterExcluded() {
        let config = Config(githubs: [], excludes: ["lib2"], renames: [:])
        let shouldBeIncluded = GitHub(name: "lib1", owner: "o1", version: nil)
        let result = config.filterExcluded([shouldBeIncluded, GitHub(name: "lib2", owner: "o2", version: nil)])
        XCTAssertEqual(result, [shouldBeIncluded])
    }

    func testApply_githubs() {
        let github1 = GitHub(name: "github1", owner: "g1", version: nil)
        let config = Config(githubs: [github1], excludes: ["lib2"], renames: [:])
        let shouldBeIncluded = GitHub(name: "lib1", owner: "o1", version: nil)
        let result = config.apply(githubs: [shouldBeIncluded, GitHub(name: "lib2", owner: "o2", version: nil)])
        XCTAssertEqual(result, [github1, shouldBeIncluded])
    }

    func testApply_rename() {
        var cocoapod1 = CocoaPodsLicense(library: CocoaPods(name: "lib1", version: nil), body: "body")
        let config = Config(githubs: [], excludes: [], renames: ["lib1": "lib1_renamed"])
        let result = config.rename([cocoapod1])

        cocoapod1.name = "lib1_renamed"
        XCTAssertEqual(result, [cocoapod1])
    }
}
