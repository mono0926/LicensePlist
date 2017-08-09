//
//  LicenseRequests.swift
//  LicensePlist
//
//  Created by mono on 2017/04/30.
//
//

import Foundation
import Himotoki
import APIKit

struct RepoRequests {
    private init() {}

    struct License: GitHubRequest {
        var method: HTTPMethod { return .get }
        let path: String
        typealias Response = LicenseResponse
        init(owner: String, repo: String) {
            self.path = "repos/\(owner)/\(repo)/license"
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

struct LicenseResponse {
    let content: String
    let contentDecoded: String
    let encoding: String
    let kind: LicenseKindResponse
}

extension LicenseResponse: Himotoki.Decodable {
    static func decode(_ e: Extractor) throws -> LicenseResponse {
        let content: String = try e.value("content")
        let encofing: String = try e.value("encoding")
        assert(encofing == "base64")
        let contentDecoded = String(data: Data(base64Encoded: content, options: [.ignoreUnknownCharacters])!, encoding: .utf8)!
        return try LicenseResponse(content: content,
                                   contentDecoded: contentDecoded,
                                   encoding: encofing,
                                   kind: e.value("license"))
    }
}

struct LicenseKindResponse {
    let name: String
    let spdxId: String?
}

extension LicenseKindResponse: Himotoki.Decodable {
    static func decode(_ e: Extractor) throws -> LicenseKindResponse {
        return try LicenseKindResponse(name: e.value("name"), spdxId: e.valueOptional("spdx_id"))
    }
}
