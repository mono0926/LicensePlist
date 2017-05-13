import LoggerAPI

public protocol HasName {
    var name: String { get }
    var nameSpecified: String? { get }
}
