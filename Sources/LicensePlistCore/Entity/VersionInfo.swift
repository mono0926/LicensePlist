struct VersionInfo: Equatable {
    var dictionary: [String: String] = [:]

    func version(name: String) -> String? {
        return dictionary[name]
    }
    public static func==(lhs: VersionInfo, rhs: VersionInfo) -> Bool {

        return lhs.dictionary == rhs.dictionary
    }
}
