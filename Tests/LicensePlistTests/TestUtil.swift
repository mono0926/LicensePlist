import Foundation
@testable import LicensePlistCore

class TestUtil {
    static func setGitHubToken() {
        GitHubAuthorizatoin.shared.token = try? String(
            contentsOf: URL(fileURLWithPath: "/Users/mono/Git/Lib/LicensePlist/Tests/LicensePlistTests/github_token.txt"),
            encoding: String.Encoding.utf8)
    }
}
