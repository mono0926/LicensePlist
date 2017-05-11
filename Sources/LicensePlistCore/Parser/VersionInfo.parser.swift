import Foundation

extension VersionInfo {
    public static func parse(podsManifest: String) -> VersionInfo {
        let nsPodManifest = podsManifest as NSString
        let regex = try! NSRegularExpression(pattern: "- (.*) \\(([0-9.]*)\\)", options: [])
        let dict = regex.matches(in: podsManifest, options: [], range: NSRange(location: 0, length: nsPodManifest.length))
            .reduce([String: String]()) { sum, match in
                let numberOfRanges = match.numberOfRanges
                guard numberOfRanges == 3 else {
                    assert(false, "maybe invalid regular expression to: \(nsPodManifest.substring(with: match.range))")
                    return sum
                }
                let name = nsPodManifest.substring(with: match.rangeAt(1))
                let version = nsPodManifest.substring(with: match.rangeAt(2))
                var sum = sum
                sum[name] = version
                if let prefix = name.components(separatedBy: "/").first, sum[prefix] == nil {
                    sum[prefix] = version
                }
                return sum
        }
        return VersionInfo(dictionary: dict)
    }
}
