import Foundation
import SWXMLHash

extension CocoaPodsLicense: Parser {
    public static func parse(_ content: String) -> [CocoaPodsLicense] {let xml = SWXMLHash.config { _ in }.parse(content)
        return xml["plist"]["dict"]["array"].children
            .map { e in
                var title: String?
                var license: String?
                var titleIndex: Int?
                var licenseIndex: Int?
                var isLicense = false
                e.children.map { $0.element?.text }.flatMap { $0 }.enumerated().forEach { (i, text) in
                    if text == "License" {
                        isLicense = true
                    }
                    if text == "Title" {
                        titleIndex = i + 1
                        return
                    }
                    if text == "FooterText" {
                        licenseIndex = i + 1
                        return
                    }
                    if i == titleIndex {
                        title = text
                    }
                    if i == licenseIndex {
                        license = text
                    }
                }
                if let title = title, let license = license, isLicense {
                    return CocoaPodsLicense(library: CocoaPods(name: title), body: license)
                }
                return nil
            }
            .flatMap { $0 }
    }
}
