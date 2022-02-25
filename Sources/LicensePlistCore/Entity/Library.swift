import Foundation
import APIKit
import LoggerAPI

public protocol Library: HasName, Hashable {
    var version: String? { get }
    var source: String? { get }
}

extension Library {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
