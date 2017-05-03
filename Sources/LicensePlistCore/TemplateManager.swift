import Foundation

class TemplateManager {
    private static let remotePathFormat = "https://raw.githubusercontent.com/mono0926/LicensePlist/master/Template/%@.plist"
    private static let licensePath = URL(string: String(format: remotePathFormat, "License"))!
    private static let licenseListPath = URL(string: String(format: remotePathFormat, "LicenseList"))!
    private static let licenseListItemPath = URL(string: String(format: remotePathFormat, "LicenseListItem"))!

    private init() {}
    static let shared = TemplateManager()
    private var _license: Template?
    private var _licenseList: Template?
    private var _licenseListItem: Template?

    var license: Template {
        if let r = _license {
            return r
        }
        let r = (try! String(contentsOf: type(of: self).licensePath)).template
        _license = r
        return r
    }
    var licenseList: Template {
        if let r = _licenseList {
            return r
        }
        let r = (try! String(contentsOf: type(of: self).licenseListPath)).template
        _licenseList = r
        return r
    }
    var licenseListItem: Template {
        if let r = _licenseListItem {
            return r
        }
        let r = (try! String(contentsOf: type(of: self).licenseListItemPath)).template
        _licenseListItem = r
        return r
    }
}

struct Template {
    let content: String
    init(content: String) {
        self.content = content
    }
    func applied(_ data: [String: String]) -> String {
        return data.reduce(content) { sum, e in
            return sum.replacingOccurrences(of: "{{.\(e.key)}}", with: e.value)
        }
    }
}

extension String {
    var template: Template { return Template(content: self) }
}
