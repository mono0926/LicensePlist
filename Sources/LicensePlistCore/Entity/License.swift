import APIKit
import Foundation
import LoggerAPI

public protocol LicenseInfo: HasName {
    var body: String { get }
    var version: String? { get }
    var bodyEscaped: String { get }
}

public protocol License: LicenseInfo {
    associatedtype LibraryType: Library
    var library: LibraryType { get }
    var body: String { get }
}

public extension LicenseInfo {
    func name(withVersion: Bool) -> String {
        let title = nameSpecified ?? name
        if let version = version, withVersion {
            return "\(title) (\(version))"
        }
        return title
    }
}

public extension License {
    var name: String { return library.name }
    var nameSpecified: String? { return library.nameSpecified }
    var version: String? { return library.version }
    var bodyEscaped: String {
        return body
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#x27;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "<", with: "&lt;")
    }
}
