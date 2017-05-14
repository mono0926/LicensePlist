import Foundation
import APIKit
import LoggerAPI
import Himotoki

public struct CocoaPods: Library {
    public let name: String
    public let nameSpecified: String?
    public let version: String?
}

extension CocoaPods {
    public static func==(lhs: CocoaPods, rhs: CocoaPods) -> Bool {
        return lhs.name == rhs.name &&
            lhs.nameSpecified == rhs.nameSpecified &&
            lhs.version == rhs.version
    }
}
