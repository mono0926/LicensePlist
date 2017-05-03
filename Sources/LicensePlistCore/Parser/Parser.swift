public protocol Parser {
    static func parse(_ content: String) -> [Self]
}
