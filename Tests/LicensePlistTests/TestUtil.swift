import Foundation
import LoggerAPI
@testable import LicensePlistCore

class TestUtil {

    static func setGitHubToken() {
        if let token = ProcessInfo.processInfo.environment["GITHUB_TOKEN"], !token.isEmpty {
            GitHubAuthorization.shared.token = token
            return
        }
        // Specify your `github_token.txt` location
        let url = testResourceDir.appendingPathComponent("github_token.txt")
        do {
            GitHubAuthorization.shared.token = try String(contentsOf: url,
                                                           encoding: String.Encoding.utf8)
        } catch {
            Log.warning("\(url) not found. You can execute without github_token, but API limit will exceed sometimes.")
        }
    }

    static var sourceDir: URL {
        return URL(string: #filePath)!
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    static var testResourceDir: URL {
        return sourceDir
            .appendingPathComponent("Tests")
            .appendingPathComponent("LicensePlistTests")
            .appendingPathComponent("Resources")
    }

    static var testProjectsPath: URL {
        return sourceDir
            .appendingPathComponent("Tests")
            .appendingPathComponent("LicensePlistTests")
            .appendingPathComponent("XcodeProjects")
    }

}
