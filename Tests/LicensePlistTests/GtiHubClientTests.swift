import Foundation
import XCTest
import APIKit
import RxSwift
import RxBlocking
@testable import LicensePlistCore

class GitHubClientTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        TestUtil.setGitHubToken()
    }
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
    func testGet_parent() {
        let request = RepoRequests.Get(owner: "gram30", repo: "ios_sdk")
        let result = Session.shared.lp.sendSync(request)
        switch result {
        case .success(let response):
            XCTAssertEqual(
                response.parent?.htmlUrl,
                URL(string: "https://github.com/adjust/ios_sdk")!)
        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }
    func testLicense_multiple() {
        let request1 = RepoRequests.License(owner: "mono0926", repo: "NativePopup")
        let request2 = RepoRequests.License(owner: "ReactiveX", repo: "RxSwift")
        let o1 = Session.shared.rx.response(request1).asObservable()
        let o2 = Session.shared.rx.response(request2).asObservable()
        let result = try! Observable.merge([o1, o2]).toBlocking().toArray()
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].downloadUrl,
                       URL(string: "https://raw.githubusercontent.com/mono0926/NativePopup/master/LICENSE")!)
        XCTAssertEqual(result[1].downloadUrl,
                       URL(string: "https://raw.githubusercontent.com/ReactiveX/RxSwift/master/LICENSE.md")!)
    }
    func testRepositories() {
        let request = SearchRequests.Repositories(query: "NativePopup")
        let result = Session.shared.lp.sendSync(request)
        switch result {
        case .success(let response):
            let item = response.items.first!
            XCTAssertEqual(item.htmlUrl, URL(string: "https://github.com/mono0926/NativePopup")!)
            XCTAssertEqual(item.owner.login, "mono0926")
            XCTAssertEqual(item.name, "NativePopup")
        case .failure(let error):
            XCTFail(String(describing: error))
        }
    }
}
