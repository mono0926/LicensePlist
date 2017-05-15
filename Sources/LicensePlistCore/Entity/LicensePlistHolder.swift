import Foundation
import LoggerAPI

struct LicensePlistHolder {
    let root: Data
    let items: [(LicenseInfo, Data)]
    static func load(licenses: [LicenseInfo], config: Config) -> LicensePlistHolder {
        let rootItems: [[String: String]] = licenses.map { license in
            return ["Type": "PSChildPaneSpecifier",
                    "Title": license.name(withVersion: config.addVersionNumbers),
                    "File": "\(Consts.prefix)/\(license.name)"]
        }
        let root = try! PropertyListSerialization.data(fromPropertyList: ["PreferenceSpecifiers": rootItems],
                                                       format: .xml,
                                                       options: 0)
        let items: [(LicenseInfo, Data)] = licenses.map { license in
            let item = ["PreferenceSpecifiers": [["Type": "PSGroupSpecifier", "FooterText": license.body]]]
            let value = try! PropertyListSerialization.data(fromPropertyList: item, format: .xml, options: 0)
            return (license, value)
        }
        return LicensePlistHolder(root: root, items: items)
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
        // TODO: エラー
        try! root.write(to: rootPath)
        items.forEach {
            try! $0.1.write(to: itemsPath.appendingPathComponent("\($0.0.name).plist"))
        }

    }
}
