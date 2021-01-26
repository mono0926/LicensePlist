import Foundation
import LoggerAPI

public struct CocoaPodsLicense: License, Equatable {
    public let library: CocoaPods
    public let body: String

    public static func== (lhs: CocoaPodsLicense, rhs: CocoaPodsLicense) -> Bool {
        return lhs.library == rhs.library &&
            lhs.body == rhs.body
    }
}

extension CocoaPodsLicense: CustomStringConvertible {
    public var description: String {
        return "name: \(library.name), nameSpecified: \(nameSpecified ?? "")\nbody: \(String(body.prefix(20)))…\nversion: \(version ?? "")"
    }
}

public extension CocoaPodsLicense {
    static func load(_ content: String, versionInfo: VersionInfo, config: Config) -> [CocoaPodsLicense] {
        do {
            let plistData = content.data(using: .utf8)!
            let plistDecoder = PropertyListDecoder()

            return try plistDecoder.decode(AcknowledgementsPlist.self, from: plistData).preferenceSpecifiers
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

private struct AcknowledgementsPlist: Decodable {
    enum CodingKeys: String, CodingKey {
        case preferenceSpecifiers = "PreferenceSpecifiers"
    }

    let preferenceSpecifiers: [PreferenceSpecifier]
}

private struct PreferenceSpecifier: Decodable {
    enum CodingKeys: String, CodingKey {
        case footerText = "FooterText"
        case title = "Title"
        case type = "Type"
        case license = "License"
    }

    let footerText: String
    let title: String
    let type: String
    let license: String?
    var isLicense: Bool { return license != nil }
}
