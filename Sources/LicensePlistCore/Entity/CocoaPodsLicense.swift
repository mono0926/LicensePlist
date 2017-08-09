import Foundation
import LoggerAPI
import Himotoki

public struct CocoaPodsLicense: License, Equatable {
    public let library: CocoaPods
    public let body: String

    public static func==(lhs: CocoaPodsLicense, rhs: CocoaPodsLicense) -> Bool {
        return lhs.library == rhs.library &&
            lhs.body == rhs.body
    }
}

extension CocoaPodsLicense: CustomStringConvertible {
    public var description: String {
        return "name: \(library.name), nameSpecified: \(nameSpecified ?? "")\nbody: \(String(body.characters.prefix(20)))…"
    }
}

extension CocoaPodsLicense {
    public static func load(_ content: String, versionInfo: VersionInfo, config: Config) -> [CocoaPodsLicense] {
        do {
            let plist = try PropertyListSerialization.propertyList(from: content.data(using: String.Encoding.utf8)!,
                                                                   options: [],
                                                                   format: nil)

            return try AcknowledgementsPlist.decodeValue(plist).preferenceSpecifiers
                .filter { $0.isLicense }
                .map {
                    let name = $0.title
                    return CocoaPodsLicense(library: CocoaPods(name: name,
                                                               nameSpecified: config.renames[name],
                                                               version: versionInfo.version(name: $0.title)),
                                            body: $0.footerText)
            }
        } catch let e {
            Log.error(String(describing: e))
            return []
        }
    }
}

private struct AcknowledgementsPlist {
    let preferenceSpecifiers: [PreferenceSpecifier]
}

extension AcknowledgementsPlist: Himotoki.Decodable {
    static func decode(_ e: Extractor) throws -> AcknowledgementsPlist {
        return try AcknowledgementsPlist(preferenceSpecifiers: e.array("PreferenceSpecifiers"))
    }
}

private struct PreferenceSpecifier {
    let footerText: String
    let title: String
    let type: String
    let license: String?
    var isLicense: Bool { return license != nil }
}

extension PreferenceSpecifier: Himotoki.Decodable {
    static func decode(_ e: Extractor) throws -> PreferenceSpecifier {
        return try PreferenceSpecifier(footerText: e.value("FooterText"),
                                       title: e.value("Title"),
                                       type: e.value("Type"),
                                       license: e.valueOptional("License"))
    }
}
