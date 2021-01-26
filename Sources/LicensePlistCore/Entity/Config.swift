import Foundation
import LoggerAPI
import Yaml

public struct Config {
    let githubs: [GitHub]
    let manuals: [Manual]
    let excludes: [String]
    let renames: [String: String]
    public var force = false
    public var addVersionNumbers = false
    public var suppressOpeningDirectory = false
    public var singlePage = false
    public var failIfMissingLicense = false

    public static let empty = Config(githubs: [], manuals: [], excludes: [], renames: [:])

    public init(yaml: String, configBasePath: URL) {
        let value = try! Yaml.load(yaml)
        let excludes = value["exclude"].array?.map { $0.string! } ?? []
        let renames = value["rename"].dictionary?.reduce([String: String]()) { sum, e in
            guard let from = e.key.string, let to = e.value.string else { return sum }
            var sum = sum
            sum[from] = to
            return sum
        } ?? [:]
        let manuals = value["manual"].array ?? []
        let manualList = Manual.load(manuals, renames: renames, configBasePath: configBasePath)
        let githubs = value["github"].array?.map { $0.string }.compactMap { $0 } ?? []
        let gitHubList = githubs.map { GitHub.load(.licensePlist(content: $0), renames: renames) }.flatMap { $0 }
        gitHubList.forEach {
            Log.warning("\($0.name) is specified by the depricated format. It will be removed at Version 2." +
                "See: https://github.com/mono0926/LicensePlist/blob/master/Tests/LicensePlistTests/Resources/license_plist.yml .")
        }
        let githubsVersion: [GitHub] = value["github"].array?.map {
            guard let dictionary = $0.dictionary else {
                return nil
            }
            guard let owner = dictionary["owner"]?.string, let name = dictionary["name"]?.string else {
                return nil
            }
            return GitHub(name: name,
                          nameSpecified: renames[name],
                          owner: owner,
                          version: dictionary["version"]?.string)
        }.compactMap { $0 } ?? []
        self = Config(githubs: githubsVersion + gitHubList, manuals: manualList, excludes: excludes, renames: renames)
    }

    public init(githubs: [GitHub], manuals: [Manual], excludes: [String], renames: [String: String]) {
        self.githubs = githubs
        self.manuals = manuals
        self.excludes = excludes
        self.renames = renames
    }

    func excluded(name: String) -> Bool {
        if excludes.contains(name) {
            return true
        }
        for text in excludes {
            if let pattern = type(of: self).extractRegex(text), let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let nsName = name as NSString
                let matches = regex.matches(in: name, options: [], range: NSRange(location: 0, length: nsName.length))
                assert(matches.count <= 1)
                if !matches.isEmpty {
                    return true
                }
            }
        }
        return false
    }

    static func extractRegex(_ text: String) -> String? {
        let nsText = text as NSString
        let regex = try! NSRegularExpression(pattern: "^/(.+)/$", options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length))
        if matches.count > 1 {
            Log.warning("\(text) contains multiple regex pattern(sandwitched by `/`), but those are ignored except for first one.")
        }
        guard let match = matches.first else {
            return nil
        }
        let numberOfRanges = match.numberOfRanges
        guard numberOfRanges == 2 else {
            assert(false, "maybe invalid regular expression to: \(nsText.substring(with: match.range))")
            return nil
        }
        return nsText.substring(with: match.range(at: 1))
    }

    func filterExcluded<T: HasName>(_ names: [T]) -> [T] {
        return names.filter {
            let name = $0.name
            let result = !excluded(name: name)
            if !result {
                Log.warning("\(type(of: $0.self))'s \(name) was excluded according to config YAML.")
            }
            return result
        }
    }

    func apply(githubs: [GitHub]) -> [GitHub] {
        self.githubs.forEach { Log.warning("\($0.name) was loaded from config YAML.") }
        return filterExcluded(self.githubs + githubs)
    }

    func applyManual(manuals: [Manual]) -> [Manual] {
        return filterExcluded(self.manuals + manuals)
    }
}

extension Config: Equatable {
    public static func== (lhs: Config, rhs: Config) -> Bool {
        return lhs.githubs == rhs.githubs &&
            lhs.manuals == rhs.manuals &&
            lhs.excludes == rhs.excludes &&
            lhs.renames == rhs.renames
    }
}
