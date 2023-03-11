import Foundation
import PackagePlugin

@main
struct AddAcknowledgementsCopyScriptCommand: CommandPlugin {
    func performCommand(context: PluginContext, arguments externalArgs: [String]) async throws {
        Diagnostics.warning("Command only supported as Xcode command")
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension AddAcknowledgementsCopyScriptCommand: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments externalArgs: [String]) throws {
        let licensePlist = try context.tool(named: "license-plist")
        var arguments = ["add-acknowledgements-copy-script"] + externalArgs
        
        do {
            arguments += ["--xcodeproj", try findXcodeprojPath(context: context)]
            try licensePlist.run(arguments: arguments)
        } catch let error as RunError {
            Diagnostics.error(error.description)
        }
    }
    
    private func findXcodeprojPath(context: XcodePluginContext) throws -> String {
        let projectDirectoryItems = try? FileManager.default.contentsOfDirectory(atPath: context.xcodeProject.directory.string)
        let xcodeprojFiles = projectDirectoryItems?.filter { $0.hasSuffix(".xcodeproj") }
        
        guard let xcodeprojFiles = xcodeprojFiles, !xcodeprojFiles.isEmpty else {
            throw RunError(description: ".xcodeproj file not found in the project directory")
        }
        
        guard xcodeprojFiles.count == 1 else {
            throw RunError(description: "Too many .xcodeproj files in the project directory")
        }
        
        return xcodeprojFiles[0]
    }
}
#endif

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
