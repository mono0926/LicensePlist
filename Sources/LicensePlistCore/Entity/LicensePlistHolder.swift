import Foundation
import LoggerAPI

struct LicensePlistHolder {
    let root: Data
    let items: [(LicenseInfo, Data)]
    static func load(licenses: [LicenseInfo], options: Options) -> LicensePlistHolder {
        let rootItems: [[String: String]] = {
            guard !licenses.isEmpty else { return [] }
            return [["Type": "PSGroupSpecifier", "Title": "Licenses"]] + licenses.map { license in
                return ["Type": "PSChildPaneSpecifier",
                        "Title": license.name(withVersion: options.config.addVersionNumbers),
                        "File": "\(options.prefix)/\(license.name)"]
            }
        }()
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
