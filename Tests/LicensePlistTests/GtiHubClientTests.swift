import Foundation
import XCTest
import APIKit
@testable import LicensePlistCore

class GitHubClientTests: XCTestCase {
    func testLicense() {
        let request = RepoRequests.License(owner: "mono0926", repo: "NativePopup")
        let result = Session.shared.lp.sendSync(request)
        switch result {
        case .success(let response):
            XCTAssertEqual(
                response.downloadUrl,
                URL(string: "https://raw.githubusercontent.com/mono0926/NativePopup/master/LICENSE")!)
        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }
    func testRepositories() {
        let request = SearchRequests.Repositories(query: "NativePopup")
        let result = Session.shared.lp.sendSync(request)
        switch result {
        case .success(let response):
            XCTAssertEqual(
                response.items.first?.htmlUrl,
                URL(string: "https://github.com/mono0926/NativePopup")!)
        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }
}
