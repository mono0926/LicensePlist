//
//  SwiftPackageManagerTests.swift
//  APIKit
//
//  Created by Matthias Buchetics on 20.09.19.
//

import Foundation
import XCTest
@testable import LicensePlistCore

class SwiftPackageManagerTests: XCTestCase {
    
    func testDecoding() {
        let jsonString = """
            {
              "package": "APIKit",
              "repositoryURL": "https://github.com/ishkawa/APIKit.git",
              "state": {
                "branch": null,
                "revision": "86d51ecee0bc0ebdb53fb69b11a24169a69097ba",
                "version": "4.1.0"
              }
            }
        """
        
        let data = jsonString.data(using: .utf8)!
        let package = try! JSONDecoder().decode(SwiftPackage.self, from: data)
        
        XCTAssertEqual(package.package, "APIKit")
        XCTAssertEqual(package.repositoryURL, "https://github.com/ishkawa/APIKit.git")
        XCTAssertEqual(package.state.revision, "86d51ecee0bc0ebdb53fb69b11a24169a69097ba")
        XCTAssertEqual(package.state.version, "4.1.0")
    }
    
    func testConvertToGithub() {
        let package = SwiftPackage(package: "Commander", repositoryURL: "https://github.com/kylef/Commander.git", state: SwiftPackage.State(branch: nil, revision: "e5b50ad7b2e91eeb828393e89b03577b16be7db9", version: "0.8.0"))
        let result = package.toGitHub(renames: [:])
        XCTAssertEqual(result, GitHub(name: "Commander", nameSpecified: nil, owner: "kylef", version: "0.8.0"))
    }
    
    func testRename() {
        let package = SwiftPackage(package: "Commander", repositoryURL: "https://github.com/kylef/Commander.git", state: SwiftPackage.State(branch: nil, revision: "e5b50ad7b2e91eeb828393e89b03577b16be7db9", version: "0.8.0"))
        let result = package.toGitHub(renames: ["Commander": "RenamedCommander"])
        XCTAssertEqual(result, GitHub(name: "Commander", nameSpecified: "RenamedCommander", owner: "kylef", version: "0.8.0"))
    }
    
    func testInvalidURL() {
        let package = SwiftPackage(package: "Google", repositoryURL: "http://www.google.com", state: SwiftPackage.State(branch: nil, revision: "", version: "0.0.0"))
        let result = package.toGitHub(renames: [:])
        XCTAssertNil(result)
    }
}
