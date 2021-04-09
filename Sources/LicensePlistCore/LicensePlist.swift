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
            let swiftPackageFileReadResult = try SwiftPackageFileReader(path: options.packagePath).read()
            let xcodeProjectFileReadResult = try XcodeProjectFileReader(path: options.xcodeprojPath).read()
            info.loadSwiftPackageLibraries(packageFile: swiftPackageFileReadResult ?? xcodeProjectFileReadResult)
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
