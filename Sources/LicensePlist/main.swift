import ArgumentParser
import Foundation
import LicensePlistCore
import LoggerAPI

private func loadConfig(configPath: URL) -> Config {
    if let yaml = configPath.lp.read() {
        return Config(yaml: yaml, configBasePath: configPath.deletingLastPathComponent())
    }
    return Config.empty
}

extension CompletionKind {
    static var empty: CompletionKind {
        return .custom { _ in return [] }
    }
}

extension LogLevel: EnumerableFlag {
    public static var allCases: [LogLevel] = [.silenceMode, .normalLogLevel, .verbose]
}

// Typename used for usage in help command
struct LicensePlist: ParsableCommand {
    static let configuration = CommandConfiguration(version: Consts.version,
                                                    subcommands: [AddAcknowledgementsCopyScript.self])

    @Option(name: .long, completion: .file())
    var cartfilePath: String?

    @Option(name: .long, completion: .file())
    var mintfilePath: String?

    @Option(name: .long, completion: .directory)
    var podsPath: String?

    @Option(name: [.customLong("package-path"), .customLong("swift-package-path"), .long, .customLong("swift-package-paths")], parsing: .upToNextOption, completion: .file())
    var packagePaths = [String]()

    @Option(name: [.long, .customLong("swift-package-sources-path")], completion: .directory)
    var packageSourcesPath: String?

    @Option(name: .long, completion: .file())
    var xcworkspacePath: String?

    @Option(name: .long, completion: .file())
    var xcodeprojPath: String?

    @Option(name: .long, completion: .file())
    var outputPath: String?

    @Option(name: .long, help: "You can also pass the token via the '\(Environment.Keys.githubToken)' environment variable.", completion: .empty)
    var githubToken: String?

    @Option(name: .long, completion: .file())
    var configPath = Consts.configPath

    @Option(name: .long, completion: .empty)
    var prefix: String?

    @Option(name: .long, completion: .file())
    var htmlPath: String?

    @Option(name: .long, completion: .file())
    var markdownPath: String?

    @Option(name: .long, parsing: .upToNextOption, completion: .empty)
    var licenseFileNames = [String]()

    @Flag(name: .long, inversion: .prefixedNo)
    var force: Bool?

    @Flag(name: .long, inversion: .prefixedNo)
    var addVersionNumbers: Bool?

    @Flag(name: .long, inversion: .prefixedNo)
    var addSources: Bool?

    @Flag(name: .long, inversion: .prefixedNo)
    var suppressOpeningDirectory: Bool?

    @Flag(name: .long, inversion: .prefixedNo)
    var singlePage: Bool?

    @Flag(name: .long, inversion: .prefixedNo)
    var failIfMissingLicense: Bool?

    @Flag(name: .long, inversion: .prefixedNo)
    var sandboxMode: Bool?

    @Flag(exclusivity: .chooseLast)
    var logLevel: LogLevel = .normalLogLevel

    @Flag(name: .long,
          inversion: .prefixedNo,
          exclusivity: .chooseLast,
          help: "This command line option take precedence over the '\(Environment.Keys.noColor)' environment variable.")
    var color: Bool?

    func run() throws {
        Logger.configure(logLevel: logLevel, colorCommandLineFlag: color)

        var config = loadConfig(configPath: URL(fileURLWithPath: configPath))
        config.force = force ?? config.options.force ?? false
        config.addVersionNumbers = addVersionNumbers ?? config.options.addVersionNumbers ?? false
        config.sandboxMode = sandboxMode ?? config.options.sandboxMode ?? false
        config.suppressOpeningDirectory = (suppressOpeningDirectory ?? config.options.suppressOpeningDirectory ?? false) || config.sandboxMode
        config.singlePage = singlePage ?? config.options.singlePage ?? false
        config.failIfMissingLicense = failIfMissingLicense ?? config.options.failIfMissingLicense ?? false
        config.addSources = addSources ?? config.options.addSources ?? false
        let cartfilePath = cartfilePath.asPathURL(other: config.options.cartfilePath, default: Consts.cartfileName)
        let mintfilePath = mintfilePath.asPathURL(other: config.options.mintfilePath, default: Consts.mintfileName)
        let podsPath = podsPath.asPathURL(other: config.options.podsPath, default: Consts.podsDirectoryName)
        let configPackagePaths = config.options.packagePaths ?? [URL(fileURLWithPath: Consts.packageName)]
        let packagePaths = packagePaths.isEmpty ? configPackagePaths : packagePaths.map { URL(fileURLWithPath: $0) }
        let packageSourcesPath = packageSourcesPath.asPathURL(other: config.options.packageSourcesPath, isDirectory: true)
        let xcworkspacePath = xcworkspacePath.asPathURL(other: config.options.xcworkspacePath, default: Consts.xcworkspacePath)
        let xcodeprojPath = xcodeprojPath.asPathURL(other: config.options.xcodeprojPath, default: Consts.xcodeprojPath)
        let outputPath = outputPath.asPathURL(other: config.options.outputPath, default: Consts.outputPath)
        let githubToken = githubToken ?? config.options.gitHubToken ?? Environment.shared[.githubToken]
        let prefix = prefix ?? config.options.prefix ?? Consts.prefix
        let htmlPath = htmlPath.asPathURL(other: config.options.htmlPath)
        let markdownPath = markdownPath.asPathURL(other: config.options.markdownPath)
        let configLicenseFileNames = config.options.licenseFileNames ?? Consts.licenseFileNames
        let licenseFileNames = licenseFileNames.isEmpty ? configLicenseFileNames : licenseFileNames
        let options = Options(outputPath: outputPath,
                              cartfilePath: cartfilePath,
                              mintfilePath: mintfilePath,
                              podsPath: podsPath,
                              packagePaths: packagePaths,
                              packageSourcesPath: packageSourcesPath,
                              xcworkspacePath: xcworkspacePath,
                              xcodeprojPath: xcodeprojPath,
                              prefix: prefix,
                              gitHubToken: githubToken,
                              htmlPath: htmlPath,
                              markdownPath: markdownPath,
                              licenseFileNames: licenseFileNames,
                              config: config)
        let tool = LicensePlistCore.LicensePlist()
        tool.process(options: options)
    }
}

LicensePlist.main()
