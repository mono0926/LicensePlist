import Foundation
import PackagePlugin

enum LicensePlistBuildToolError: Error {
    case workspaceNotFound
    case packageResolvedFileNotFound
    case configFileNotFound
}

@main
struct LicensePlistBuildTool: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        Diagnostics.error("Plugin only supported in Xcode build phases")
        return []
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension LicensePlistBuildTool: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        let licensePlist = try context.tool(named: "license-plist")
        let fileManager = FileManager.default
        
        // Checks LicensePlist config
        let configPath = context.xcodeProject.directory.appending(subpath: "license_plist.yml")
        guard fileManager.fileExists(atPath: configPath.string) else {
            throw LicensePlistBuildToolError.configFileNotFound
        }
        
        // The folder with checked out package sources
        let defaultPackageSourcesPath = context.pluginWorkDirectory
            .removingLastComponent()
            .removingLastComponent()
            .removingLastComponent()
            .removingLastComponent()
        
        // Parses package sources path from config
        let yamlData = fileManager.contents(atPath: configPath.string) ?? Data()
        let yaml = String(data: yamlData, encoding: .utf8) ?? ""
        let packageSourcesPath = try parse(stringParameter: "packageSourcesPath", in: yaml) ?? defaultPackageSourcesPath.string
        
        // Gets the workspace path in the project folder
        let projectDirectoryItems = try fileManager.contentsOfDirectory(atPath: context.xcodeProject.directory.string)
        guard let workspacePath = projectDirectoryItems.first(where: { $0.hasSuffix(".xcworkspace") }) else {
            throw LicensePlistBuildToolError.workspaceNotFound
        }
        
        // Package.resolved file path inside the workspace
        let packageResolvedPath = Path(fileManager.currentDirectoryPath)
            .appending(subpath: workspacePath)
            .appending(subpath: "xcshareddata/swiftpm/Package.resolved")
        guard fileManager.fileExists(atPath: packageResolvedPath.string) else {
            throw LicensePlistBuildToolError.packageResolvedFileNotFound
        }
        
        // Output directory inside build output directory
        let outputDirectoryName = "com.mono0926.LicensePlist.Output"
        let outputDirectoryPath = context.pluginWorkDirectory.appending(subpath: outputDirectoryName)
        try fileManager.createDirectory(atPath: outputDirectoryPath.string, withIntermediateDirectories: true)
        
        return [
            .prebuildCommand(displayName: "LicensePlist is processing licenses...",
                             executable: licensePlist.path,
                             arguments: ["--sandbox-mode",
                                         "--config-path", configPath,
                                         "--package-path", packageResolvedPath,
                                         "--package-sources-path", packageSourcesPath,
                                         "--output-path", outputDirectoryPath],
                             outputFilesDirectory: context.pluginWorkDirectory)
        ]
    }
}

#endif

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
