import Foundation
import APIKit
import LoggerAPI

public struct GitHub: Library {
    public var name: String
    var owner: String
    public let version: String?
}

extension GitHub {
    public static func==(lhs: GitHub, rhs: GitHub) -> Bool {
        return lhs.name == rhs.name && lhs.owner == rhs.owner
    }
}

extension GitHub: CustomStringConvertible {
    public var description: String { return "name: \(name), owner: \(owner)" }
}
