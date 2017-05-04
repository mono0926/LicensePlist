import Foundation

extension GitHub: Parser {
    public static func parse(_ content: String) -> [GitHub] {
        return parse(content, mark: "github ")
    }
    public static func parse(_ content: String, mark: String, quotes: String = "\"") -> [GitHub] {
        let pattern = "[\\w\\.\\-]+"
        let regex = try! NSRegularExpression(pattern: "\(mark)\(quotes)(\(pattern))/(\(pattern))\(quotes)", options: [])
        let nsContent = content as NSString
        let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: nsContent.length))
        return matches.map { match -> GitHub? in
            let numberOfRanges = match.numberOfRanges
            guard numberOfRanges == 3 else {
                assert(false, "maybe invalid regular expression to: \(nsContent.substring(with: match.range))")
                return nil
            }
            return GitHub(name: nsContent.substring(with: match.rangeAt(2)),
                          owner: nsContent.substring(with: match.rangeAt(1)))
            }
            .flatMap { $0 }
    }
}
