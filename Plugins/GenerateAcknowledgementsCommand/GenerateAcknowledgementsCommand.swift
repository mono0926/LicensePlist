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
        let licensePlist = try context.tool(named: "license-plist")
        let processedArguments = externalArgs.skip(argument: "--target")
        do {
            try licensePlist.run(arguments: processedArguments)
        } catch let error as RunError {
            Diagnostics.error(error.description)
        }
    }
}
#endif

private extension Array where Element == String {
    /// Filter out specified argument with its value.
    /// - Parameter argument: name of the argument, for example "--foo".
    /// - Returns: array of arguments.
    ///
    /// The method assumes that the specified argument precedes its value.
    func skip(argument skippedArgumentName: String) -> [String] {
        var argumentIndex = 0
        var resultArguments = [String]()
        while argumentIndex < count {
            let currentArgumentName = self[argumentIndex]
            if currentArgumentName == skippedArgumentName {
                argumentIndex += 2
            } else {
                resultArguments.append(currentArgumentName)
                argumentIndex += 1
            }
        }
        return resultArguments
    }
}

private struct RunError: Error {
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
