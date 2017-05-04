import Foundation
import LoggerAPI

let prefix = "com.mono0926.LicensePlist"
private let encoding = String.Encoding.utf8
private var runWhenFinished: (() -> ())!
public final class LicensePlist {
    private var githubLibraries: [GitHub]?
    public init() {
        Logger.configure()
    }
    public func process(outputPath: URL? = nil,
                        cartfilePath: URL? = nil,
                        podsPath: URL? = nil,
                        gitHubToken: String? = nil,
                        configPath: URL? = nil,
                        force: Bool = false) {
        Log.info("Start")
        GitHubAuthorizatoin.shared.token = gitHubToken

        let outputRoot: URL
        if let outputPath = outputPath {
            outputRoot = outputPath
        } else {
            outputRoot = URL(fileURLWithPath: ".").appendingPathComponent("\(prefix).Output")
        }

        let config = loadConfig(configPath: configPath)

        let licenses = collectLicenseInfos(cartfilePath: cartfilePath,
                                           podsPath: podsPath,
                                           config: config,
                                           outputRoot: outputRoot,
                                           force: force)
        outputPlist(licenses: licenses, outputRoot: outputRoot)
        Log.info("End")
        reportMissings(licenses: licenses)
        runWhenFinished()
    }

    private func collectLicenseInfos(cartfilePath: URL?, podsPath: URL?, config: Config?, outputRoot: URL, force: Bool) -> [LicenseInfo] {
        Log.info("Pods License parse start")
        let excludes = config?.excludes ?? []

        let podsAcknowledgements = readPodsAcknowledgements(path: podsPath)
        let cocoaPodsLicenses = podsAcknowledgements.map { CocoaPodsLicense.parse($0) }.flatMap { $0 }.filter { cocoapods in
            if excludes.contains(cocoapods.name) {
                Log.warning("CocoaPods \(cocoapods.name) was excluded according to config yaml.")
                return false
            }
            return true
        }

        Log.info("Carthage License collect start")

        var gitHubLibraries: [GitHub] = config?.githubs ?? []
        gitHubLibraries.forEach { Log.warning("\($0.name) is loaded from config yaml.") }
        if let cartfileContent = readCartfile(path: cartfilePath) {
            gitHubLibraries += GitHub.parse(cartfileContent)
        }
        gitHubLibraries = gitHubLibraries.filter { github in
            if excludes.contains(github.name) {
                Log.warning("Carthage \(github.name) was excluded according to config yaml.")
                return false
            }
            return true
        }

        let contents = (cocoaPodsLicenses.map { String(describing: $0) } + gitHubLibraries.map { String(describing: $0) }).joined(separator: "\n\n")
        let savePath = outputRoot.appendingPathComponent(".license_plist")
        if let previous = read(path: savePath), previous == contents, !force {
            Log.warning("Completed because no diff. You can execute force by `--force` flag.")
            exit(0)
        }
        runWhenFinished = {
            try! contents.write(to: savePath, atomically: true, encoding: encoding)
        }

        let queue = OperationQueue()
        let carthageOperations = gitHubLibraries.map { GitHubLicense.collect($0) }
        queue.addOperations(carthageOperations, waitUntilFinished: true)
        let carthageLicenses = carthageOperations.map { $0.result?.value }.flatMap { $0 }
        self.githubLibraries = gitHubLibraries

        return Array(((cocoaPodsLicenses as [LicenseInfo]) + (carthageLicenses as [LicenseInfo]))
            .reduce([String: LicenseInfo]()) { sum, e in
                var sum = sum
                sum[e.name] = e
                return sum
            }.values
            .sorted { $0.name.lowercased() < $1.name.lowercased() })
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

private func loadConfig(configPath: URL?) -> Config? {
    let configPath = configPath ?? URL(string: "license_plist.yml")
    if let configPath = configPath, let yaml = read(path: configPath) {
        return ConfigLoader.shared.load(yaml: yaml)
    }
    return nil
}

private func outputPlist(licenses: [LicenseInfo], outputRoot: URL) {

    let tm = TemplateManager.shared

    let fm = FileManager.default
    let plistPath = outputRoot.appendingPathComponent(prefix)
    if fm.fileExists(atPath: plistPath.path) {
        try! fm.removeItem(at: plistPath)
        Log.info("Deleted exiting plist within \(prefix)")
    }
    try! fm.createDirectory(at: plistPath, withIntermediateDirectories: true, attributes: nil)
    Log.info("Directory created: \(outputRoot)")

    let licensListItems = licenses.map {
        return tm.licenseListItem.applied(["Title": $0.name,
                                           "FileName": "\(prefix)/\($0.name)"])
    }
    let licenseListPlist = tm.licenseList.applied(["Item": licensListItems.joined(separator: "\n")])
    write(content: licenseListPlist, to: outputRoot.appendingPathComponent("\(prefix).plist"))

    licenses.forEach {
        write(content: tm.license.applied(["Body": $0.body]),
              to: plistPath.appendingPathComponent("\($0.name).plist"))
    }
}

private func write(content: String, to path: URL) {
    try! content.write(to: path, atomically: false, encoding: encoding)
}

private func read(path: URL) -> String? {
    let fm = FileManager.default
    if !fm.fileExists(atPath: path.path) {
        Log.warning("not found: \(path)")
        return nil
    }
    do {
        return try String(contentsOf: path, encoding: encoding)
    } catch let e {
        Log.warning(String(describing: e))
        return nil
    }
}

private func readCartfile(path: URL?) -> String? {
    let cartfileName = "Cartfile"
    if let path = path, path.lastPathComponent != cartfileName {
        fatalError("Invalid Cartfile name: \(path.lastPathComponent)")
    }
    let path = path ?? URL(fileURLWithPath: cartfileName)
    if let content = read(path: path.appendingPathExtension("resolved")) {
        return content
    }
    return read(path: path)
}
private func readPodsAcknowledgements(path: URL?) -> [String] {
    let podsDirectoryName = "Pods"
    if let path = path, path.lastPathComponent != podsDirectoryName {
        fatalError("Invalid Pods name: \(path.lastPathComponent)")
    }
    let path = (path ?? URL(fileURLWithPath: podsDirectoryName)).appendingPathComponent("Target Support Files")
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
    return urls.map { read(path: $0) }.flatMap { $0 }
}
