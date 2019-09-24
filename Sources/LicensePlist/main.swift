import Foundation
import LicensePlistCore
import Commander
import LoggerAPI

private func loadConfig(configPath: URL) -> Config {
    if let yaml = configPath.lp.read() {
        return Config(yaml: yaml, configBasePath: configPath.deletingLastPathComponent())
    }
    return Config.empty
}

let main = command(Option("cartfile-path", default: Consts.cartfileName),
                   Option("pods-path", default: Consts.podsDirectoryName),
                   Option("package-path", default: Consts.packageName),
                   Option("output-path", default: Consts.outputPath),
                   Option("github-token", default: ""),
                   Option("config-path", default: Consts.configPath),
                   Option("prefix", default: Consts.prefix),
                   Option("html-path", default: ""),
                   Option("markdown-path", default: ""),
                   Flag("force"),
                   Flag("add-version-numbers"),
                   Flag("suppress-opening-directory")) { cartfile, podsPath, packagePath, output, gitHubToken, configPath, prefix, htmlPath, markdownPath, force, version, suppressOpen in

                    Logger.configure()
                    var config = loadConfig(configPath: URL(fileURLWithPath: configPath))
                    config.force = force
                    config.addVersionNumbers = version
                    config.suppressOpeningDirectory = suppressOpen
                    let options = Options(outputPath: URL(fileURLWithPath: output),
                                          cartfilePath: URL(fileURLWithPath: cartfile),
                                          podsPath: URL(fileURLWithPath: podsPath),
                                          packagePath: URL(fileURLWithPath: packagePath),
                                          prefix: prefix,
                                          gitHubToken: gitHubToken.isEmpty ? nil : gitHubToken,
                                          htmlPath: htmlPath.isEmpty ? nil : URL(fileURLWithPath: htmlPath),
                                          markdownPath: markdownPath.isEmpty ? nil : URL(fileURLWithPath: markdownPath),
                                          config: config)
                    let tool = LicensePlist()
                    tool.process(options: options)
}

main.run()
