import Foundation
import LicensePlistCore
import Commander
import LoggerAPI

private func loadConfig(configPath: URL) -> Config {
    if let yaml = configPath.lp.read() {
        return Config(yaml: yaml)
    }
    return Config.empty
}

let main = command(Option("cartfile-path", Consts.cartfileName),
                   Option("pods-path", Consts.podsDirectoryName),
                   Option("output-path", Consts.outputPath),
                   Option("github-token", ""),
                   Option("config-path", Consts.configPath),
                   Flag("force"),
                   Flag("add-version-numbers"),
                   Flag("suppress-opening-directory")) { cartfile, podsPath, output, gitHubToken, configPath, force, version, suppressOpen in

                    Logger.configure()
                    var config = loadConfig(configPath: URL(fileURLWithPath: configPath))
                    config.force = force
                    config.addVersionNumbers = version
                    config.suppressOpeningDirectory = suppressOpen
                    let options = Options(outputPath: URL(fileURLWithPath: output),
                                          cartfilePath: URL(fileURLWithPath: cartfile),
                                          podsPath: URL(fileURLWithPath: podsPath),
                                          gitHubToken: gitHubToken.isEmpty ? nil : gitHubToken,
                                          config: config)
                    let tool = LicensePlist()
                    tool.process(options: options)
}

main.run()
