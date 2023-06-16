import Foundation
import APIKit
import LoggerAPI
import Yams

public class Manual: Library {
    public let name: String
    public var body: String?    // Used as a container between YAML and ManualLicence
    public var source: String?
    public var nameSpecified: String?
    public var version: String?
    public let licenseType: LicenseType

    public init(name n: String, source: String?, nameSpecified: String?, version: String?, licenseType: LicenseType = .unknown) {
        self.name = n
        self.source = source
        self.nameSpecified = nameSpecified
        self.version = version
        self.licenseType = licenseType
    }
}

extension Manual {
    public static func==(lhs: Manual, rhs: Manual) -> Bool {
        return lhs.name == rhs.name &&
            lhs.nameSpecified == rhs.nameSpecified &&
            lhs.version == rhs.version &&
        lhs.source == rhs.source
    }
}

extension Manual: CustomStringConvertible {
    public var description: String {
        return "name: \(name), source: \(source ?? ""), nameSpecified: \(nameSpecified ?? ""), version: \(version ?? "")"
    }
}

extension Manual {
    public static func load(_ raw: Node.Sequence, renames: [String: String], configBasePath: URL) -> [Manual] {
        return raw.compactMap({
            let mapping = $0.mapping ?? Node.Mapping()
            let name = mapping["name"]?.string ?? ""
            let version = mapping["version"]?.string
            let source = mapping["source"]?.string

            var body: String?
            if let raw = mapping["body"]?.string {
                body = raw
            }

            if let file = mapping["file"]?.string {
                let url = configBasePath.appendingPathComponent(file)
                body = try! String(contentsOf: url)
            }

            let manual = Manual(name: name, source: source, nameSpecified: renames[name], version: version)
            manual.body = body  // This is so that we do not have to store a body at all ( for testing purposes mostly )
            return manual
        })
    }
}
