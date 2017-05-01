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

final class RepositoryResponse {
    let owner: RepositoryOwnerResponse
    let name: String
    let htmlUrl: URL
    let parent: RepositoryResponse?

    init(owner: RepositoryOwnerResponse, name: String, htmlUrl: URL, parent: RepositoryResponse?) {
        self.owner = owner
        self.name = name
        self.htmlUrl = htmlUrl
        self.parent = parent
    }
}

extension RepositoryResponse: Decodable {
    static func decode(_ e: Extractor) throws -> RepositoryResponse {
        return try RepositoryResponse(owner: e.value("owner"),
                                      name: e.value("name"),
                                      htmlUrl: URL(string: e.value("html_url"))!,
                                      parent: e.valueOptional("parent"))
    }
}

struct RepositoryOwnerResponse {
    let login: String
}

extension RepositoryOwnerResponse: Decodable {
    static func decode(_ e: Extractor) throws -> RepositoryOwnerResponse {
        return try RepositoryOwnerResponse(login: e.value("login"))
    }
}
