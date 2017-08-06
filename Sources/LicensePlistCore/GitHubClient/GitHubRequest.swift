import APIKit
import Foundation
import Himotoki

protocol GitHubRequest: Request {}

class GitHubAuthorization {
    private init() {}
    static let shared = GitHubAuthorization()
    var token: String?
}

extension GitHubRequest {
    var baseURL: URL { return URL(string: "https://api.github.com/")! }
    var headerFields: [String : String] {
        var header = ["Accept": "application/vnd.github.drax-preview+json"]
        if let token = GitHubAuthorization.shared.token {
            header["Authorization"] = "Token \(token)"
        }
        return header
    }
}

extension GitHubRequest where Response: Decodable {
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return try decodeValue(object)
    }
}
