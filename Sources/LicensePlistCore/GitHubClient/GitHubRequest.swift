import APIKit
import Foundation

protocol GitHubRequest: Request {}

class GitHubAuthorizatoin {
    private init() {}
    static let shared = GitHubAuthorizatoin()
    var token: String? = nil
}

extension GitHubRequest {
    var baseURL: URL { return URL(string: "https://api.github.com/")! }
    var headerFields: [String : String] {
        var header = ["Accept": "application/vnd.github.drax-preview+json"]
        if let token = GitHubAuthorizatoin.shared.token {
            header["Authorization"] = "Token \(token)"
        }
        return header
    }
}
