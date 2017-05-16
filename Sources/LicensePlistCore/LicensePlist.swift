import Foundation
import LoggerAPI

public final class LicensePlist {

    public init() {}

    public func process(options: Options) {
        Log.info("Start")
        GitHubAuthorizatoin.shared.token = options.gitHubToken
        var info = PlistInfo(options: options)
        info.loadCocoaPodsLicense(acknowledgements: readPodsAcknowledgements(path: options.podsPath))
        info.loadGitHubLibraries(cartfile: readCartfile(path: options.cartfilePath))
        info.compareWithLatestSummary()
        info.downloadGitHubLicenses()
        info.collectLicenseInfos()
        info.outputPlist()
        Log.info("End")
        info.reportMissings()
        info.finish()
        Shell.open(options.outputPath.path)
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
    return urls.map { $0.lp.read() }.flatMap { $0 }
}
