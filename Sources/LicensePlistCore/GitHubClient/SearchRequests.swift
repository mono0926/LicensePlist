//
//  SearchRequests.swift
//  LicensePlist
//
//  Created by mono on 2017/04/30.
//
//

import Foundation
import Himotoki
import APIKit

struct SearchRequests {
    private init() {}

    struct Repositories: GitHubRequest {
        let query: String
        var method: HTTPMethod { return .get }
        var path: String { return "search/repositories" }
        var parameters: Any? { return ["q": query] }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> RepositoriesResponse {
            return try decodeValue(object)
        }
    }
}

struct RepositoriesResponse {
    let items: [RepositoryResponse]
}

extension RepositoriesResponse: Decodable {
    static func decode(_ e: Extractor) throws -> RepositoriesResponse {
        return try RepositoriesResponse(items: e.array("items"))
    }
}

struct RepositoryResponse {
    let htmlUrl: URL
}

extension RepositoryResponse: Decodable {
    static func decode(_ e: Extractor) throws -> RepositoryResponse {
        return try RepositoryResponse(htmlUrl: URL(string: e.value("html_url"))!)
    }
}
