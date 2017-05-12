import Foundation
import LoggerAPI

private var runWhenFinished: (() -> Void)!
public final class LicensePlist {
    private var githubLibraries: [GitHub]?

    public init() {
        Logger.configure()
    }

    public func process(options: Options) {
        Log.info("Start")
        GitHubAuthorizatoin.shared.token = options.gitHubToken

        let licenses = collectLicenseInfos(options: options)
        outputPlist(licenses: licenses, options: options)
        Log.info("End")
        reportMissings(licenses: licenses)
        runWhenFinished()
        shell("open", options.outputPath.path)
    }

    private func collectLicenseInfos(options: Options) -> [LicenseInfo] {
        Log.info("Pods License parse start")
        let config = options.config

        let podsAcknowledgements = readPodsAcknowledgements(path: options.podsPath)
        let path = options.podsPath.appendingPathComponent("Manifest.lock")
        let podsVersionInfo = VersionInfo.parse(podsManifest: IOUtil.read(path: path) ?? "")
        var cocoaPodsLicenses = podsAcknowledgements
            .map { CocoaPodsLicense.load($0, versionInfo: podsVersionInfo) }
            .flatMap { $0 }
        cocoaPodsLicenses = config.rename(config.filterExcluded(cocoaPodsLicenses))

        Log.info("Carthage License collect start")

        var gitHubLibraries = GitHub.load(readCartfile(path: options.cartfilePath) ?? "")
        gitHubLibraries = config.apply(githubs: gitHubLibraries)

        let contents = (cocoaPodsLicenses.map { String(describing: $0) } +
            gitHubLibraries.map { String(describing: $0) } +
            config.renames.map { "\($0.key):\($0.value)" } +
            ["add-version-numbers: \(options.config.addVersionNumbers)", "LicensePlist Version: \(Consts.version)"])
            .joined(separator: "\n\n")
        let savePath = options.outputPath.appendingPathComponent("\(Consts.prefix).latest_result.txt")
        if let previous = IOUtil.read(path: savePath), previous == contents, !options.config.force {
            Log.warning("Completed because no diff. You can execute force by `--force` flag.")
            exit(0)
        }
        runWhenFinished = {
            try! contents.write(to: savePath, atomically: true, encoding: Consts.encoding)
        }

        let queue = OperationQueue()
        let carthageOperations = gitHubLibraries.map { GitHubLicense.collect($0) }
        queue.addOperations(carthageOperations, waitUntilFinished: true)
        let carthageLicenses = config.rename(carthageOperations.map { $0.result?.value }.flatMap { $0 })
        self.githubLibraries = config.rename(gitHubLibraries)

        return ((cocoaPodsLicenses as [LicenseInfo]) + (carthageLicenses as [LicenseInfo]))
            .reduce([String: LicenseInfo]()) { sum, e in
                var sum = sum
                sum[e.name] = e
                return sum
            }.values
            .sorted { $0.name.lowercased() < $1.name.lowercased() }
    }

    private func reportMissings(licenses: [LicenseInfo]) {
        Log.info("----------Result-----------")
        Log.info("# Missing license:")
        guard let carthageLibraries = githubLibraries else {
            assert(false)
            return
        }
        let missing = Set(carthageLibraries.map { $0.name }).subtracting(Set(licenses.map { $0.name }))
        if missing.isEmpty {
            Log.info("None🎉")
        } else {
            Array(missing).sorted { $0 < $1 }.forEach { Log.warning($0) }
        }
    }
}

private func outputPlist(licenses: [LicenseInfo], options: Options) {

    let tm = TemplateManager.shared

    let outputPath = options.outputPath
    let fm = FileManager.default
    let plistPath = outputPath.appendingPathComponent(Consts.prefix)
    if fm.fileExists(atPath: plistPath.path) {
        try! fm.removeItem(at: plistPath)
        Log.info("Deleted exiting plist within \(Consts.prefix)")
    }
    try! fm.createDirectory(at: plistPath, withIntermediateDirectories: true, attributes: nil)
    Log.info("Directory created: \(outputPath)")

    let licensListItems = licenses.map {
        return tm.licenseListItem.applied(["Title": $0.name(withVersion: options.config.addVersionNumbers),
                                           "FileName": "\(Consts.prefix)/\($0.name)"])
    }
    let licenseListPlist = tm.licenseList.applied(["Item": licensListItems.joined(separator: "\n")])
    write(content: licenseListPlist, to: outputPath.appendingPathComponent("\(Consts.prefix).plist"))

    licenses.forEach {
        write(content: tm.license.applied(["Body": $0.bodyEscaped]),
              to: plistPath.appendingPathComponent("\($0.name).plist"))
    }
}

private func write(content: String, to path: URL) {
    try! content.write(to: path, atomically: false, encoding: Consts.encoding)
}

private func readCartfile(path: URL) -> String? {
    if path.lastPathComponent != Consts.cartfileName {
        fatalError("Invalid Cartfile name: \(path.lastPathComponent)")
    }
    if let content = IOUtil.read(path: path.appendingPathExtension("resolved")) {
        return content
    }
    return IOUtil.read(path: path)
}

private func readPodsAcknowledgements(path: URL) -> [String] {
    if path.lastPathComponent != Consts.podsDirectoryName {
        fatalError("Invalid Pods name: \(path.lastPathComponent)")
    }
    let path = path.appendingPathComponent("Target Support Files")
    let fm = FileManager.default
    if !fm.fileExists(atPath: path.path) {
        Log.warning("not found: \(path)")
        return []
    }
    let urls = (try! fm.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: []))
        .filter {
            var isDirectory: ObjCBool = false
            fm.fileExists(atPath: $0.path, isDirectory: &isDirectory)
            return isDirectory.boolValue
        }
        .map { f in
            (try! fm.contentsOfDirectory(at: f, includingPropertiesForKeys: nil, options: []))
                .filter { $0.lastPathComponent.hasSuffix("-acknowledgements.plist") }
        }.flatMap { $0 }
    urls.forEach { Log.info("Pod acknowledgements found: \($0.lastPathComponent)") }
    return urls.map { IOUtil.read(path: $0) }.flatMap { $0 }
}
