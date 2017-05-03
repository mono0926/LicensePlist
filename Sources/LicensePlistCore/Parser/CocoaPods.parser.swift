import Foundation
import SWXMLHash

extension CocoaPodsLicense: Parser {
    public static func parse(_ content: String) -> [CocoaPodsLicense] {
        return SWXMLHash.config { _ in }.parse(content)["plist"]["dict"]["array"].children
            .map { e in
                let elements = e.children.map { $0.element?.text }.flatMap { $0 }
                let dict = zip(elements, elements.dropFirst())
                    .reduce([String: String]()) { sum, e in
                        var sum = sum
                        sum[e.0] = e.1
                        return sum
                }
                if let title = dict["Title"], let license = dict["FooterText"], let _ = dict["License"] {
                    return CocoaPodsLicense(library: CocoaPods(name: title), body: license)
                }
                return nil
            }
            .flatMap { $0 }
    }
}
