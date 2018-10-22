import Foundation
import LoggerAPI

public struct ManualLicense: License, Equatable {
    public let library: Manual
    public let body: String

    public static func==(lhs: ManualLicense, rhs: ManualLicense) -> Bool {
        return lhs.library == rhs.library &&
        lhs.body == rhs.body
    }
}

extension ManualLicense: CustomStringConvertible {
    public var description: String {
        return [["name: \(library.name)",
            "nameSpecified: \(library.nameSpecified ?? "")",
            "version: \(library.version ?? "")"]
        .joined(separator: ", "),
                "body: \(String(body.prefix(20)))…"]
        .joined(separator: "\n")
    }
}

extension ManualLicense {
    public static func load(_ manuals: [Manual]) -> [ManualLicense] {
        return manuals.map {
            return ManualLicense(library: $0, body: $0.body ?? "")
        }
    }
}
