import Foundation
import LoggerAPI
import RxBlocking
import RxSwift

public final class LicensePlist {
    let encoding = String.Encoding.utf8
    public init() {
        Logger.configure()
    }
    public func process(outputPath: URL? = nil,
                        cartfilePath: URL? = nil,
                        podsPath: URL? = nil,
                        gitHubToken: String? = nil) {
        Log.info("Start")

        GitHubAuthorizatoin.shared.token = gitHubToken

        Log.info("Pods License parse start")
        let podsAcknowledgements = readPodsAcknowledgements(path: podsPath)
        let cocoaPodsLicenses = podsAcknowledgements.map { CocoaPodsLicense.parse($0) }.flatMap { $0 }

        Log.info("Carthage License collect start")

        var carthageLibraries = [Carthage]()
        if let cartfileContent = readCartfile(path: cartfilePath) {
            carthageLibraries = Carthage.parse(cartfileContent)
        }
        let carthageLicenses = try! Observable.merge(carthageLibraries.map { CarthageLicense.collect($0).asObservable() }).toBlocking().toArray()
        let tm = TemplateManager.shared
        let prefix = "com.mono0926.LicensePlist"
        let licenseNames = Set(carthageLicenses.map { $0.library.name } + cocoaPodsLicenses.map { $0.library.name })
        let licensListItems = licenseNames.sorted { $0 < $1 }.map {
            return tm.licenseListItem.applied(["Title": $0,
                                               "FileName": "\(prefix)/\($0)"])
            }

        // TODO: refactor
        let outputRoot: URL
        if let outputPath = outputPath {
            outputRoot = outputPath
        } else {
            outputRoot = URL(fileURLWithPath: ".").appendingPathComponent("\(prefix)Output")
        }

        let fm = FileManager.default
        let plistPath = outputRoot.appendingPathComponent(prefix)
        if fm.fileExists(atPath: plistPath.path) {
            try! fm.removeItem(at: plistPath)
            Log.info("Deleted exiting plist within \(prefix)")
        }
        try! fm.createDirectory(at: plistPath, withIntermediateDirectories: true, attributes: nil)
        Log.info("Directory created: \(outputRoot)")

        let licenseListPlist = tm.licenseList.applied(["Item": licensListItems.joined(separator: "\n")])
        write(content: licenseListPlist, to: outputRoot.appendingPathComponent("\(prefix).LisenseList.plist"))

        let bodies = cocoaPodsLicenses.map { ($0.library.name, $0.body) } + carthageLicenses.map { ($0.library.name, $0.body) }
            .reduce([String: String]()) { sum, e in
                var sum = sum
                sum[e.0] = e.1
                return sum
        }
        bodies.forEach {
            write(content: tm.license.applied(["Body": $0.value]),
                  to: plistPath.appendingPathComponent("\($0.key).plist"))
        }

        Log.info("End")
        Log.info("----------Result-----------")
        Log.info("# Missing license:")
        let missing = Set(carthageLibraries.map { $0.name }).subtracting(Set(carthageLicenses.map { $0.library.name }))
        if missing.isEmpty {
            Log.info("None🎉")
        }  else {
            Array(missing).sorted { $0 < $1 }.forEach { Log.warning($0) }
        }
    }

    private func write(content: String, to path: URL) {
        try! content.write(to: path, atomically: false, encoding: encoding)
    }

    private func read(path: URL) -> String? {
        do {
            return try String(contentsOf: path, encoding: encoding)
        } catch let e {
            Log.info(String(describing: e))
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
}
