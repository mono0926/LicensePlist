import Foundation
import LoggerAPI

struct PlistInfo {
    let options: Options
    var cocoaPodsLicenses: [CocoaPodsLicense]?
    var manualLicenses: [ManualLicense]?
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

        let versionPath = options.podsPath.appendingPathComponent("Manifest.lock")
        let podsVersionInfo = VersionInfo(podsManifest: versionPath.lp.read() ?? "")
        let licenses = acknowledgements
            .map { CocoaPodsLicense.load($0, versionInfo: podsVersionInfo, config: options.config) }
            .flatMap { $0 }
        let config = options.config
        cocoaPodsLicenses = config.filterExcluded(licenses).sorted()
    }

    mutating func loadGitHubLibraries(cartfile: String?) {
        Log.info("Carthage License collect start")
        githubLibraries  = options.config.apply(githubs: GitHub.load(cartfile ?? "", renames: options.config.renames)).sorted()
    }

    mutating func loadManualLibraries() {
        Log.info("Manual License start")
        manualLicenses = ManualLicense.load(options.config.manuals).sorted()
    }

    mutating func compareWithLatestSummary() {
        guard let cocoaPodsLicenses = cocoaPodsLicenses,
            let githubLibraries = githubLibraries,
            let manualLicenses = manualLicenses else { preconditionFailure() }

        let config = options.config

        let contents = (cocoaPodsLicenses.map { String(describing: $0) } +
            githubLibraries.map { String(describing: $0) } +
            manualLicenses.map { String(describing: $0) } +
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
        queue.maxConcurrentOperationCount = 10
        let carthageOperations = githubLibraries.map { GitHubLicense.download($0) }
        queue.addOperations(carthageOperations, waitUntilFinished: true)
        githubLicenses = carthageOperations.map { $0.result?.value }.flatMap { $0 }
    }

    mutating func collectLicenseInfos() {
        guard let cocoaPodsLicenses = cocoaPodsLicenses,
            let githubLicenses = githubLicenses,
            let manualLicenses = manualLicenses else { preconditionFailure() }

        licenses = ((cocoaPodsLicenses as [LicenseInfo]) + (githubLicenses as [LicenseInfo]) + (manualLicenses as [LicenseInfo]))
            .reduce([String: LicenseInfo]()) { sum, e in
                var sum = sum
                sum[e.name] = e
                return sum
            }.values
            .sorted { $0.name.lowercased() < $1.name.lowercased() }
    }

    func outputPlist() {
        guard let licenses = licenses else { preconditionFailure() }
        let outputPath = options.outputPath
        let itemsPath = outputPath.appendingPathComponent(Consts.prefix)
        if itemsPath.lp.deleteIfExits() {
            Log.info("Deleted exiting plist within \(Consts.prefix)")
        }
        itemsPath.lp.createDirectory()
        Log.info("Directory created: \(outputPath)")

        let holder = LicensePlistHolder.load(licenses: licenses, config: options.config)
        holder.write(to: outputPath.appendingPathComponent("\(Consts.prefix).plist"), itemsPath: itemsPath)
    }

    func reportMissings() {
        guard let githubLibraries = githubLibraries, let licenses = licenses else { preconditionFailure() }

        Log.info("----------Result-----------")
        Log.info("# Missing license:")
        let missing = Set(githubLibraries.map { $0.name }).subtracting(Set(licenses.map { $0.name }))
        if missing.isEmpty {
            Log.info("None 🎉")
        } else {
            Array(missing).sorted { $0 < $1 }.forEach { Log.warning($0) }
        }
    }

    func finish() {
        precondition(cocoaPodsLicenses != nil && githubLibraries != nil && githubLicenses != nil && licenses != nil)
        guard let summary = summary, let summaryPath = summaryPath else {
            fatalError("summary should be set")
        }
        do {
            try summary.write(to: summaryPath, atomically: true, encoding: Consts.encoding)
        } catch let e {
            Log.error("Failed to save summary. Error: \(String(describing: e))")
        }
    }
}
