import Foundation
import APIKit
import LoggerAPI
import Yaml

public class Manual: Library {
    public let name: String
    public var body: String?    // Used as a container between YAML and ManualLicence
    public var source: String?
    public var nameSpecified: String?
    public var version: String?

    init(name n: String, source: String?, nameSpecified: String?, version: String?) {
        self.name = n
        self.source = source
        self.nameSpecified = nameSpecified
        self.version = version
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
    public static func load(_ raw: [Yaml],
                            renames: [String: String]) -> [Manual] {
        return raw.map { (manualEntry) -> Manual in
            var name = ""
            var body: String?
            var source: String?
            var version: String?
            for valuePair in manualEntry.dictionary ?? [:] {
                switch valuePair.key.string ?? "" {
                case "source":
                    source = valuePair.value.string
                case "name":
                    name = valuePair.value.string ?? ""
                case "version":
                    version = valuePair.value.string
                case "body":
                    body = valuePair.value.string
                default:
                    Log.warning("Tried to parse an unknown YAML key")
                }
            }
            let manual = Manual(name: name, source: source, nameSpecified: renames[name], version: version)
            manual.body = body  // This is so that we do not have to store a body at all ( for testing purposes mostly )
            return manual
        }
    }
}
