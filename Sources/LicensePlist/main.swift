import Foundation
import LicensePlistCore
import Commander

let main = command(Option("cartfile-path", ""),
                   Option("pods-path", ""),
                   Option("output-path", ""),
                   Option("github-token", "")) { cartfile, podsPath, output, gitHubToken in
                    let tool = LicensePlist()
                    tool.process(outputPath: output.isEmpty ? nil : URL(fileURLWithPath: output),
                                 cartfilePath: cartfile.isEmpty ? nil : URL(fileURLWithPath: cartfile),
                                 podsPath: podsPath.isEmpty ? nil : URL(fileURLWithPath: podsPath),
                                 gitHubToken: gitHubToken.isEmpty ? nil : gitHubToken)
}

main.run()
