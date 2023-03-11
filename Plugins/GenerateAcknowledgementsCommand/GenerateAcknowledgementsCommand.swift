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
        Diagnostics.warning("WORKDIR: \(context.pluginWorkDirectory)") // TODO: remove
        
        let licensePlist = try context.tool(named: "license-plist")
        var arguments = externalArgs.skip(argument: "--target")
        do {
//            arguments += ["--sandbox-mode"]
            let packageSources = try packageSourcesPath(context: context, arguments: arguments)
            arguments += ["--package-sources-path", packageSources]
            try licensePlist.run(arguments: arguments)
        } catch let error as RunError {
            Diagnostics.error(error.description)
        }
    }
    
    private func packageSourcesPath(context: XcodePluginContext, arguments: [String]) throws -> String {
        // Check external arguments
        let argumentNames = ["--swift-package-sources-path", "--package-sources-path"]
        for argumentName in argumentNames {
            if let path = arguments.value(of: argumentName) {
                return path
            }
        }
        
        // Check configuration file
        if let configPath = try configPath(context: context, arguments: arguments) {
            let yamlData = FileManager.default.contents(atPath: configPath.string) ?? Data()
            let yaml = String(data: yamlData, encoding: .utf8) ?? ""
            if let path = try parse(stringParameter: "packageSourcesPath", in: yaml) {
                return path
            }
        }
        
        // Return default folder with checked out package sources
        return context.pluginWorkDirectory
            .removingLastComponent()
            .removingLastComponent()
            .removingLastComponent()
            .removingLastComponent()
            .string
    }
    
    private func configPath(context: XcodePluginContext, arguments: [String]) throws -> Path? {
        let fileManager = FileManager.default
        
        // Check external arguments
        if let localPath = arguments.value(of: "--config-path") {
            let configPath = context.xcodeProject.directory.appending(subpath: localPath)
            if !fileManager.fileExists(atPath: configPath.string) {
                throw RunError(description: "Configuration file not found")
            }
            return configPath
        }
        
        // Check default configuration path
        let defaultConfigPath = context.xcodeProject.directory.appending(subpath: "license_plist.yml")
        if fileManager.fileExists(atPath: defaultConfigPath.string) {
            return defaultConfigPath
        }
        
        return nil
    }
}
#endif

private extension Array where Element == String {
    /// Filter out specified argument with its value.
    /// - Parameter argumentName: name of the argument, for example "--foo".
    /// - Returns: array of arguments.
    ///
    /// The method assumes that the specified argument precedes its value.
    func value(of argumentName: String) -> String? {
        var argumentIndex = 0
        while argumentIndex < count - 1 {
            if self[argumentIndex] == argumentName {
                return self[argumentIndex + 1]
            }
            argumentIndex += 1
        }
        return nil
    }
    
    /// Filter out specified argument with its value.
    /// - Parameter skippedArgumentName: name of the argument, for example "--foo".
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

/// Looks up for a string parameter in YAML.
/// - Parameters:
///   - name: name of the parameter.
///   - yaml: markup string.
/// - Returns: parsed value or nil if the parameter wasn't found.
private func parse(stringParameter name: String, in yaml: String) throws -> String? {
    let regex = try NSRegularExpression(pattern: "^\\s+\(name):(.*)")
    let range = NSRange(yaml.startIndex..<yaml.endIndex, in: yaml)
    let matches = regex.matches(in: yaml, options: [], range:range)
    
    if let match = matches.first {
        let range = match.range(at: 1)
        if let swiftRange = Range(range, in: yaml) {
            return String(yaml[swiftRange])
        }
    }
    
    return nil
}
