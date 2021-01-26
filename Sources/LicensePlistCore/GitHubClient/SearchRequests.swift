//
//  SearchRequests.swift
//  LicensePlist
//
//  Created by mono on 2017/04/30.
//
//

import APIKit
import Foundation

struct SearchRequests {
    private init() {}

    struct Repositories: GitHubRequest {
        let method = HTTPMethod.get
        let path = "search/repositories"
        let parameters: Any?
        typealias Response = RepositoriesResponse
        init(query: String) {
            parameters = ["q": query]
        }
    }
}

struct RepositoriesResponse: Decodable {
    let items: [RepositoryResponse]
}

final class RepositoryResponse: Decodable {
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

struct RepositoryOwnerResponse: Decodable {
    let login: String
}
