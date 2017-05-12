import Foundation

public struct Options {
    public let outputPath: URL
    public let cartfilePath: URL
    public let podsPath: URL
    public let gitHubToken: String?
    public let config: Config
    public init(outputPath: URL,
        cartfilePath: URL,
        podsPath: URL,
        gitHubToken: String?,
        config: Config) {
        self.outputPath = outputPath
        self.cartfilePath = cartfilePath
        self.podsPath = podsPath
        self.gitHubToken = gitHubToken
        self.config = config
    }
}
