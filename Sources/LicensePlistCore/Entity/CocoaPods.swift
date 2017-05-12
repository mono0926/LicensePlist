import Foundation
import APIKit
import LoggerAPI
import Himotoki

public struct CocoaPods: Library {
    public var name: String
    public let version: String?
}

extension CocoaPods {
    public static func==(lhs: CocoaPods, rhs: CocoaPods) -> Bool {
        return lhs.name == rhs.name && lhs.version == rhs.version
    }
}
