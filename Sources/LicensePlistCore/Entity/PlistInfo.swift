import Foundation
import LoggerAPI

struct PlistInfo {
    let options: Options
    var cocoaPodsLicenses: [CocoaPodsLicense]?
    var githubLibraries: [GitHub]?
    var githubLicenses: [GitHubLicense]?
    var summary: String?
    var summaryPath: URL?
    var licenses: [LicenseInfo]?

    init(options: Options) {
        self.options = options
    }

    mutating func loadCocoaPodsLicense(acknowledgements: [String]) {
        guard cocoaPodsLicenses == nil else { preconditionFailure() }
        Log.info("Pods License parse start")

        let path = options.podsPath.appendingPathComponent("Manifest.lock")
        let podsVersionInfo = VersionInfo(podsManifest: path.lp.read() ?? "")
        let licenses = acknowledgements
            .map { CocoaPodsLicense.load($0, versionInfo: podsVersionInfo, config: options.config) }
            .flatMap { $0 }
        let config = options.config
        cocoaPodsLicenses = config.filterExcluded(licenses)
    }

    mutating func loadGitHubLibraries(cartfile: String?) {
        Log.info("Carthage License collect start")
        githubLibraries  = options.config.apply(githubs: GitHub.load(cartfile ?? "", renames: options.config.renames))
    }

    mutating func compareWithLatestSummary() {
        guard let cocoaPodsLicenses = cocoaPodsLicenses, let githubLibraries = githubLibraries else { preconditionFailure() }

        let config = options.config

        let contents = (cocoaPodsLicenses.map { String(describing: $0) } +
            githubLibraries.map { String(describing: $0) } +
            ["add-version-numbers: \(options.config.addVersionNumbers)", "LicensePlist Version: \(Consts.version)"])
            .joined(separator: "\n\n")
        let savePath = options.outputPath.appendingPathComponent("\(Consts.prefix).latest_result.txt")
        if let previous = savePath.lp.read(), previous == contents, !config.force {
            Log.warning("Completed because no diff. You can execute force by `--force` flag.")
            exit(0)
        }
        summary = contents
        summaryPath = savePath
    }

    mutating func downloadGitHubLicenses() {
        guard let githubLibraries = githubLibraries else { preconditionFailure() }

        let queue = OperationQueue()
        let carthageOperations = githubLibraries.map { GitHubLicense.download($0) }
        queue.addOperations(carthageOperations, waitUntilFinished: true)
        githubLicenses = carthageOperations.map { $0.result?.value }.flatMap { $0 }
    }

    mutating func collectLicenseInfos() {
        guard let cocoaPodsLicenses = cocoaPodsLicenses, let githubLicenses = githubLicenses else { preconditionFailure() }

        licenses = ((cocoaPodsLicenses as [LicenseInfo]) + (githubLicenses as [LicenseInfo]))
            .reduce([String: LicenseInfo]()) { sum, e in
                var sum = sum
                sum[e.name] = e
                return sum
            }.values
            .sorted { $0.name.lowercased() < $1.name.lowercased() }
    }

    func outputPlist() {
        guard let licenses = licenses else { preconditionFailure() }

        let tm = TemplateManager.shared

        let outputPath = options.outputPath
        let plistPath = outputPath.appendingPathComponent(Consts.prefix)
        if plistPath.lp.deleteIfExits() {
            Log.info("Deleted exiting plist within \(Consts.prefix)")
        }
        plistPath.lp.createDirectory()
        Log.info("Directory created: \(outputPath)")

        let licensListItems = licenses.map {
            return tm.licenseListItem.applied(["Title": $0.name(withVersion: options.config.addVersionNumbers),
                                               "FileName": "\(Consts.prefix)/\($0.name)"])
        }
        let licenseListPlist = tm.licenseList.applied(["Item": licensListItems.joined(separator: "\n")])
        outputPath.appendingPathComponent("\(Consts.prefix).plist").lp.write(content: licenseListPlist)

        licenses.forEach {
            plistPath.appendingPathComponent("\($0.name).plist")
                .lp.write(content: tm.license.applied(["Body": $0.bodyEscaped]))
        }
    }

    func reportMissings() {
        guard let githubLibraries = githubLibraries, let licenses = licenses else { preconditionFailure() }

        Log.info("----------Result-----------")
        Log.info("# Missing license:")
        let missing = Set(githubLibraries.map { $0.name }).subtracting(Set(licenses.map { $0.name }))
        if missing.isEmpty {
            Log.info("None🎉")
        } else {
            Array(missing).sorted { $0 < $1 }.forEach { Log.warning($0) }
        }
    }

    func finish() {
        precondition(cocoaPodsLicenses != nil && githubLibraries != nil && githubLicenses != nil)
        guard let summary = summary, let summaryPath = summaryPath else {
            fatalError("summary should be set")
        }
        try! summary.write(to: summaryPath, atomically: true, encoding: Consts.encoding)
    }
}
