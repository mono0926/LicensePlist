import Foundation

extension GitHub: Parser {
    public static func parse(_ content: String) -> [GitHub] {
        return parse(content, mark: "github ")
    }
    public static func parse(_ content: String, mark: String, quotes: String = "\"") -> [GitHub] {
        let r = parse(content, mark: mark, quotes: quotes, version: true)
        if !r.isEmpty {
            return r
        }
        return parse(content, mark: mark, quotes: quotes, version: false)
    }
    public static func parse(_ content: String, mark: String, quotes: String = "\"", version: Bool = false) -> [GitHub] {
        let pattern = "[\\w\\.\\-]+"
        let regexString = "\(mark)\(quotes)(\(pattern))/(\(pattern))\(quotes)" + (version ? " \(quotes)([\\w\\.\\-]+)\(quotes)" : "")
        let regex = try! NSRegularExpression(pattern: regexString, options: [])
        let nsContent = content as NSString
        let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: nsContent.length))
        return matches.map { match -> GitHub? in
            let numberOfRanges = match.numberOfRanges
            guard numberOfRanges == (version ? 4 : 3) else {
                assert(false, "maybe invalid regular expression to: \(nsContent.substring(with: match.range))")
                return nil
            }
            return GitHub(name: nsContent.substring(with: match.rangeAt(2)),
                          owner: nsContent.substring(with: match.rangeAt(1))
                , version: version ? nsContent.substring(with: match.rangeAt(3)) : nil)
            }
            .flatMap { $0 }
    }
}
