import Foundation
import XCTest
import APIKit
import Result
@testable import LicensePlistCore

class ResultOperatoinTests: XCTestCase {

    func testBlocking() {
        let operation = ResultOperation<String, NSError> { _ in
            return Result(value: "hello")
        }
        XCTAssertEqual(operation.resultSync().value!, "hello")
    }
}
