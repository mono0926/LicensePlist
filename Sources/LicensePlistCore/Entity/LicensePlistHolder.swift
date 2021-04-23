import Foundation
import LoggerAPI

struct LicensePlistHolder {
    let root: Data
    let items: [(LicenseInfo, Data)]
    static func load(licenses: [LicenseInfo], options: Options) -> LicensePlistHolder {
        let rootItems: [[String: String]] = {
            guard !licenses.isEmpty else { return [] }
            return [["Type": "PSGroupSpecifier", "Title": "Licenses"]] + licenses.map { license in
                ["Type": "PSChildPaneSpecifier",
                 "Title": license.name(withVersion: options.config.addVersionNumbers),
                 "File": "\(options.prefix)/\(license.name)"]
            }
        }()
        let root = try! PropertyListSerialization.data(fromPropertyList: ["PreferenceSpecifiers": rootItems],
                                                       format: .xml,
                                                       options: 0)
        let items: [(LicenseInfo, Data)] = licenses.map { license in
            let lineRegex = try! NSRegularExpression(pattern: "^\\s*[-_*=]{3,}\\s*$", options: [])
            let item = ["PreferenceSpecifiers":
                license.body
                .components(separatedBy: "\n\n")
                .split(whereSeparator: { (possibleHorizontalLine) -> Bool in
                    lineRegex.firstMatch(in: possibleHorizontalLine, options: [], range: NSRange(location: 0, length: possibleHorizontalLine.count)) != nil
                })
                .map { parts in
                    [parts.joined(separator: "\n\n")]
                }
                .joined(separator: [String(repeating: "-", count: 40)])
                .map { (paragraph) -> [String: String] in
                    ["Type": "PSGroupSpecifier", "FooterText": paragraph]
                }]
            let value = try! PropertyListSerialization.data(fromPropertyList: item, format: .xml, options: 0)
            return (license, value)
        }
        return LicensePlistHolder(root: root, items: items)
    }

    static func loadAllToRoot(licenses: [LicenseInfo]) -> LicensePlistHolder {
        let rootItem: [[String: String]] = {
            guard !licenses.isEmpty else { return [] }
            let body = licenses
                .compactMap { lincense in
                    ["Type": "PSGroupSpecifier",
                     "Title": lincense.name,
                     "FooterText": lincense.body]
                }
            return body
        }()
        let root = try! PropertyListSerialization.data(fromPropertyList: ["PreferenceSpecifiers": rootItem],
                                                       format: .xml,
                                                       options: 0)
        return LicensePlistHolder(root: root, items: [])
    }

    func deserialized() -> (root: [String: [[String: String]]], items: [(LicenseInfo, [String: [[String: String]]])]) {
        let root = try! PropertyListSerialization.propertyList(from: self.root, options: [], format: nil) as! [String: [[String: String]]]
        let items: [(LicenseInfo, [String: [[String: String]]])] = self.items.map { license, data in
            let value = try! PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: [[String: String]]]
            return (license, value)
        }
        return (root: root, items: items)
    }

    func write(to rootPath: URL, itemsPath: URL) {
        do {
            try root.write(to: rootPath)
            try items.forEach {
                try $0.1.write(to: itemsPath.appendingPathComponent("\($0.0.name).plist"))
            }
        } catch let e {
            Log.error("Failed to write to (rootPath: \(rootPath), itemsPath: \(itemsPath)).\nerror: \(e)")
        }
    }
}
