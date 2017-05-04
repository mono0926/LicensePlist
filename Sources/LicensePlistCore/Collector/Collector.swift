import Foundation
import LoggerAPI

public enum CollectorError: Error {
    case
    unexpected(Error),
    notFound(String)
}

public protocol Collector: License {
    static func collect(_ library: Self.LibraryType) -> ResultOperation<Self, CollectorError>
}
