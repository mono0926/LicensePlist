import Foundation
import RxSwift
import APIKit
import LoggerAPI

public struct Carthage: Library {
    public let name: String
    var owner: String
}

extension Carthage {
    public static func ==(lhs: Carthage, rhs: Carthage) -> Bool {
        return lhs.name == rhs.name && lhs.owner == rhs.owner
    }
}
