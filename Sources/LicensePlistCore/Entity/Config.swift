import Foundation

struct Config {
    let githubs: [GitHub]
    let excludes: [String]

    func excluded(name: String) -> Bool {
        return excludes.contains(name)
    }
}

extension Config: Equatable {
    public static func==(lhs: Config, rhs: Config) -> Bool {
        return lhs.githubs == rhs.githubs && lhs.excludes == rhs.excludes
    }
}
