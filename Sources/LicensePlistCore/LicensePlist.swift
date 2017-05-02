import Foundation
import LoggerAPI
import RxBlocking

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

        let cartfileName = "Cartfile"
        if let cartfilePath = cartfilePath, cartfilePath.lastPathComponent != cartfileName {
            fatalError("Invalid Cartfile name: \(cartfilePath.lastPathComponent)")
        }
        let cartfilePath = cartfilePath ?? URL(fileURLWithPath: cartfileName)
        let cartfileContent = { () -> String? in
            if let content = read(path: cartfilePath.appendingPathExtension("resolved")) {
                return content
            }
            return read(path: cartfilePath)
        }()
        if let cartfileContent = cartfileContent {
            carthageLibraries = carthageParser.parse(content: cartfileContent)
        }

        let podfileName = "Podfile"
        if let podfilePath = podfilePath, podfilePath.lastPathComponent != podfileName {
            fatalError("Invalid Podfile name: \(podfilePath.lastPathComponent)")
        }
        let podfilePath = podfilePath ?? URL(fileURLWithPath: podfileName)

        if let content = read(path: podfilePath.appendingPathExtension("lock")) {
            podLibraries = podfileParser.parse(content: content, kind: .lock)
        } else if let content = read(path: podfilePath) {
            podLibraries = podfileParser.parse(content: content, kind: .source)
        }

        let libraries = transformer.normalize(carthageLibraries, podLibraries)
        Log.info("License collect start")
        let licenses = try! licenseCollector.collect(with: libraries).toBlocking().toArray()
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

    private func read(path: URL) -> String? {
        do {
            return try String(contentsOf: path, encoding: encoding)
        } catch let e {
            Log.info(String(describing: e))
            return nil
        }
    }
}
