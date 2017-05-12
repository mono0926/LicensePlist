public struct GitHubLicense: License, Equatable {
    public var library: GitHub
    public let body: String
    let githubResponse: LicenseResponse

    public static func==(lhs: GitHubLicense, rhs: GitHubLicense) -> Bool {
        return lhs.library == rhs.library &&
            lhs.body == rhs.body
    }
}
