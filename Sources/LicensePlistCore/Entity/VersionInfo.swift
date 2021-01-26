import Foundation

public struct VersionInfo: Equatable {
    var dictionary: [String: String] = [:]

    func version(name: String) -> String? {
        return dictionary[name]
    }

    public static func== (lhs: VersionInfo, rhs: VersionInfo) -> Bool {
        return lhs.dictionary == rhs.dictionary
    }
}

extension VersionInfo {
    init(podsManifest: String) {
        let nsPodManifest = podsManifest as NSString
        let regex = try! NSRegularExpression(pattern: "- (.*) \\(([0-9.]*)\\)", options: [])
        dictionary = regex.matches(in: podsManifest, options: [], range: NSRange(location: 0, length: nsPodManifest.length))
            .reduce([String: String]()) { sum, match in
                let numberOfRanges = match.numberOfRanges
                guard numberOfRanges == 3 else {
                    assert(false, "maybe invalid regular expression to: \(nsPodManifest.substring(with: match.range))")
                    return sum
                }
                let name = nsPodManifest.substring(with: match.range(at: 1))
                let version = nsPodManifest.substring(with: match.range(at: 2))
                var sum = sum
                sum[name] = version
                if let prefix = name.components(separatedBy: "/").first, sum[prefix] == nil {
                    sum[prefix] = version
                }
                return sum
            }
    }
}
