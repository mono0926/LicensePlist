import Foundation
import PackagePlugin

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
        let configPath = context.xcodeProject.directoryURL.appending(component: "license_plist.yml")
        guard fileManager.fileExists(atPath: configPath.path) else {
            Diagnostics.error("Can't find 'license_plist.yml' file")
            return []
        }
        
        // The folder with checked out package sources
        let packageSourcesPath = context.pluginWorkDirectoryURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        // Output directory inside build output directory
        let outputDirectoryPath = context.pluginWorkDirectoryURL.appending(component: "com.mono0926.LicensePlist.Output")
        try fileManager.createDirectory(atPath: outputDirectoryPath.path, withIntermediateDirectories: true)

        return [
            .prebuildCommand(displayName: "LicensePlist is processing licenses...",
                             executable: licensePlist.url,
                             arguments: ["--sandbox-mode",
                                         "--config-path", configPath.path,
                                         "--package-sources-path", packageSourcesPath.path,
                                         "--output-path", outputDirectoryPath.path],
                             outputFilesDirectory: context.pluginWorkDirectoryURL)
        ]
    }
}

#endif
