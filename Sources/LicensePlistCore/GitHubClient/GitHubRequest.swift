import APIKit
import Foundation

protocol GitHubRequest: Request {}

class GitHubAuthorization {
    private init() {}
    static let shared = GitHubAuthorization()
    var token: String?
}

extension GitHubRequest {
    var baseURL: URL { return URL(string: "https://api.github.com/")! }
    var headerFields: [String: String] {
        var header = ["Accept": "application/vnd.github.drax-preview+json"]
        if let token = GitHubAuthorization.shared.token {
            header["Authorization"] = "Token \(token)"
        }
        return header
    }
}

struct DecodableDataParser: DataParser {
    var contentType: String? {
        return "application/json"
    }

    func parse(data: Data) throws -> Any {
        return data
    }
}

extension GitHubRequest where Response: Decodable {
    var dataParser: DataParser {
        return DecodableDataParser()
    }

    func response(from object: Any, urlResponse _: HTTPURLResponse) throws -> Response {
        guard let data = object as? Data else {
            throw ResponseError.unexpectedObject(object)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(Response.self, from: data)
    }
}
