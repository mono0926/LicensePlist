import Foundation
import LicensePlistCore
import Commander

private func loadConfig(configPath: URL) -> Config {
    if let yaml = IOUtil.read(path: configPath) {
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
                   Flag("add-version-numbers")) { cartfile, podsPath, output, gitHubToken, configPath, force, version in

                    var config = loadConfig(configPath: URL(fileURLWithPath: configPath))
                    config.force = force
                    config.addVersionNumbers = version
                    let options = Options(outputPath: URL(fileURLWithPath: output),
                                          cartfilePath: URL(fileURLWithPath: cartfile),
                                          podsPath: URL(fileURLWithPath: podsPath),
                                          gitHubToken: gitHubToken.isEmpty ? nil : gitHubToken,
                                          config: config)
                    let tool = LicensePlist()
                    tool.process(options: options)
}

main.run()
