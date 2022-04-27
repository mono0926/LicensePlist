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
        cocoaPodsLicenses = config.filterExcluded(cocoaPodsLicenses: licenses).sorted()
    }

    mutating func loadGitHubLibraries(file: GitHubLibraryConfigFile) {
        switch file.type {
        case .carthage:
            Log.info("Carthage License collect start")
        case .mint:
            Log.info("Mint License collect start")
        case .licensePlist:
            // should not reach here
            preconditionFailure()
        }
        let githubs = GitHub.load(file, renames: options.config.renames)
        githubLibraries = ((githubLibraries ?? []) + options.config.apply(githubs: githubs)).sorted()
    }

    mutating func loadSwiftPackageLibraries(packageFiles: [String]) {
        Log.info("Swift Package Manager License collect start")

        let packages = packageFiles.flatMap { SwiftPackage.loadPackages($0) }
        let packagesAsGithubLibraries = packages.compactMap { $0.toGitHub(renames: options.config.renames) }.sorted()

        githubLibraries = (githubLibraries ?? []) + options.config.apply(githubs: packagesAsGithubLibraries)
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
        let savePath = options.outputPath.appendingPathComponent("\(options.prefix).latest_result.txt")
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
        githubLicenses = carthageOperations.map { operation in
            switch operation.result {
            case let .success(value):
                return value
            default:
                return nil
            }
        }.compactMap { $0 }
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
        let itemsPath = outputPath.appendingPathComponent(options.prefix)
        if itemsPath.lp.deleteIfExits() {
            Log.info("Deleted exiting plist within \(options.prefix)")
        }
        itemsPath.lp.createDirectory()
        Log.info("Directory created: \(outputPath)")

        let holder = options.config.singlePage ?
            LicensePlistHolder.loadAllToRoot(licenses: licenses, options: options) :
            LicensePlistHolder.load(licenses: licenses, options: options)
        holder.write(to: outputPath.appendingPathComponent("\(options.prefix).plist"), itemsPath: itemsPath)

        if let markdownPath = options.markdownPath {
            let markdownHolder = LicenseMarkdownHolder.load(licenses: licenses, options: options)
            markdownHolder.write(to: markdownPath)
        }

        if let htmlPath = options.htmlPath {
            let htmlHolder = LicenseHTMLHolder.load(licenses: licenses, options: options)
            htmlHolder.write(to: htmlPath)
        }
    }

    func reportMissings() {
        guard let githubLibraries = githubLibraries, let licenses = licenses else { preconditionFailure() }

        Log.info("----------Result-----------")
        Log.info("# Missing license:")
        let missing = Set(githubLibraries.map { $0.name }).subtracting(Set(licenses.map { $0.name }))
        if missing.isEmpty {
            Log.info("None 🎉")
            return
        }

        Array(missing).sorted { $0 < $1 }.forEach { Log.warning($0) }
        if options.config.failIfMissingLicense {
            exit(1)
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
