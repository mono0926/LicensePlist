//
//  SwiftPackage.swift
//  LicensePlistCore
//
//  Created by Matthias Buchetics on 20.09.19.
//

import Foundation

public struct SwiftPackage: Decodable {
    struct State: Decodable {
        let branch: String?
        let revision: String?
        let version: String
    }
    
    let package: String
    let repositoryURL: String
    let state: State
}

public struct ResolvedPackages: Decodable {
    struct Pins: Decodable {
        let pins: [SwiftPackage]
    }
    
    let object: Pins
    let version: Int
}

extension SwiftPackage {
    
    func toGitHub(renames: [String: String]) -> GitHub? {
        let urlParts = repositoryURL
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .components(separatedBy: "/")
        
        guard urlParts.count >= 3 else { return nil }
        
        let name = urlParts.last?.components(separatedBy: ".").first ?? ""
        let owner = urlParts[urlParts.count - 2]
        
        return GitHub(name: name,
                      nameSpecified: renames[name],
                      owner: owner,
                      version: state.version)
    }
}
