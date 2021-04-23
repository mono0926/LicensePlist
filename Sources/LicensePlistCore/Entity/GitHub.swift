import APIKit
import Foundation
import LoggerAPI

public struct GitHub: Library {
    public let name: String
    public let nameSpecified: String?
    var owner: String
    public let version: String?
}

public extension GitHub {
    static func== (lhs: GitHub, rhs: GitHub) -> Bool {
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
    public static func load(_ file: GitHubLibraryConfigFile, renames: [String: String] = [:]) -> [GitHub] {
        let r = load(file, renames: renames, version: true)
        if !r.isEmpty {
            return r
        }
        return load(file, renames: renames, version: false)
    }

    private static func load(_ file: GitHubLibraryConfigFile,
                             renames: [String: String],
                             version: Bool = false) -> [GitHub]
    {
        guard let content = file.content else { return [] }
        let regexString = file.type.regexString(version: version)
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
                let version = nsContent.substring(with: match.range(at: 3))
                let pattern = try! NSRegularExpression(pattern: "\\w{40}", options: [])
                if !pattern.matches(in: version, options: [], range: NSRange(location: 0, length: (version as NSString).length)).isEmpty {
                    return String(version.prefix(7))
                }
                return version
            }()
            let name = nsContent.substring(with: match.range(at: 2))
            return GitHub(name: name,
                          nameSpecified: renames[name],
                          owner: nsContent.substring(with: match.range(at: 1)),
                          version: version)
        }
        .compactMap { $0 }
    }
}
