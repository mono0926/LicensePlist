import Foundation

public enum PodfileKind {
    case
    source,
    lock
}

public protocol PodfileParserProtocol {
    func parse(content: String, kind: PodfileKind) -> [Library]
}

class PodfileParser: PodfileParserProtocol {

    func parse(content: String, kind: PodfileKind) -> [Library] {
        switch kind {
        case .source:
            return parse(content: content, regex: sourceRegex(quote: "'")) +
                parse(content: content, regex: sourceRegex(quote: "\""))
        case .lock:
            let regex = try! NSRegularExpression(pattern: "- (\\w+)", options: [])
            return parse(content: content, regex: regex)
        }
    }

    private func sourceRegex(quote: Character) -> NSRegularExpression {
        return try! NSRegularExpression(pattern: "pod \(quote)(\\w+)[\(quote)/]", options: [])
    }

    private func parse(content: String, regex: NSRegularExpression) -> [Library] {
        let nsContent = content as NSString
        let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: nsContent.length))
        let libraries = matches.map { match -> Library? in
            let numberOfRanges = match.numberOfRanges
            guard numberOfRanges == 2 else {
                assert(false, "maybe invalid regular expression to: \(nsContent.substring(with: match.range))")
                return nil
            }
            return Library(source: .podfile, name: nsContent.substring(with: match.rangeAt(1)), owner: nil)
            }
            .flatMap { $0 }
        let librarySet = Set(libraries)
        return Array(librarySet).sorted { lhs, rhs in
            return lhs.name < rhs.name
        }
    }
}
