import Foundation
import APIKit
import LoggerAPI

public protocol LicenseInfo: HasName {
    var body: String { get }
    var version: String? { get }
    var source: String? { get }
    var bodyEscaped: String { get }
}

public protocol License: LicenseInfo {
    associatedtype LibraryType: Library
    var library: LibraryType { get }
    var body: String { get }
}

extension LicenseInfo {
    public func name(withVersion: Bool) -> String {
        let title = nameSpecified ?? name
        if let version = version, withVersion {
            return "\(title) (\(version))"
        }
        return title
    }
}

extension License {
    public var name: String { return library.name }
    public var nameSpecified: String? { return library.nameSpecified }
    public var version: String? { return library.version }
    public var source: String? { return library.source }
    public var bodyEscaped: String {
        return body
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#x27;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "<", with: "&lt;")
    }
}
