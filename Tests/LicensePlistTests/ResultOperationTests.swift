import Foundation
import XCTest
import APIKit
import Result
@testable import LicensePlistCore

class ResultOperatoinTests: XCTestCase {

    func testBlocking() {
        let operation = ResultOperation<String, NSError> { operation in
            return Result(value: "hello")
        }
        XCTAssertEqual(operation.blocking().result!.value!, "hello")
    }
}
