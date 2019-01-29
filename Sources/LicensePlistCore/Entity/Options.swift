import Foundation

public struct Options {
    public let outputPath: URL
    public let cartfilePath: URL
    public let podsPath: URL
    public let prefix: String
    public let gitHubToken: String?
    public let htmlPath: URL?
    public let markdownPath: URL?
    public let config: Config

    public static let empty = Options(outputPath: URL(fileURLWithPath: ""),
                                      cartfilePath: URL(fileURLWithPath: ""),
                                      podsPath: URL(fileURLWithPath: ""),
                                      prefix: "",
                                      gitHubToken: nil,
                                      htmlPath: nil,
                                      markdownPath: nil,
                                      config: Config.empty)

    public init(outputPath: URL,
                cartfilePath: URL,
                podsPath: URL,
                prefix: String,
                gitHubToken: String?,
                htmlPath: URL?,
                markdownPath: URL?,
                config: Config) {
        self.outputPath = outputPath
        self.cartfilePath = cartfilePath
        self.podsPath = podsPath
        self.prefix = prefix
        self.gitHubToken = gitHubToken
        self.htmlPath = htmlPath
        self.markdownPath = markdownPath
        self.config = config
    }
}
