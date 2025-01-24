import Foundation
import LoggerAPI
import Yams

public struct GeneralOptions: Sendable {
  public let outputPath: URL?
  public let cartfilePath: URL?
  public let mintfilePath: URL?
  public let podsPath: URL?
  public let packagePaths: [URL]?
  public let packageSourcesPath: URL?
  public let xcworkspacePath: URL?
  public let xcodeprojPath: URL?
  public let prefix: String?
  public let gitHubToken: String?
  public let htmlPath: URL?
  public let markdownPath: URL?
  public let csvPath: URL?
  public let licenseFileNames: [String]?
  public let force: Bool?
  public let addVersionNumbers: Bool?
  public let suppressOpeningDirectory: Bool?
  public let singlePage: Bool?
  public let failIfMissingLicense: Bool?
  public let addSources: Bool?
  public let sandboxMode: Bool?

  public static let empty = GeneralOptions(
    outputPath: nil,
    cartfilePath: nil,
    mintfilePath: nil,
    podsPath: nil,
    packagePaths: nil,
    packageSourcesPath: nil,
    xcworkspacePath: nil,
    xcodeprojPath: nil,
    prefix: nil,
    gitHubToken: nil,
    htmlPath: nil,
    markdownPath: nil,
    csvPath: nil,
    licenseFileNames: nil,
    force: nil,
    addVersionNumbers: nil,
    suppressOpeningDirectory: nil,
    singlePage: nil,
    failIfMissingLicense: nil,
    addSources: nil,
    sandboxMode: nil)

  public init(
    outputPath: URL?,
    cartfilePath: URL?,
    mintfilePath: URL?,
    podsPath: URL?,
    packagePaths: [URL]?,
    packageSourcesPath: URL?,
    xcworkspacePath: URL?,
    xcodeprojPath: URL?,
    prefix: String?,
    gitHubToken: String?,
    htmlPath: URL?,
    markdownPath: URL?,
    csvPath: URL?,
    licenseFileNames: [String]?,
    force: Bool?,
    addVersionNumbers: Bool?,
    suppressOpeningDirectory: Bool?,
    singlePage: Bool?,
    failIfMissingLicense: Bool?,
    addSources: Bool?,
    sandboxMode: Bool?
  ) {
    self.outputPath = outputPath
    self.cartfilePath = cartfilePath
    self.mintfilePath = mintfilePath
    self.podsPath = podsPath
    self.packagePaths = packagePaths
    self.packageSourcesPath = packageSourcesPath
    self.xcworkspacePath = xcworkspacePath
    self.xcodeprojPath = xcodeprojPath
    self.prefix = prefix
    self.gitHubToken = gitHubToken
    self.htmlPath = htmlPath
    self.markdownPath = markdownPath
    self.csvPath = csvPath
    self.licenseFileNames = licenseFileNames
    self.force = force
    self.addVersionNumbers = addVersionNumbers
    self.suppressOpeningDirectory = suppressOpeningDirectory
    self.singlePage = singlePage
    self.failIfMissingLicense = failIfMissingLicense
    self.addSources = addSources
    self.sandboxMode = sandboxMode
  }
}

extension GeneralOptions {
  public static func == (lhs: GeneralOptions, rhs: GeneralOptions) -> Bool {
    return lhs.outputPath == rhs.outputPath && lhs.cartfilePath == rhs.cartfilePath
      && lhs.mintfilePath == rhs.mintfilePath && lhs.podsPath == rhs.podsPath
      && lhs.packagePaths == rhs.packagePaths && lhs.packageSourcesPath == rhs.packageSourcesPath
      && lhs.xcworkspacePath == rhs.xcworkspacePath && lhs.xcodeprojPath == rhs.xcodeprojPath
      && lhs.prefix == rhs.prefix && lhs.gitHubToken == rhs.gitHubToken
      && lhs.htmlPath == rhs.htmlPath && lhs.markdownPath == rhs.markdownPath
      && lhs.csvPath == rhs.csvPath && lhs.licenseFileNames == rhs.licenseFileNames
      && lhs.force == rhs.force && lhs.addVersionNumbers == rhs.addVersionNumbers
      && lhs.suppressOpeningDirectory == rhs.suppressOpeningDirectory
      && lhs.singlePage == rhs.singlePage && lhs.failIfMissingLicense == rhs.failIfMissingLicense
      && lhs.addSources == rhs.addSources && lhs.sandboxMode == rhs.sandboxMode
  }
}

extension GeneralOptions {
  public static func load(_ raw: Node.Mapping, configBasePath: URL) -> GeneralOptions {
    return GeneralOptions(
      outputPath: raw["outputPath"]?.string.asPathURL(in: configBasePath),
      cartfilePath: raw["cartfilePath"]?.string.asPathURL(in: configBasePath),
      mintfilePath: raw["mintfilePath"]?.string.asPathURL(in: configBasePath),
      podsPath: raw["podsPath"]?.string.asPathURL(in: configBasePath),
      packagePaths: raw["packagePaths"]?.sequence?.compactMap {
        $0.string.asPathURL(in: configBasePath)
      },
      packageSourcesPath: raw["packageSourcesPath"]?.string.asPathURL(
        in: configBasePath, isDirectory: true),
      xcworkspacePath: raw["xcworkspacePath"]?.string.asPathURL(in: configBasePath),
      xcodeprojPath: raw["xcodeprojPath"]?.string.asPathURL(in: configBasePath),
      prefix: raw["prefix"]?.string,
      gitHubToken: raw["gitHubToken"]?.string,
      htmlPath: raw["htmlPath"]?.string.asPathURL(in: configBasePath),
      markdownPath: raw["markdownPath"]?.string.asPathURL(in: configBasePath),
      csvPath: raw["csvPath"]?.string.asPathURL(in: configBasePath),
      licenseFileNames: raw["licenseFileNames"]?.sequence?.compactMap { $0.string },
      force: raw["force"]?.bool,
      addVersionNumbers: raw["addVersionNumbers"]?.bool,
      suppressOpeningDirectory: raw["suppressOpeningDirectory"]?.bool,
      singlePage: raw["singlePage"]?.bool,
      failIfMissingLicense: raw["failIfMissingLicense"]?.bool,
      addSources: raw["addSources"]?.bool,
      sandboxMode: raw["sandboxMode"]?.bool)
  }
}
