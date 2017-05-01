import Foundation
import XCTest
import RxSwift
@testable import LicensePlistCore

class RxSwiftExtensionTests: XCTestCase {
    func testResult() {
        XCTAssertEqual(Observable.from(optional: 1).result(), [1])
    }
}
