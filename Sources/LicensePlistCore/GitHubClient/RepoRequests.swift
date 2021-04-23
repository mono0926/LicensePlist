//
//  LicenseRequests.swift
//  LicensePlist
//
//  Created by mono on 2017/04/30.
//
//

import APIKit
import Foundation

struct RepoRequests {
    private init() {}

    struct License: GitHubRequest {
        var method: HTTPMethod { return .get }
        let path: String
        typealias Response = LicenseResponse
        init(owner: String, repo: String) {
            path = "repos/\(owner)/\(repo)/license"
        }
    }

    struct Get: GitHubRequest {
        var method = HTTPMethod.get
        let path: String
        typealias Response = RepositoryResponse
        init(owner: String, repo: String) {
            path = "repos/\(owner)/\(repo)"
        }
    }
}

struct LicenseResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case content
        case encoding
        case kind = "license"
    }

    let content: String
    let encoding: String
    let kind: LicenseKindResponse

    var contentDecoded: String {
        assert(encoding == "base64")
        return String(data: Data(base64Encoded: content, options: [.ignoreUnknownCharacters])!, encoding: .utf8)!
    }
}

struct LicenseKindResponse: Decodable {
    let name: String
    let spdxId: String?
}
