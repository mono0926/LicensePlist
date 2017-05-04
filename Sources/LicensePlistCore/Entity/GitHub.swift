import Foundation
import APIKit
import LoggerAPI

public struct GitHub: Library {
    public let name: String
    var owner: String
}

extension GitHub {
    public static func==(lhs: GitHub, rhs: GitHub) -> Bool {
        return lhs.name == rhs.name && lhs.owner == rhs.owner
    }
}
