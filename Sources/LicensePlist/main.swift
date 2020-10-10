import Foundation
import LicensePlistCore
import ArgumentParser
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

struct LicensePlist: ParsableCommand {
	@Option(name: .long, completion: .file())
	var cartfilePath = Consts.cartfileName
	
	@Option(name: .long, completion: .file())
	var mintfilePath = Consts.mintfileName
	
	@Option(name: .long, completion: .directory)
	var podsPath = Consts.podsDirectoryName
	
	@Option(name: .long, completion: .file())
	var packagePath = Consts.packageName
	
	@Option(name: .long, completion: .file())
	var xcodeprojPath = "*.xcodeproj"
	
	@Option(name: .long, completion: .file())
	var outputPath = Consts.outputPath
	
	@Option(name: .long, completion: .empty )
	var githubToken: String?
	
	@Option(name: .long, completion: .file())
	var configPath = Consts.configPath
	
	@Option(name: .long, completion: .empty)
	var prefix = Consts.prefix
	
	@Option(name: .long, completion: .file())
	var htmlPath: String?
	
	@Option(name: .long, completion: .file())
	var markdownPath: String?
	
	@Flag(name: .long)
	var force = false
	
	@Flag(name: .long)
	var addVersionNumbers = false
	
	@Flag(name: .long)
	var suppressOpeningDirectory = false
	
	@Flag(name: .long)
	var singlePage = false
	
	@Flag(name: .long)
	var failIfMissingLicense = false
	
	func run() throws {
		Logger.configure()
		var config = loadConfig(configPath: URL(fileURLWithPath: configPath))
		config.force = force
		config.addVersionNumbers = addVersionNumbers
		config.suppressOpeningDirectory = suppressOpeningDirectory
		config.singlePage = singlePage
		config.failIfMissingLicense = failIfMissingLicense
		let options = Options(outputPath: URL(fileURLWithPath: outputPath),
									 cartfilePath: URL(fileURLWithPath: cartfilePath),
									 mintfilePath: URL(fileURLWithPath: mintfilePath),
									 podsPath: URL(fileURLWithPath: podsPath),
									 packagePath: URL(fileURLWithPath: packagePath),
									 xcodeprojPath: URL(fileURLWithPath: xcodeprojPath),
									 prefix: prefix,
									 gitHubToken: githubToken ?? ProcessInfo.processInfo.environment["LICENSE_PLIST_GITHUB_TOKEN"],
									 htmlPath: htmlPath.map { return URL(fileURLWithPath: $0) },
									 markdownPath: markdownPath.map { return URL(fileURLWithPath: $0) },
									 config: config)
		let tool = LicensePlistCore.LicensePlist()
		tool.process(options: options)
	}
}

LicensePlist.main()

//let main = command(Option("cartfile-path", default: Consts.cartfileName),
//                   Option("mintfile-path", default: Consts.mintfileName),
//                   Option("pods-path", default: Consts.podsDirectoryName),
//                   Option("package-path", default: Consts.packageName),
//                   Option("xcodeproj-path", default: "*.xcodeproj"),
//                   Option("output-path", default: Consts.outputPath),
//                   Option("github-token", default: ""),
//                   Option("config-path", default: Consts.configPath),
//                   Option("prefix", default: Consts.prefix),
//                   Option("html-path", default: ""),
//                   Option("markdown-path", default: ""),
//                   Flag("force"),
//                   Flag("add-version-numbers"),
//                   Flag("suppress-opening-directory"),
//                   Flag("single-page"),
//                   Flag("fail-if-missing-license")) { cartfile, mintfile, podsPath, packagePath, xcodeprojPath, output, gitHubToken, configPath, prefix, htmlPath, markdownPath, force, version, suppressOpen, singlePage, failIfMissingLicense in
//
//                    Logger.configure()
//                    var config = loadConfig(configPath: URL(fileURLWithPath: configPath))
//                    config.force = force
//                    config.addVersionNumbers = version
//                    config.suppressOpeningDirectory = suppressOpen
//                    config.singlePage = singlePage
//                    config.failIfMissingLicense = failIfMissingLicense
//                    let options = Options(outputPath: URL(fileURLWithPath: output),
//                                          cartfilePath: URL(fileURLWithPath: cartfile),
//                                          mintfilePath: URL(fileURLWithPath: mintfile),
//                                          podsPath: URL(fileURLWithPath: podsPath),
//                                          packagePath: URL(fileURLWithPath: packagePath),
//                                          xcodeprojPath: URL(fileURLWithPath: xcodeprojPath),
//                                          prefix: prefix,
//                                          gitHubToken: gitHubToken.isEmpty ? ProcessInfo.processInfo.environment["LICENSE_PLIST_GITHUB_TOKEN"] : gitHubToken,
//                                          htmlPath: htmlPath.isEmpty ? nil : URL(fileURLWithPath: htmlPath),
//                                          markdownPath: markdownPath.isEmpty ? nil : URL(fileURLWithPath: markdownPath),
//                                          config: config)
//                    let tool = LicensePlist()
//                    tool.process(options: options)
//}
//
//main.run()
