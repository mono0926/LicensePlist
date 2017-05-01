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
        let owner: String
        let repo: String
        var method: HTTPMethod { return .get }
        var path: String { return "repos/\(owner)/\(repo)/license" }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> LicenseResponse {
            return try decodeValue(object)
        }
    }

    struct Get: GitHubRequest {
        let owner: String
        let repo: String

        var method: HTTPMethod { return .get }
        var path: String { return "repos/\(owner)/\(repo)" }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> RepositoryResponse {
            return try decodeValue(object)
        }
    }
}

struct LicenseResponse {
    let downloadUrl: URL
    let kind: LicenseKindResponse
}

extension LicenseResponse: Decodable {
    static func decode(_ e: Extractor) throws -> LicenseResponse {
        return try LicenseResponse(downloadUrl: URL(string: e.value("download_url"))!, kind: e.value("license"))
    }
}

struct LicenseKindResponse {
    let name: String
    let spdxId: String?
}

extension LicenseKindResponse: Decodable {
    static func decode(_ e: Extractor) throws -> LicenseKindResponse {
        return try LicenseKindResponse(name: e.value("name"), spdxId: e.valueOptional("spdx_id"))
    }
}
