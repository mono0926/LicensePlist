import Foundation
import APIKit
import LoggerAPI

public protocol Library: HasName, Hashable {
    var version: String? { get }
}

extension Library {
    public var hashValue: Int {
        return name.hash
    }
}
