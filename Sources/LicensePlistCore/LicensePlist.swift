import Foundation
import LoggerAPI

public final class LicensePlist {

    public init() {}

    public func process(options: Options) {
        Log.info("Start")
        GitHubAuthorization.shared.token = options.gitHubToken
        var info = PlistInfo(options: options)
        info.loadCocoaPodsLicense(acknowledgements: readPodsAcknowledgements(path: options.podsPath))
        info.loadGitHubLibraries(cartfile: readCartfile(path: options.cartfilePath))
        info.loadSwiftPackageLibraries(packageFile: readSwiftPackages(path: options.packagePath) ?? readXcodeProject(path: options.xcodeprojPath))
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

private func readCartfile(path: URL) -> String? {
    if path.lastPathComponent != Consts.cartfileName {
        fatalError("Invalid Cartfile name: \(path.lastPathComponent)")
    }
    if let content = path.appendingPathExtension("resolved").lp.read() {
        return content
    }
    return path.lp.read()
}

private func readSwiftPackages(path: URL) -> String? {
    if path.lastPathComponent != Consts.packageName && path.lastPathComponent != "Package.resolved" {
        fatalError("Invalid Package.swift name: \(path.lastPathComponent)")
    }
    if let content = path.deletingPathExtension().appendingPathExtension("resolved").lp.read() {
        return content
    }
    return path.lp.read()
}

private func readXcodeProject(path: URL) -> String? {

    var projectPath: URL?
    if path.lastPathComponent.contains("*") {
        // find first "xcodeproj" in directory
        projectPath = path.deletingLastPathComponent().lp.listDir().first { $0.pathExtension == Consts.xcodeprojExtension }
    } else {
        // use the specified path
        projectPath = path
    }
    guard let validatedPath = projectPath else { return nil }

    if validatedPath.pathExtension != Consts.xcodeprojExtension {
        return nil
    }
    let packageResolvedPath = validatedPath
        .appendingPathComponent("project.xcworkspace")
        .appendingPathComponent("xcshareddata")
        .appendingPathComponent("swiftpm")
        .appendingPathComponent("Package.resolved")
    return readSwiftPackages(path: packageResolvedPath)
}

private func readPodsAcknowledgements(path: URL) -> [String] {
    if path.lastPathComponent != Consts.podsDirectoryName {
        fatalError("Invalid Pods name: \(path.lastPathComponent)")
    }
    let path = path.appendingPathComponent("Target Support Files")
    if !path.lp.isExists {
        Log.warning("not found: \(path)")
        return []
    }
    let urls = path.lp.listDir()
        .filter { $0.lp.isDirectory }
        .map { f in
            f.lp.listDir()
                .filter { $0.lastPathComponent.hasSuffix("-acknowledgements.plist") }
        }.flatMap { $0 }
    urls.forEach { Log.info("Pod acknowledgements found: \($0.lastPathComponent)") }
    return urls.map { $0.lp.read() }.compactMap { $0 }
}
