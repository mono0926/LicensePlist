import APIKit
import Foundation
@testable import LicensePlistCore
import XCTest

class ResultOperationTests: XCTestCase {
    func testBlocking() {
        let operation = ResultOperation<String, Error> { _ in
            Result.success("Test")
        }
        XCTAssertEqual(try! operation.resultSync().get(), "Test")
    }
}
