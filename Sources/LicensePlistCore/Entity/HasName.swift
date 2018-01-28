import LoggerAPI

public protocol HasName {
    var name: String { get }
    var nameSpecified: String? { get }
}

extension Collection where Iterator.Element: HasName {
    func sorted() -> [Iterator.Element] {
        return sorted { $0.name.lowercased() < $1.name.lowercased() }
    }
}
