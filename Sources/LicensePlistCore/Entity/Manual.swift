import Foundation
import APIKit
import LoggerAPI
import Yams

public struct Manual: Sendable, Library {
    public let name: String
    public let body: String?    // Used as a container between YAML and ManualLicence
    public let source: String?
    public var nameSpecified: String?
    public var version: String?
    public let licenseType: LicenseType

    public init(name n: String, body: String? = nil, source: String?, nameSpecified: String?, version: String?, licenseType: LicenseType = .unknown) {
        self.name = n
        self.body = body
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

            return Manual(name: name, body: body, source: source, nameSpecified: renames[name], version: version)
        })
    }
}
