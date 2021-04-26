import Foundation
import XCTest
import APIKit
@testable import LicensePlistCore

class RepoRequestsTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        TestUtil.setGitHubToken()
    }
    func testLicense() {
        let request = RepoRequests.License(owner: "mono0926", repo: "NativePopup")
        let result = Session.shared.lp.sendSync(request)
        switch result {
        case .success(let response):
            XCTAssertTrue(response.contentDecoded.hasPrefix("MIT License"))
        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }
    func testGet_parent() {
        let request = RepoRequests.Get(owner: "gram30", repo: "ios_sdk")
        let result = Session.shared.lp.sendSync(request)
        switch result {
        case .success(let response):
            XCTAssertEqual(
                response.parent?.htmlUrl,
                URL(string: "https://github.com/adjust/ios_sdk"))
        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }
    func testLicense_multiple() throws {
        let request1 = RepoRequests.License(owner: "mono0926", repo: "NativePopup")
        let request2 = RepoRequests.License(owner: "ReactiveX", repo: "RxSwift")
        let o1 = Session.shared.lp.send(request1)
        let o2 = Session.shared.lp.send(request2)
        let queue = OperationQueue()
        queue.addOperations([o1, o2], waitUntilFinished: true)
        let result = try [XCTUnwrap(o1.result).get(), XCTUnwrap(o2.result).get()]
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result[0].contentDecoded.hasPrefix("MIT License"))
        XCTAssertTrue(result[1].contentDecoded.hasPrefix("**The MIT License**"))
    }
}
