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
