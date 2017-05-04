import Foundation
import LoggerAPI

public enum CollectorError: Error {
    case
    unexpected(Error)
}

public protocol Collector: License {
    static func collect(_ library: Self.LibraryType) -> ResultOperation<Self, CollectorError>
}
