import Foundation
import LicensePlistCore
import Commander

let main = command(Option("cartfile-path", Consts.cartfileName),
                   Option("pods-path", Consts.podsDirectoryName),
                   Option("output-path", Consts.outputPath),
                   Option("github-token", ""),
                   Option("config-path", Consts.configPath),
                   Flag("force"),
                   Flag("add-version-numbers")) { cartfile, podsPath, output, gitHubToken, configPath, force, version in
                    let tool = LicensePlist()
                    tool.process(outputPath: URL(fileURLWithPath: output),
                                 cartfilePath: URL(fileURLWithPath: cartfile),
                                 podsPath: URL(fileURLWithPath: podsPath),
                                 gitHubToken: gitHubToken.isEmpty ? nil : gitHubToken,
                                 configPath: URL(fileURLWithPath: configPath),
                                 force: force,
                                 version: version)
}

main.run()
