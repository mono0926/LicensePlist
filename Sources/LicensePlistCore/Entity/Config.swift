import Foundation
import LoggerAPI
import Yaml

public struct Config {
    let githubs: [GitHub]
    let manuals: [Manual]
    let excludes: [Exclude]
    let renames: [String: String]
    public let options: GeneralOptions
    public var force = false
    public var addVersionNumbers = false
    public var addSources = false
    public var suppressOpeningDirectory = false
    public var singlePage = false
    public var failIfMissingLicense = false

    public static let empty = Config(githubs: [], manuals: [], excludes: [Exclude](), renames: [:], options: .empty)

    public init(yaml: String, configBasePath: URL) {
        let value = try! Yaml.load(yaml)
        let excludes = value["exclude"].array?.compactMap({ Exclude(from: $0) }) ?? []
        let renames = value["rename"].dictionary?.reduce([String: String]()) { sum, e in
            guard let from = e.key.string, let to = e.value.string else { return sum }
            var sum = sum
            sum[from] = to
            return sum
            } ?? [:]
        let manuals = value["manual"].array ?? []
        let manualList = Manual.load(manuals, renames: renames, configBasePath: configBasePath)
        let githubs = value["github"].array?.compactMap { $0.string }.compactMap { $0 } ?? []
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
        let options: GeneralOptions = value["options"].dictionary.map {
            GeneralOptions.load($0)
        } ?? .empty
        self = Config(githubs: githubsVersion + gitHubList, manuals: manualList, excludes: excludes, renames: renames, options: options)
    }

    public init(githubs: [GitHub], manuals: [Manual], excludes: [String], renames: [String: String], options: GeneralOptions) {
        self.init(githubs: githubs, manuals: manuals, excludes: excludes.map({ Exclude(name: $0) }), renames: renames, options: options)
    }

    public init(githubs: [GitHub], manuals: [Manual], excludes: [Exclude], renames: [String: String], options: GeneralOptions) {
        self.githubs = githubs
        self.manuals = manuals
        self.excludes = excludes
        self.renames = renames
        self.options = options
    }

    func excluded(github: GitHub) -> Bool {
        for exclude in excludes {
            if matches(testString: github.name, matchString: exclude.name) &&
                matches(testString: github.owner, matchString: exclude.owner) &&
                matches(testString: github.source, matchString: exclude.source) &&
                matches(testString: github.licenseType.rawValue, matchString: exclude.licenseType) {
                return true
            }
        }
        return false
    }

    func excluded(manual: Manual) -> Bool {
        for exclude in excludes {
            if matches(testString: manual.name, matchString: exclude.name) &&
                matches(testString: manual.source, matchString: exclude.source) &&
                matches(testString: manual.licenseType.rawValue, matchString: exclude.licenseType) {
                return true
            }
        }
        return false
    }

    func excluded(cocoaPodsLicense: CocoaPodsLicense) -> Bool {
        for exclude in excludes {
            if matches(testString: cocoaPodsLicense.name, matchString: exclude.name) &&
                matches(testString: cocoaPodsLicense.source, matchString: exclude.source) &&
                matches(testString: cocoaPodsLicense.licenseType.rawValue, matchString: exclude.licenseType) {
                return true
            }
        }
        return false
    }

    func excluded(name: String) -> Bool {
        for exclude in excludes where matches(testString: name, matchString: exclude.name) {
            return true
        }
        return false
    }

    private func matches(testString: String?, matchString: String?) -> Bool {
        // If it's an exact match, short-circuit
        if testString == matchString {
            return true
        }

        // If matchString is nil, then the rule isn't specified and we ignore it
        guard let matchString = matchString else {
            return true
        }

        // If testString is nil, then there is nothing to test and the rule must fail
        guard let testString = testString else {
            return false
        }

        // If it wasn't an exact match, then try regular expression.
        guard let pattern = type(of: self).extractRegex(matchString), let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return false
        }

        // If a regular expression is detected, test the string and return whether it matched the regex.
        let matches = regex.matches(in: testString, options: [], range: NSRange(location: 0, length: testString.count))
        assert(matches.count <= 1)
        return matches.count == 1
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

    func filterExcluded(githubs: [GitHub]) -> [GitHub] {
        return githubs.filter {
            let result = !excluded(github: $0)
            if !result {
                Log.warning("\(type(of: $0.self))'s \($0.name) was excluded according to config YAML.")
            }
            return result
        }
    }

    func filterExcluded(manuals: [Manual]) -> [Manual] {
        return manuals.filter {
            let result = !excluded(manual: $0)
            if !result {
                Log.warning("\(type(of: $0.self))'s \($0.name) was excluded according to config YAML.")
            }
            return result
        }
    }

    func filterExcluded(cocoaPodsLicenses: [CocoaPodsLicense]) -> [CocoaPodsLicense] {
        return cocoaPodsLicenses.filter {
            let result = !excluded(cocoaPodsLicense: $0)
            if !result {
                Log.warning("\(type(of: $0.self))'s \($0.name) was excluded according to config YAML.")
            }
            return result
        }
    }

    func apply(githubs: [GitHub]) -> [GitHub] {
        self.githubs.forEach { Log.warning("\($0.name) was loaded from config YAML.") }
        return filterExcluded(githubs: (self.githubs + githubs))
    }

    func applyManual(manuals: [Manual]) -> [Manual] {
        return filterExcluded(manuals: (self.manuals + manuals))
    }
}

extension Config: Equatable {
    public static func==(lhs: Config, rhs: Config) -> Bool {
        return lhs.githubs == rhs.githubs &&
            lhs.manuals == rhs.manuals &&
            lhs.excludes == rhs.excludes &&
            lhs.renames == rhs.renames &&
            lhs.options == rhs.options
    }
}
