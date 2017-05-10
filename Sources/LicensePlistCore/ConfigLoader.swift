import Foundation
import Yaml

class ConfigLoader {
    private init() {}
    static let shared = ConfigLoader()

    func load(yaml: String) -> Config {
        let value = try! Yaml.load(yaml)
        let githubs = value["github"].array?.map { $0.string }.flatMap { $0 } ?? []
        let gitHubList = githubs.map { GitHub.parse($0, mark: "", quotes: "") }.flatMap { $0 }
        let excludes = value["exclude"].array?.map { $0.string! } ?? []
        let renames = value["rename"].dictionary?.reduce([String: String]()) { sum, e in
            guard let from = e.key.string, let to = e.value.string else { return sum }
            var sum = sum
            sum[from] = to
            return sum
            } ?? [:]
        return Config(githubs: gitHubList, excludes: excludes, renames: renames)
    }
}
