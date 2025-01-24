//
//  SwiftPackageManagerTests.swift
//  APIKit
//
//  Created by Matthias Buchetics on 20.09.19.
//

// swiftlint:disable file_length type_body_length function_body_length
// Disabling file length warnings from SwiftLint, because any meaningful test should be included in the Test Suite
// Disabling type body length warnings from SwiftLint for the same reason as file length
// Disabling function body length warnings from SwiftLint, because Unit Tests may contain longer mock and fake definitions that should not be refactored

import Foundation
import XCTest

@testable import LicensePlistCore

class SwiftPackageManagerTests: XCTestCase {

  // MARK: - SPM v1

  func testDecodingV1() throws {
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

    let data = try XCTUnwrap(jsonString.data(using: .utf8))
    let package = try JSONDecoder().decode(SwiftPackageV1.self, from: data)

    XCTAssertEqual(package.package, "APIKit")
    XCTAssertEqual(package.repositoryURL, "https://github.com/ishkawa/APIKit.git")
    XCTAssertEqual(package.state.revision, "86d51ecee0bc0ebdb53fb69b11a24169a69097ba")
    XCTAssertEqual(package.state.version, "4.1.0")
  }

  func testDecodingOfURLWithDotsV1() throws {
    let jsonString = """
          {
            "package": "R.swift.Library",
            "repositoryURL": "https://github.com/mac-cain13/R.swift.Library",
            "state": {
              "branch": "master",
              "revision": "3365947d725398694d6ed49f2e6622f05ca3fc0f",
              "version": null
            }
          }
      """

    let data = try XCTUnwrap(jsonString.data(using: .utf8))
    let package = try JSONDecoder().decode(SwiftPackageV1.self, from: data)

    XCTAssertEqual(package.package, "R.swift.Library")
    XCTAssertEqual(package.repositoryURL, "https://github.com/mac-cain13/R.swift.Library")
    XCTAssertEqual(package.state.revision, "3365947d725398694d6ed49f2e6622f05ca3fc0f")
    XCTAssertNil(package.state.version)
  }

  func testDecodingOptionalVersionV1() throws {
    let jsonString = """
          {
            "package": "APIKit",
            "repositoryURL": "https://github.com/ishkawa/APIKit.git",
            "state": {
              "branch": "master",
              "revision": "86d51ecee0bc0ebdb53fb69b11a24169a69097ba",
              "version": null
            }
          }
      """

    let data = try XCTUnwrap(jsonString.data(using: .utf8))
    let package = try JSONDecoder().decode(SwiftPackageV1.self, from: data)

    XCTAssertEqual(package.package, "APIKit")
    XCTAssertEqual(package.repositoryURL, "https://github.com/ishkawa/APIKit.git")
    XCTAssertEqual(package.state.revision, "86d51ecee0bc0ebdb53fb69b11a24169a69097ba")
    XCTAssertEqual(package.state.branch, "master")
    XCTAssertNil(package.state.version)
  }

  func testConvertToGithub() {
    let package = SwiftPackage(
      package: "Commander",
      repositoryURL: "https://github.com/kylef/Commander.git",
      revision: "e5b50ad7b2e91eeb828393e89b03577b16be7db9",
      version: "0.8.0",
      packageDefinitionVersion: 1)
    let result = package.toGitHub(renames: [:])
    XCTAssertEqual(
      result,
      GitHub(name: "Commander", nameSpecified: "Commander", owner: "kylef", version: "0.8.0"))
  }

  func testConvertToGithubNameWithDots() {
    let package = SwiftPackage(
      package: "R.swift.Library",
      repositoryURL: "https://github.com/mac-cain13/R.swift.Library",
      revision: "3365947d725398694d6ed49f2e6622f05ca3fc0f",
      version: nil,
      packageDefinitionVersion: 1)
    let result = package.toGitHub(renames: [:])
    XCTAssertEqual(
      result,
      GitHub(
        name: "R.swift.Library", nameSpecified: "R.swift.Library", owner: "mac-cain13", version: nil
      ))
  }

  func testConvertToGithubURLWithTrailingSlash() {
    let package = SwiftPackage(
      package: "Defaults",
      repositoryURL: "https://github.com/sindresorhus/Defaults/",
      revision: "981ccb0a01c54abbe3c12ccb8226108527bbf115",
      version: "6.3.0",
      packageDefinitionVersion: 1)
    let result = package.toGitHub(renames: [:])
    XCTAssertEqual(
      result,
      GitHub(name: "Defaults", nameSpecified: "Defaults", owner: "sindresorhus", version: "6.3.0"))
  }

  func testConvertToGithubSSH() {
    let package = SwiftPackage(
      package: "LicensePlist",
      repositoryURL: "git@github.com:mono0926/LicensePlist.git",
      revision: "3365947d725398694d6ed49f2e6622f05ca3fc0e",
      version: nil,
      packageDefinitionVersion: 1)
    let result = package.toGitHub(renames: [:])
    XCTAssertEqual(
      result,
      GitHub(name: "LicensePlist", nameSpecified: "LicensePlist", owner: "mono0926", version: nil))
  }

  func testConvertToGithubPackageName() {
    let package = SwiftPackage(
      package: "IterableSDK",
      repositoryURL: "https://github.com/Iterable/swift-sdk",
      revision: "3365947d725398694d6ed49f2e6622f05ca3fc0e",
      version: nil,
      packageDefinitionVersion: 1)
    let result = package.toGitHub(renames: [:])
    XCTAssertEqual(
      result,
      GitHub(name: "swift-sdk", nameSpecified: "IterableSDK", owner: "Iterable", version: nil))
  }

  func testConvertToGithubRenames() {
    let package = SwiftPackage(
      package: "IterableSDK",
      repositoryURL: "https://github.com/Iterable/swift-sdk",
      revision: "3365947d725398694d6ed49f2e6622f05ca3fc0e",
      version: nil,
      packageDefinitionVersion: 1)
    let result = package.toGitHub(renames: ["swift-sdk": "NAME"])
    XCTAssertEqual(
      result, GitHub(name: "swift-sdk", nameSpecified: "NAME", owner: "Iterable", version: nil))
  }

  func testRename() {
    let package = SwiftPackage(
      package: "Commander",
      repositoryURL: "https://github.com/kylef/Commander.git",
      revision: "e5b50ad7b2e91eeb828393e89b03577b16be7db9",
      version: "0.8.0",
      packageDefinitionVersion: 1)
    let result = package.toGitHub(renames: ["Commander": "RenamedCommander"])
    XCTAssertEqual(
      result,
      GitHub(name: "Commander", nameSpecified: "RenamedCommander", owner: "kylef", version: "0.8.0")
    )
  }

  func testInvalidURL() {
    let package = SwiftPackage(
      package: "Google", repositoryURL: "http://www.google.com", revision: "", version: "0.0.0",
      packageDefinitionVersion: 1)
    let result = package.toGitHub(renames: [:])
    XCTAssertNil(result)
  }

  func testNonGithub() {
    let package = SwiftPackage(
      package: "Bitbucket",
      repositoryURL: "https://mbuchetics@bitbucket.org/mbuchetics/adventofcode2018.git",
      revision: "",
      version: "0.0.0",
      packageDefinitionVersion: 1)
    let result = package.toGitHub(renames: [:])
    XCTAssertNil(result)
  }

  func testParse() throws {
    let path = "https://raw.githubusercontent.com/mono0926/LicensePlist/master/Package.resolved"
    let content = try String(contentsOf: XCTUnwrap(URL(string: path)))
    let packages = SwiftPackage.loadPackages(content)

    XCTAssertFalse(packages.isEmpty)
    XCTAssertEqual(packages.count, 11)

    let packageFirst = try XCTUnwrap(packages.first)
    XCTAssertEqual(
      packageFirst,
      SwiftPackage(
        package: "apikit",
        repositoryURL: "https://github.com/ishkawa/APIKit.git",
        revision: "4e7f42d93afb787b0bc502171f9b5c12cf49d0ca",
        version: "5.3.0",
        packageDefinitionVersion: 2))
    let packageLast = try XCTUnwrap(packages.last)
    XCTAssertEqual(
      packageLast,
      SwiftPackage(
        package: "yams",
        repositoryURL: "https://github.com/jpsim/Yams.git",
        revision: "f47ba4838c30dbd59998a4e4c87ab620ff959e8a",
        version: "5.0.5",
        packageDefinitionVersion: 2))
  }

  // MARK: - SPM v2

  func testDecodingWithVersionV2() throws {
    let jsonString = """
          {
            "identity" : "APIKit",
            "kind" : "remoteSourceControl",
            "location" : "https://github.com/ishkawa/APIKit.git",
            "state" : {
              "revision" : "86d51ecee0bc0ebdb53fb69b11a24169a69097ba",
              "version" : "4.1.0"
            }
          }
      """

    let data = try XCTUnwrap(jsonString.data(using: .utf8))
    let package = try JSONDecoder().decode(SwiftPackageV2.self, from: data)

    XCTAssertEqual(package.identity, "APIKit")
    XCTAssertEqual(package.location, "https://github.com/ishkawa/APIKit.git")
    XCTAssertEqual(package.state.revision, "86d51ecee0bc0ebdb53fb69b11a24169a69097ba")
    XCTAssertNil(package.state.branch)
    XCTAssertEqual(package.state.version, "4.1.0")
  }

  func testDecodingWithBranchV2() throws {
    let jsonString = """
          {
            "identity" : "APIKit",
            "kind" : "remoteSourceControl",
            "location" : "https://github.com/ishkawa/APIKit.git",
            "state" : {
              "branch" : "master",
              "revision" : "86d51ecee0bc0ebdb53fb69b11a24169a69097ba"
            }
          }
      """

    let data = try XCTUnwrap(jsonString.data(using: .utf8))
    let package = try JSONDecoder().decode(SwiftPackageV2.self, from: data)

    XCTAssertEqual(package.identity, "APIKit")
    XCTAssertEqual(package.location, "https://github.com/ishkawa/APIKit.git")
    XCTAssertEqual(package.state.revision, "86d51ecee0bc0ebdb53fb69b11a24169a69097ba")
    XCTAssertEqual(package.state.branch, "master")
    XCTAssertNil(package.state.version)
  }

  // MARK: SPM v2 Name Parsing

  private let testPackage = SwiftPackage(
    package: "Unit Test Fake", repositoryURL: "https://github.com/unit/test", revision: nil,
    version: nil, packageDefinitionVersion: 2)

  func testNameParsingStandardV2() throws {
    let packageSwiftString = """
      // swift-tools-version:5.0
      // The swift-tools-version declares the minimum version of Swift required to build this package.

      import PackageDescription

      let package = Package(
          name: "Valet",
          platforms: [
              .iOS(.v9),
              .tvOS(.v9),
              .watchOS(.v2),
              .macOS(.v10_11),
          ],
          products: [
              .library(
                  name: "Valet",
                  targets: ["Valet"]),
          ],
          targets: [
              .target(
              name: "Valet",
              dependencies: []),
          ],
          swiftLanguageVersions: [.v5]
      )
      """

    XCTAssertEqual(testPackage.parseName(from: packageSwiftString), "Valet")
  }

  func testNameParsingWithCommentsV2() throws {
    let packageSwiftString = """
      // swift-tools-version:5.6
      //
      //  Package.swift
      //
      //  Copyright (c) 2014-2020 Alamofire Software Foundation (http://alamofire.org/)
      //
      //  Permission is hereby granted, free of charge, to any person obtaining a copy
      //  of this software and associated documentation files (the "Software"), to deal
      //  in the Software without restriction, including without limitation the rights
      //  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      //  copies of the Software, and to permit persons to whom the Software is
      //  furnished to do so, subject to the following conditions:
      //
      //  The above copyright notice and this permission notice shall be included in
      //  all copies or substantial portions of the Software.
      //
      //  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      //  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      //  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      //  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      //  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      //  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
      //  THE SOFTWARE.
      //

      import PackageDescription

      let package = Package(name: "Alamofire",
                    platforms: [.macOS(.v10_12),
                                .iOS(.v10),
                                .tvOS(.v10),
                                .watchOS(.v3)],
                    products: [.library(name: "Alamofire",
                                        targets: ["Alamofire"])],
                    targets: [.target(name: "Alamofire",
                                      path: "Source",
                                      exclude: ["Info.plist"],
                                      linkerSettings: [.linkedFramework("CFNetwork",
                                                                        .when(platforms: [.iOS,
                                                                                          .macOS,
                                                                                          .tvOS,
                                                                                          .watchOS]))]),
                              .testTarget(name: "AlamofireTests",
                                          dependencies: ["Alamofire"],
                                          path: "Tests",
                                          exclude: ["Info.plist", "Test Plans"],
                                          resources: [.process("Resources")])],
                    swiftLanguageVersions: [.v5])
      """

    XCTAssertEqual(testPackage.parseName(from: packageSwiftString), "Alamofire")
  }

  func testNameParsingNonStandardV2() throws {
    let packageSwiftString = """
      // swift-tools-version: 5.6
      // The swift-tools-version declares the minimum version of Swift required to build this package.

      import PackageDescription

      private let prettyLog = "PrettyLog"

      let package = Package(
          name: prettyLog,
          platforms: [
              .iOS(.v11),
              .macCatalyst(.v13),
              .macOS(.v10_13),
              .tvOS(.v11),
              .watchOS(.v4)
          ],
          products: [
              .library(name: prettyLog, targets: [prettyLog])
          ],
          targets: [
              .target(name: prettyLog, dependencies: [])
          ]
      )
      """

    XCTAssertEqual(
      testPackage.parseName(from: packageSwiftString), nil,
      "This should be `nil` because the name is not defined as a String. Which is still valid SPM but sadly not easily parseable. We need to fall back to other methods for getting the name."
    )
  }

  func testNameParsingWithAdditionalCodeInPackageDefinitionV2() throws {
    let packageSwiftString = """
      // swift-tools-version: 5.6
      // The swift-tools-version declares the minimum version of Swift required to build this package.

      import PackageDescription

      let someOtherPackageThatWeDontNeed = Package(
          name: "This should not be parsed",
          platforms: [
              .macOS(.v10_12),
              .iOS(.v10),
              .tvOS(.v10),
              .watchOS(.v3)],
          products: [
              .library(
                  name: ""This should not be parsed",
                  targets: [""This should not be parsed"])],
          targets: [
              .target(
                  name: ""This should not be parsed",
                  path: "Source",
                  exclude: ["Info.plist"],
                  linkerSettings: [
                      .linkedFramework("CFNetwork", .when(platforms: [.iOS, .macOS, .tvOS, .watchOS]))]),
              .testTarget(
                  name: ""This should not be parsed Tests",
                  dependencies: [""This should not be parsed"],
                  path: "Tests",
                  exclude: ["Info.plist", "Test Plans"],
                  resources: [.process("Resources")])],
          swiftLanguageVersions: [.v5])

      let everythingAbove = "should not be parsed!"

      let package = Package(
          name: "SUCCESS",
          platforms: [
              .macOS(.v10_12),
              .iOS(.v10),
              .tvOS(.v10),
              .watchOS(.v3)],
          products: [
              .library(
                  name: "SUCCESS",
                  targets: ["SUCCESS"])],
          targets: [
              .target(
                  name: "SUCCESS",
                  path: "Source",
                  exclude: ["Info.plist"],
                  linkerSettings: [
                      .linkedFramework("CFNetwork", .when(platforms: [.iOS, .macOS, .tvOS, .watchOS]))]),
              .testTarget(
                  name: "SUCCESSTests",
                  dependencies: ["SUCCESS"],
                  path: "Tests",
                  exclude: ["Info.plist", "Test Plans"],
                  resources: [.process("Resources")])],
          swiftLanguageVersions: [.v5])

      let everythingBelow = "should not be parsed!"

      let oneMoreUninterestingPackage = Package(
          name: "Not interesting to us")
      """

    XCTAssertEqual(
      testPackage.parseName(from: packageSwiftString), "SUCCESS",
      "This should be `SUCCESS` because we only need to look at the Package object stored in the constant `let package`."
    )
  }

  func testConvertToGithubPackageNameV2() {
    let package = SwiftPackage(
      package: "SPM v2 Name automattically written in lowercase",
      repositoryURL: "https://github.com/test/better-name-parsed-from-repo",
      revision: nil,
      version: nil,
      packageDefinitionVersion: 2)
    let result = package.toGitHub(renames: [:])
    XCTAssertEqual(
      result?.nameSpecified, "better-name-parsed-from-repo",
      "For SPM v2 we try to parse the Package.swift from the repository to get the name. But when that fails, we fall back to the name in the Repository URL which is still an improvement to the name we get as `identity` from the generated JSON."
    )
  }

  // MARK: Source Packages

  func testResolvingNameFromCheckoutSources() {
    let package = SwiftPackage(
      package: "R.swift",
      repositoryURL: "https://github.com/mac-cain13/R.swift",
      revision: "18ad905c6f8f0865042e1d1ee4effc7291aa899d",
      version: "0.5.4",
      packageDefinitionVersion: 2)
    let checkoutPath = TestUtil.testResourceDir.appendingPathComponent("SourcePackages/checkouts")
      .lp.fileURL
    let result = package.toGitHub(renames: [:], checkoutPath: checkoutPath)
    XCTAssertEqual(
      result,
      GitHub(name: "R.swift", nameSpecified: "rswift", owner: "mac-cain13", version: "0.5.4"))
  }
}
