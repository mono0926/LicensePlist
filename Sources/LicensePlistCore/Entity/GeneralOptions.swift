import Foundation
import LoggerAPI
import Yaml

public struct GeneralOptions {
    public let outputPath: String?
    public let cartfilePath: String?
    public let mintfilePath: String?
    public let podsPath: String?
    public let packagePaths: [String]?
    public let xcworkspacePath: String?
    public let xcodeprojPath: String?
    public let prefix: String?
    public let gitHubToken: String?
    public let htmlPath: String?
    public let markdownPath: String?
    public let force: Bool?
    public let addVersionNumbers: Bool?
    public let suppressOpeningDirectory: Bool?
    public let singlePage: Bool?
    public let failIfMissingLicense: Bool?
    public let addSources: Bool?

    public static let empty = GeneralOptions(outputPath: nil,
                                             cartfilePath: nil,
                                             mintfilePath: nil,
                                             podsPath: nil,
                                             packagePaths: nil,
                                             xcworkspacePath: nil,
                                             xcodeprojPath: nil,
                                             prefix: nil,
                                             gitHubToken: nil,
                                             htmlPath: nil,
                                             markdownPath: nil,
                                             force: nil,
                                             addVersionNumbers: nil,
                                             suppressOpeningDirectory: nil,
                                             singlePage: nil,
                                             failIfMissingLicense: nil,
                                             addSources: nil)

    public init(outputPath: String?,
                cartfilePath: String?,
                mintfilePath: String?,
                podsPath: String?,
                packagePaths: [String]?,
                xcworkspacePath: String?,
                xcodeprojPath: String?,
                prefix: String?,
                gitHubToken: String?,
                htmlPath: String?,
                markdownPath: String?,
                force: Bool?,
                addVersionNumbers: Bool?,
                suppressOpeningDirectory: Bool?,
                singlePage: Bool?,
                failIfMissingLicense: Bool?,
                addSources: Bool?) {
        self.outputPath = outputPath
        self.cartfilePath = cartfilePath
        self.mintfilePath = mintfilePath
        self.podsPath = podsPath
        self.packagePaths = packagePaths
        self.xcworkspacePath = xcworkspacePath
        self.xcodeprojPath = xcodeprojPath
        self.prefix = prefix
        self.gitHubToken = gitHubToken
        self.htmlPath = htmlPath
        self.markdownPath = markdownPath
        self.force = force
        self.addVersionNumbers = addVersionNumbers
        self.suppressOpeningDirectory = suppressOpeningDirectory
        self.singlePage = singlePage
        self.failIfMissingLicense = failIfMissingLicense
        self.addSources = addSources
    }
}

extension GeneralOptions {
    public static func==(lhs: GeneralOptions, rhs: GeneralOptions) -> Bool {
        return lhs.outputPath == rhs.outputPath &&
            lhs.cartfilePath == rhs.cartfilePath &&
            lhs.mintfilePath == rhs.mintfilePath &&
            lhs.podsPath == rhs.podsPath &&
            lhs.packagePaths == rhs.packagePaths &&
            lhs.xcworkspacePath == rhs.xcworkspacePath &&
            lhs.xcodeprojPath == rhs.xcodeprojPath &&
            lhs.prefix == rhs.prefix &&
            lhs.gitHubToken == rhs.gitHubToken &&
            lhs.htmlPath == rhs.htmlPath &&
            lhs.markdownPath == rhs.markdownPath &&
            lhs.force == rhs.force &&
            lhs.addVersionNumbers == rhs.addVersionNumbers &&
            lhs.suppressOpeningDirectory == rhs.suppressOpeningDirectory &&
            lhs.singlePage == rhs.singlePage &&
            lhs.failIfMissingLicense == rhs.failIfMissingLicense &&
            lhs.addSources == rhs.addSources
    }
}

extension GeneralOptions {
    public static func load(_ raw: [Yaml: Yaml]) -> GeneralOptions {
        return GeneralOptions(outputPath: raw["outputPath"]?.string,
                              cartfilePath: raw["cartfilePath"]?.string,
                              mintfilePath: raw["mintfilePath"]?.string,
                              podsPath: raw["podsPath"]?.string,
                              packagePaths: raw["packagePaths"]?.array?.compactMap(\.string),
                              xcworkspacePath: raw["xcworkspacePath"]?.string,
                              xcodeprojPath: raw["xcodeprojPath"]?.string,
                              prefix: raw["prefix"]?.string,
                              gitHubToken: raw["gitHubToken"]?.string,
                              htmlPath: raw["htmlPath"]?.string,
                              markdownPath: raw["markdownPath"]?.string,
                              force: raw["force"]?.bool,
                              addVersionNumbers: raw["addVersionNumbers"]?.bool,
                              suppressOpeningDirectory: raw["suppressOpeningDirectory"]?.bool,
                              singlePage: raw["singlePage"]?.bool,
                              failIfMissingLicense: raw["failIfMissingLicense"]?.bool,
                              addSources: raw["addSources"]?.bool)
    }
}
