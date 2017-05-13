import Foundation
import XCTest
import APIKit
@testable import LicensePlistCore

class URLExtensionTests: XCTestCase {
    func testDownloadContent() {
        let url = URL(string: "https://raw.githubusercontent.com/mono0926/LicensePlist/master/LICENSE")!
        XCTAssertTrue(url.lp.download().resultSync().value!.hasPrefix("MIT License"))
    }
}
