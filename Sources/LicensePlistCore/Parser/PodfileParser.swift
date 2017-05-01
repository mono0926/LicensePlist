import Foundation

public protocol PodfileParserProtocol {
    func parse(content: String) -> [Library]
}

class PodfileParser: PodfileParserProtocol {
    func parse(content: String) -> [Library] {
        return parse(content: content, quote: "'") + parse(content: content, quote: "\"")
    }

    private func parse(content: String, quote: Character) -> [Library] {
        let regex = try! NSRegularExpression(pattern: "pod \(quote)((\\w+)|(\\w+)/(\\w+))\(quote)", options: [])
        let nsContent = content as NSString
        let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: nsContent.length))
        let libraries = matches.map { match -> Library? in
            let numberOfRanges = match.numberOfRanges
            guard numberOfRanges == 5 else {
                assert(false, "maybe invalid regular expression to: \(nsContent.substring(with: match.range))")
                return nil
            }
            let name = nsContent.substring(with: match.rangeAt(1)).components(separatedBy: "/").first
            assert(name != nil)
            return Library(source: .podfile, name: name!, owner: nil)
            }
            .flatMap { $0 }
        let librarySet = Set(libraries)
        return Array(librarySet).sorted { lhs, rhs in
            return lhs.name < rhs.name
        }
    }
}
