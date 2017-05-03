import Foundation
import RxSwift
import APIKit
import LoggerAPI

public struct CocoaPods: Library {
    public let name: String
}

extension CocoaPods {
    public static func ==(lhs: CocoaPods, rhs: CocoaPods) -> Bool {
        return lhs.name == rhs.name
    }
}
