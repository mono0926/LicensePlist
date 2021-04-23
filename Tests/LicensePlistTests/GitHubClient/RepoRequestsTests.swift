import APIKit
import Foundation
@testable import LicensePlistCore
import XCTest

class RepoRequestsTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        TestUtil.setGitHubToken()
    }

    func testLicense() {
        let request = RepoRequests.License(owner: "mono0926", repo: "NativePopup")
        let result = Session.shared.lp.sendSync(request)
        switch result {
        case let .success(response):
            XCTAssertTrue(response.contentDecoded.hasPrefix("MIT License"))
        case let .failure(error):
            XCTFail(String(describing: error))
        }
    }

    func testGet_parent() {
        let request = RepoRequests.Get(owner: "gram30", repo: "ios_sdk")
        let result = Session.shared.lp.sendSync(request)
        switch result {
        case let .success(response):
            XCTAssertEqual(
                response.parent?.htmlUrl,
                URL(string: "https://github.com/adjust/ios_sdk")!
            )
        case let .failure(error):
            XCTFail(String(describing: error))
        }
    }

    func testLicense_multiple() {
        let request1 = RepoRequests.License(owner: "mono0926", repo: "NativePopup")
        let request2 = RepoRequests.License(owner: "ReactiveX", repo: "RxSwift")
        let o1 = Session.shared.lp.send(request1)
        let o2 = Session.shared.lp.send(request2)
        let queue = OperationQueue()
        queue.addOperations([o1, o2], waitUntilFinished: true)
        let result = [try! o1.result!.get(), try! o2.result!.get()]
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result[0].contentDecoded.hasPrefix("MIT License"))
        XCTAssertTrue(result[1].contentDecoded.hasPrefix("**The MIT License**"))
    }
}
