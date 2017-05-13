import Foundation
import APIKit
import LoggerAPI

public struct GitHub: Library {
    public let name: String
    public let nameSpecified: String?
    var owner: String
    public let version: String?
}

extension GitHub {
    public static func==(lhs: GitHub, rhs: GitHub) -> Bool {
        return lhs.name == rhs.name &&
            lhs.nameSpecified == rhs.nameSpecified &&
            lhs.owner == rhs.owner &&
            lhs.version == rhs.version
    }
}

extension GitHub: CustomStringConvertible {
    public var description: String {
        return "name: \(name), nameSpecified: \(nameSpecified ?? ""), owner: \(owner), version: \(version ?? "")"
    }
}

extension GitHub {
    public static func load(_ content: String, renames: [String: String] = [:]) -> [GitHub] {
        return load(content, renames: renames, mark: "github ")
    }
    public static func load(_ content: String, renames: [String: String], mark: String, quotes: String = "\"") -> [GitHub] {
        let r = load(content, renames: renames, mark: mark, quotes: quotes, version: true)
        if !r.isEmpty {
            return r
        }
        return load(content, renames: renames, mark: mark, quotes: quotes, version: false)
    }
    public static func load(_ content: String,
                            renames: [String: String],
                            mark: String,
                            quotes: String = "\"",
                            version: Bool = false) -> [GitHub] {
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
            let version = { () -> String? in
                guard version else { return nil }
                let version = nsContent.substring(with: match.rangeAt(3))
                let pattern = try! NSRegularExpression(pattern: "\\w{40}", options: [])
                if !pattern.matches(in: version, options: [], range: NSRange(location: 0, length: (version as NSString).length)).isEmpty {
                    return String(version.characters.prefix(7))
                }
                return version
            }()
            let name = nsContent.substring(with: match.rangeAt(2))
            return GitHub(name: name,
                          nameSpecified: renames[name],
                          owner: nsContent.substring(with: match.rangeAt(1)),
                          version: version)
            }
            .flatMap { $0 }
    }
}
