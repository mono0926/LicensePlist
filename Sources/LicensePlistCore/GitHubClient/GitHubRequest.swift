import APIKit
import Foundation

protocol GitHubRequest: Request {}

extension GitHubRequest {
    var baseURL: URL { return URL(string: "https://api.github.com/")! }
    var headerFields: [String : String] {
        return ["Accept": "application/vnd.github.drax-preview+json"]
    }
}
