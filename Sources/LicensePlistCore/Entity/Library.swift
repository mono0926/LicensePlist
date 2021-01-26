import APIKit
import Foundation
import LoggerAPI

public protocol Library: HasName, Hashable {
    var version: String? { get }
}

public extension Library {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
