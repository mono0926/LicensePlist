import Foundation
import Yaml

class ConfigLoader {
    private init() {}
    static let shared = ConfigLoader()

    func load(yaml: String) -> Config {
        let value = try! Yaml.load(yaml)
        let githubs = value["github"].array?.map { $0.string }.flatMap { $0 } ?? []
        let gitHubList = githubs.map { GitHub.parse($0, mark: "", quotes: "") }.flatMap { $0 }
        let githubsVersion: [GitHub] = value["github"].array?.map {
            guard let dictionary = $0.dictionary else {
                return nil
            }
            guard let owner = dictionary["owner"]?.string, let name = dictionary["name"]?.string else {
                return nil
            }
            return GitHub(name: name, owner: owner, version: dictionary["version"]?.string)
            }.flatMap { $0 } ?? []
        let excludes = value["exclude"].array?.map { $0.string! } ?? []
        let renames = value["rename"].dictionary?.reduce([String: String]()) { sum, e in
            guard let from = e.key.string, let to = e.value.string else { return sum }
            var sum = sum
            sum[from] = to
            return sum
            } ?? [:]
        return Config(githubs: githubsVersion + gitHubList, excludes: excludes, renames: renames)
    }
}
