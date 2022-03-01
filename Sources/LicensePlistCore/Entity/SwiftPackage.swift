//
//  SwiftPackage.swift
//  LicensePlistCore
//
//  Created by Matthias Buchetics on 20.09.19.
//

import Foundation

public struct SwiftPackage: Equatable {
    let package: String
    let repositoryURL: String
    let revision: String?
    let version: String?
}

struct SwiftPackageV1: Decodable {
    struct State: Decodable {
        let branch: String?
        let revision: String?
        let version: String?
    }

    let package: String
    let repositoryURL: String
    let state: State
}

struct ResolvedPackagesV1: Decodable {
    struct Pins: Decodable {
        let pins: [SwiftPackageV1]
    }

    let object: Pins
    let version: Int
}

struct SwiftPackageV2: Decodable {
    struct State: Decodable {
        let branch: String?
        let revision: String?
        let version: String?
    }

    let identity: String
    let location: String
    let state: State
}

struct ResolvedPackagesV2: Decodable {
    let pins: [SwiftPackageV2]
    let version: Int
}

extension SwiftPackage {
    static func loadPackages(_ content: String) -> [SwiftPackage] {
        guard let data = content.data(using: .utf8) else { return [] }
        if let resolvedPackagesV1 = try? JSONDecoder().decode(ResolvedPackagesV1.self, from: data) {
            return resolvedPackagesV1.object.pins.map {
                SwiftPackage(package: $0.package, repositoryURL: $0.repositoryURL, revision: $0.state.revision, version: $0.state.version)
            }
        } else if let resolvedPackagesV2 = try? JSONDecoder().decode(ResolvedPackagesV2.self, from: data) {
            return resolvedPackagesV2.pins.map {
                SwiftPackage(package: $0.identity, repositoryURL: $0.location, revision: $0.state.revision, version: $0.state.version)
            }
        } else {
            return []
        }
    }

    func toGitHub(renames: [String: String]) -> GitHub? {
        guard repositoryURL.contains("github.com") else { return nil }

        let urlParts = repositoryURL
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .components(separatedBy: "/")

        let name = urlParts.last?.deletingSuffix(".git") ?? ""
        let owner: String
        if urlParts.count >= 3 {
            owner = urlParts[urlParts.count - 2]
        } else {
            owner = urlParts.first?.components(separatedBy: ":").last ?? ""
        }

        return GitHub(name: name,
                      nameSpecified: renames[name] ?? package,
                      owner: owner,
                      version: version)
    }
}
