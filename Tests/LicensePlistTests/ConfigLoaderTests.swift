import Foundation
import XCTest
@testable import LicensePlistCore

class ConfigLoaderTests: XCTestCase {
    private let target = ConfigLoader.shared
    func testLoad_empty() {
        XCTAssertEqual(target.load(yaml: ""), Config(githubs: [], excludes: []))
    }
    func testLoad_sample() {
        let path = "https://raw.githubusercontent.com/mono0926/LicensePlist/master/Tests/LicensePlistTests/Resources/license_plist.yml"
        XCTAssertEqual(target.load(yaml: URL(string: path)!.downloadContent().resultSync().value!),
                       Config(githubs: [GitHub(name: "NativePopup", owner: "mono0926")],
                              excludes: ["RxSwift", "ios-license-generator", "/^Core.*$/"]))
    }
}
