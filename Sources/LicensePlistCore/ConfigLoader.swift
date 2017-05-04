import Foundation
import Yaml

class ConfigLoader {
    private init() {}
    static let shared = ConfigLoader()

    func load(yaml: String) -> Config {
        let value = try! Yaml.load(yaml)
        let githubs = value["github"].array?.map { $0.string! } ?? []
        let gitHubList = githubs.map { GitHub.parse($0, mark: "", quotes: "") }.flatMap { $0 }
        let excludes = value["exclude"].array?.map { $0.string! } ?? []
        return Config(githubs: gitHubList, excludes: excludes)
    }
}
