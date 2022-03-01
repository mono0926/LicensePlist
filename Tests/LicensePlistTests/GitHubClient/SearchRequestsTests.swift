import Foundation
import XCTest
import APIKit
@testable import LicensePlistCore

class SearchRequestsTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        TestUtil.setGitHubToken()
    }
    func testRepositories() throws {
        let request = SearchRequests.Repositories(query: "NativePopup")
        let result = Session.shared.lp.sendSync(request)
        switch result {
        case .success(let response):
            let item = try XCTUnwrap(response.items.first)
            XCTAssertEqual(item.htmlUrl, URL(string: "https://github.com/mono0926/NativePopup"))
            XCTAssertEqual(item.owner.login, "mono0926")
            XCTAssertEqual(item.name, "NativePopup")
        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }
}
