import Foundation
import LicensePlistCore
import Commander

let main = command(Option("cartfile-path", ""),
                   Option("podfile-path", ""),
                   Option("output-path", ""),
                   Option("github-token", "")) { cartfile, podfile, output, gitHubToken in
                    let tool = LicensePlist()
                    tool.process(outputPath: output.isEmpty ? nil : URL(fileURLWithPath: output),
                                 cartfilePath: cartfile.isEmpty ? nil : URL(fileURLWithPath: cartfile),
                                 podfilePath: podfile.isEmpty ? nil : URL(fileURLWithPath: podfile),
                                 gitHubToken: gitHubToken.isEmpty ? nil : gitHubToken)
}

main.run()
