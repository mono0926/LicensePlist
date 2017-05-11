import Foundation
import APIKit
import LoggerAPI

public protocol LicenseInfo: HasChangeableName {
    var body: String { get }
    var version: String? { get }
    var bodyEscaped: String { get }
}

public protocol License: LicenseInfo {
    associatedtype LibraryType: Library
    var library: LibraryType { get set }
    var body: String { get }
}

extension LicenseInfo {
    public func name(withVersion: Bool) -> String {
        if let version = version, withVersion {
            return "\(name) (\(version))"
        }
        return name
    }
}

extension License {
    public var name: String {
        set { library.name = newValue }
        get { return library.name }
    }
    public var version: String? { return library.version }
    public var bodyEscaped: String {
        return body
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#x27;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "<", with: "&lt;")
    }
}

public struct GitHubLicense: License, Equatable {
    public var library: GitHub
    public let body: String
    let githubResponse: LicenseResponse

    public static func==(lhs: GitHubLicense, rhs: GitHubLicense) -> Bool {
        return lhs.library == rhs.library &&
        lhs.body == rhs.body
    }
}

public struct CocoaPodsLicense: License, Equatable {
    public var library: CocoaPods
    public let body: String

    public static func==(lhs: CocoaPodsLicense, rhs: CocoaPodsLicense) -> Bool {
        return lhs.library == rhs.library &&
            lhs.body == rhs.body
    }
}

extension CocoaPodsLicense: CustomStringConvertible {
    public var description: String { return "name: \(library.name)\nbody: \(String(body.characters.prefix(20)))…" }
}
