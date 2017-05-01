import Foundation
import LoggerAPI

public final class LicensePlist {
    let encoding = String.Encoding.utf8
    private let carthageParser: CartfileParserProtocol
    private let podfileParser: PodfileParserProtocol
    private let transformer: TransformerProtocol
    private let licenseCollector: LicenseCollectorProtocol
    public init(carthageParser: CartfileParserProtocol = CartfileParser(),
                podfileParser: PodfileParserProtocol = PodfileParser(),
                transformer: TransformerProtocol = Transformer(),
                licenseCollector: LicenseCollectorProtocol = LicenseCollector()) {
        self.carthageParser = carthageParser
        self.podfileParser = podfileParser
        self.transformer = transformer
        self.licenseCollector = licenseCollector
        Logger.configure()
    }
    public func process(outputPath: URL? = nil,
                        cartfilePath: URL? = nil,
                        podfilePath: URL? = nil,
                        gitHubToken: String? = nil) {
        Log.info("Start")

        GitHubAuthorizatoin.shared.token = gitHubToken

        var carthageLibraries = [Library]()
        var podLibraries = [Library]()

        let cartfileContent = try! String(contentsOf: cartfilePath ?? URL(fileURLWithPath: "Cartfile"),
                                          encoding: encoding)
        carthageLibraries = carthageParser.parse(content: cartfileContent)

        let podfileContent = try! String(contentsOf: podfilePath ?? URL(fileURLWithPath: "Podfile"),
                                         encoding: encoding)
        podLibraries = podfileParser.parse(content: podfileContent)

        let libraries = transformer.normalize(carthageLibraries, podLibraries)
        Log.info("License collect start")
        let licenses = licenseCollector.collect(with: libraries).result()
        let tm = TemplateManager.shared
        let prefix = "com.mono0926.LicensePlist."
        let licensListItems = licenses.map { license in
            return tm.licenseListItem.applied(["Title": license.library.name,
                                               "FileName": "\(prefix)\(license.library.name)"])
        }

        let outputRoot: URL
        if let outputPath = outputPath {
            outputRoot = outputPath
        } else {
            outputRoot = URL(fileURLWithPath: ".").appendingPathComponent("\(prefix)Output")
            let fm = FileManager.default
            do {
                try fm.createDirectory(at: outputRoot, withIntermediateDirectories: false, attributes: nil)
                Log.info("Directory created: \(outputRoot)")
            } catch {
                Log.info("Directory existed: \(outputRoot)")
                for f in (try! fm.contentsOfDirectory(at: outputRoot, includingPropertiesForKeys: nil, options: [])) where f.lastPathComponent.hasPrefix(prefix) {
                    try! fm.removeItem(at: f)
                }
                Log.info("Deleted exiting plist starting with \(prefix)")
            }
        }
        let licenseListPlist = tm.licenseList.applied(["Item": licensListItems.joined(separator: "\n")])
        write(content: licenseListPlist, to: outputRoot.appendingPathComponent("\(prefix)LisenseList.plist"))
        licenses.forEach { license in
            let plist = tm.license.applied(["Body": license.body])
            write(content: plist, to: outputRoot.appendingPathComponent("\(prefix)\(license.library.name).plist"))
        }
        Log.info("End")
        Log.info("----------Result-----------")
        Log.info("# Missing license:")
        let missing = Set(libraries.map { $0.name }).subtracting(Set(licenses.map { $0.library.name }))
        if missing.isEmpty {
            Log.info("None🎉")
        }  else {
            Array(missing).sorted { $0 < $1 }.forEach { Log.error($0) }
        }
    }

    private func write(content: String, to path: URL) {
        try! content.write(to: path, atomically: false, encoding: encoding)
    }
}
