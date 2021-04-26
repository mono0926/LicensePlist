import Foundation
import XCTest
import APIKit
@testable import LicensePlistCore

class URLExtensionTests: XCTestCase {
    func testDownloadContent() throws {
        let url = try XCTUnwrap(URL(string: "https://raw.githubusercontent.com/mono0926/LicensePlist/master/LICENSE"))
        XCTAssertTrue(try url.lp.download().resultSync().get().hasPrefix("MIT License"))
    }
    func testFileURL() throws {
        let url = try XCTUnwrap(URL(string: "/github.com/mono0926/LicensePlist"))
        XCTAssertEqual(url.lp.fileURL.absoluteString, "file:///github.com/mono0926/LicensePlist")
    }
}
