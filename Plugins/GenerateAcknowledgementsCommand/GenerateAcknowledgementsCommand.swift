import Foundation
import PackagePlugin

@main
struct GenerateAcknowledgementsCommand: CommandPlugin {
    func performCommand(context: PluginContext, arguments externalArgs: [String]) async throws {
        Diagnostics.warning("Command only supported as Xcode command")
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension GenerateAcknowledgementsCommand: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments externalArgs: [String]) throws {
        Diagnostics.warning("ARGUMENTS: \(externalArgs.joined(","))") // TODO: Remove
        let licensePlist = try context.tool(named: "license-plist")        
        do {
            try licensePlist.run(arguments: externalArgs)
        } catch let error as RunError {
            Diagnostics.error(error.description)
        }
    }
}
#endif

struct RunError: Error {
    let description: String
}

private extension PluginContext.Tool {
    func run(arguments: [String]) throws {
        let pipe = Pipe()
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path.string)
        process.arguments = arguments
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        if process.terminationReason == .exit && process.terminationStatus == 0 {
            return
        }

        let data = try pipe.fileHandleForReading.readToEnd()
        let stderr = data.flatMap { String(data: $0, encoding: .utf8) }

        if let stderr {
            throw RunError(description: stderr)
        } else {
            let problem = "\(process.terminationReason.rawValue):\(process.terminationStatus)"
            throw RunError(description: "\(name) invocation failed: \(problem)")
        }
    }
}
