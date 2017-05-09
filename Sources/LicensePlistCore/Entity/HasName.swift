import LoggerAPI

public protocol HasName {
    var name: String { get }
}

public protocol HasChangeableName: HasName {
    var name: String { get set }
}
