import XCTest

/// Tests the path resolution algorithm used by Xcode plugins to locate
/// the SourcePackages directory from `pluginWorkDirectoryURL`.
///
/// Plugin targets cannot be imported in tests, so these tests validate the
/// algorithm directly using URL manipulation — the same operations the plugins perform.
final class PluginPathResolutionTests: XCTestCase {

    // MARK: - GenerateAcknowledgementsCommand path resolution

    /// Old Xcode (<=16.2): pluginWorkDirectoryURL is under SourcePackages.
    /// Path: {DerivedData}/xxx/SourcePackages/plugins/GenerateAcknowledgementsCommand/
    /// Going up 2 levels should yield {DerivedData}/xxx/SourcePackages/
    func testCommandPlugin_oldXcode_resolvesSourcePackages() {
        let pluginWorkDir = URL(fileURLWithPath: "/Users/user/Library/Developer/Xcode/DerivedData/MyApp-abc/SourcePackages/plugins/GenerateAcknowledgementsCommand")

        let resolved = resolvePackageSourcesPath_commandPlugin(pluginWorkDirectoryURL: pluginWorkDir)

        XCTAssertEqual(resolved.path, "/Users/user/Library/Developer/Xcode/DerivedData/MyApp-abc/SourcePackages")
    }

    /// New Xcode (>=16.3 / Xcode 26): pluginWorkDirectoryURL is under Build/Intermediates.noindex.
    /// Path: {DerivedData}/xxx/Build/Intermediates.noindex/CommandPluginIntermediates/GenerateAcknowledgementsCommand/
    /// The naive 2-level ascent would land at Build/Intermediates.noindex/ — wrong.
    /// The fix must detect the absence of "SourcePackages" and navigate to {DerivedData}/xxx/SourcePackages/
    func testCommandPlugin_newXcode_resolvesSourcePackages() {
        let pluginWorkDir = URL(fileURLWithPath: "/Users/user/Library/Developer/Xcode/DerivedData/MyApp-abc/Build/Intermediates.noindex/CommandPluginIntermediates/GenerateAcknowledgementsCommand")

        let resolved = resolvePackageSourcesPath_commandPlugin(pluginWorkDirectoryURL: pluginWorkDir)

        XCTAssertEqual(resolved.path, "/Users/user/Library/Developer/Xcode/DerivedData/MyApp-abc/SourcePackages")
    }

    /// Verifies that checkouts can be found under the resolved path.
    func testCommandPlugin_newXcode_checkoutsPath() {
        let pluginWorkDir = URL(fileURLWithPath: "/Users/user/Library/Developer/Xcode/DerivedData/MyApp-abc/Build/Intermediates.noindex/CommandPluginIntermediates/GenerateAcknowledgementsCommand")

        let resolved = resolvePackageSourcesPath_commandPlugin(pluginWorkDirectoryURL: pluginWorkDir)
        let checkoutsPath = resolved.appendingPathComponent("checkouts")

        XCTAssertEqual(checkoutsPath.path, "/Users/user/Library/Developer/Xcode/DerivedData/MyApp-abc/SourcePackages/checkouts")
    }

    // MARK: - LicensePlistBuildTool path resolution (regression guard)

    /// Old Xcode: pluginWorkDirectoryURL is under SourcePackages.
    /// Path: {DerivedData}/xxx/SourcePackages/plugins/MyApp.output/MyApp/LicensePlistBuildTool/
    func testBuildToolPlugin_oldXcode_resolvesSourcePackages() {
        let pluginWorkDir = URL(fileURLWithPath: "/Users/user/Library/Developer/Xcode/DerivedData/MyApp-abc/SourcePackages/plugins/MyApp.output/MyApp/LicensePlistBuildTool")

        let resolved = resolvePackageSourcesPath_buildToolPlugin(pluginWorkDirectoryURL: pluginWorkDir)

        XCTAssertEqual(resolved.path, "/Users/user/Library/Developer/Xcode/DerivedData/MyApp-abc/SourcePackages")
    }

    /// New Xcode: pluginWorkDirectoryURL is under Build/Intermediates.noindex.
    /// Path: {DerivedData}/xxx/Build/Intermediates.noindex/BuildToolPluginIntermediates/MyApp.output/MyApp/LicensePlistBuildTool/
    func testBuildToolPlugin_newXcode_resolvesSourcePackages() {
        let pluginWorkDir = URL(fileURLWithPath: "/Users/user/Library/Developer/Xcode/DerivedData/MyApp-abc/Build/Intermediates.noindex/BuildToolPluginIntermediates/MyApp.output/MyApp/LicensePlistBuildTool")

        let resolved = resolvePackageSourcesPath_buildToolPlugin(pluginWorkDirectoryURL: pluginWorkDir)

        XCTAssertEqual(resolved.path, "/Users/user/Library/Developer/Xcode/DerivedData/MyApp-abc/SourcePackages")
    }

    // MARK: - Algorithm implementations (mirrors plugin code)

    /// Mirrors GenerateAcknowledgementsCommand.packageSourcesPath
    private func resolvePackageSourcesPath_commandPlugin(pluginWorkDirectoryURL: URL) -> URL {
        let isInSourcePackagesDirectory = pluginWorkDirectoryURL.pathComponents.contains {
            $0 == "SourcePackages"
        }

        var packageSourcesPath = pluginWorkDirectoryURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        if !isInSourcePackagesDirectory {
            packageSourcesPath = packageSourcesPath
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appending(component: "SourcePackages")
        }

        return packageSourcesPath
    }

    /// Mirrors LicensePlistBuildTool.packageSourcesPath (from PR #241)
    private func resolvePackageSourcesPath_buildToolPlugin(pluginWorkDirectoryURL: URL) -> URL {
        let isInSourcePackagesDirectory = pluginWorkDirectoryURL.pathComponents.contains {
            $0 == "SourcePackages"
        }

        var packageSourcesPath = pluginWorkDirectoryURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        if !isInSourcePackagesDirectory {
            packageSourcesPath = packageSourcesPath
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appending(component: "SourcePackages")
        }

        return packageSourcesPath
    }
}
