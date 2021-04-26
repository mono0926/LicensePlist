import Foundation
import XCTest
import APIKit
@testable import LicensePlistCore

class ResultOperatoinTests: XCTestCase {

    func testBlocking() throws {
        let operation = ResultOperation<String, NSError> { _ in
            return Result.success("hello")
        }
        XCTAssertEqual(try operation.resultSync().get(), "hello")
    }
}
