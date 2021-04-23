import APIKit
import Foundation
@testable import LicensePlistCore
import XCTest

class SearchRequestsTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        TestUtil.setGitHubToken()
    }

    func testRepositories() {
        let request = SearchRequests.Repositories(query: "NativePopup")
        let result = Session.shared.lp.sendSync(request)
        switch result {
        case let .success(response):
            let item = response.items.first!
            XCTAssertEqual(item.htmlUrl, URL(string: "https://github.com/mono0926/NativePopup")!)
            XCTAssertEqual(item.owner.login, "mono0926")
            XCTAssertEqual(item.name, "NativePopup")
        case let .failure(error):
            XCTFail(String(describing: error))
        }
    }
}
