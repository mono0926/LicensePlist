import Foundation
import APIKit
import LoggerAPI

public protocol Library: HasName, Hashable, Equatable {
    var version: String? { get }
}

extension Library {
    public var hashValue: Int {
        return name.hash
    }
}
