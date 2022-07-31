import Foundation
import LoggerAPI

public final class LicensePlist {

    public init() {}

    public func process(options: Options) {
        Log.info("Start")
        GitHubAuthorization.shared.token = options.gitHubToken
        var info = PlistInfo(options: options)
        info.loadCocoaPodsLicense(acknowledgements: readPodsAcknowledgements(path: options.podsPath))
        info.loadGitHubLibraries(file: readCartfile(path: options.cartfilePath))
        info.loadGitHubLibraries(file: readMintfile(path: options.mintfilePath))

        do {
            let swiftPackageFileReadResults = try options.packagePaths.compactMap { packagePath in
                try SwiftPackageFileReader(path: packagePath).read()
            }

            if !swiftPackageFileReadResults.isEmpty {
                info.loadSwiftPackageLibraries(packageFiles: swiftPackageFileReadResults)
            }
        } catch {
            fatalError(error.localizedDescription)
        }

        do {
            if let xcodeFileReadResult = try xcodeFileReadResult(xcworkspacePath: options.xcworkspacePath, xcodeprojPath: options.xcodeprojPath),
               !xcodeFileReadResult.isEmpty {
                info.loadSwiftPackageLibraries(packageFiles: [xcodeFileReadResult])
            }
        } catch {
            fatalError(error.localizedDescription)
        }

        info.loadManualLibraries()
        info.compareWithLatestSummary()
        info.downloadGitHubLicenses()
        info.collectLicenseInfos()
        info.outputPlist()
        Log.info("End")
        info.reportMissings()
        info.finish()
        if !options.config.suppressOpeningDirectory {
            Shell.open(options.outputPath.path)
        }
    }

    /// Gets the result of attempting to read the `Package.resolved` from ether a Xcode Workspace or Xcode project.
    /// - note: If an Xcode workspace is found it is preferred over a Xcode project.
    private func xcodeFileReadResult(xcworkspacePath: URL, xcodeprojPath: URL) throws -> String? {

        var result: String?
        if xcworkspacePath.path.isEmpty == false {
            result = try XcodeWorkspaceFileReader(path: xcworkspacePath).read()
        }

        if result == nil && xcodeprojPath.path.isEmpty == false {
            result = try XcodeProjectFileReader(path: xcodeprojPath).read()
        }

        return result
    }
}

private func readCartfile(path: URL) -> GitHubLibraryConfigFile {
    if path.lastPathComponent != Consts.cartfileName {
        fatalError("Invalid Cartfile name: \(path.lastPathComponent)")
    }
    if let content = path.appendingPathExtension("resolved").lp.read() {
        return GitHubLibraryConfigFile(type: .carthage, content: content)
    }
    return .carthage(content: path.lp.read())
}

private func readMintfile(path: URL) -> GitHubLibraryConfigFile {
    if path.lastPathComponent != Consts.mintfileName {
        fatalError("Invalid MintFile name: \(path.lastPathComponent)")
    }
    return .mint(content: path.lp.read())
}

private func readPodsAcknowledgements(path: URL) -> [String] {
    if path.lastPathComponent != Consts.podsDirectoryName {
        fatalError("Invalid Pods name: \(path.lastPathComponent)")
    }

    let pathsToFind = [
        path.appendingPathComponent("Target Support Files"),
        path.appendingPathComponent("_Prebuild").appendingPathComponent("Target Support Files")
    ]

    let paths = pathsToFind.filter { $0.lp.isExists }
    if paths.isEmpty {
        pathsToFind.forEach { Log.warning("not found: \($0)") }
        return []
    }
    let urls = paths.flatMap { $0.lp.listDir() }
        .filter { $0.lp.isDirectory }
        .map { f in
            f.lp.listDir()
                .filter { $0.lastPathComponent.hasSuffix("-acknowledgements.plist") }
        }.flatMap { $0 }
    urls.forEach { Log.info("Pod acknowledgements found: \($0.lastPathComponent)") }
    return urls.map { $0.lp.read() }.compactMap { $0 }
}
