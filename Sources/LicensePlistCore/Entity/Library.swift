import Foundation
import APIKit
import LoggerAPI

public protocol Library: Hashable, Equatable, HasChangeableName {
}

extension Library {
    public var hashValue: Int {
        return name.hash
    }
}
