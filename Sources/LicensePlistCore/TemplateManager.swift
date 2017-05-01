import Foundation

class TemplateManager {
    private static let remotePathFormat = "https://raw.githubusercontent.com/mono0926/LicensePlist/master/Template/%@.plist"
    private static let licensePath = URL(string: String(format: remotePathFormat, "License"))!
    private static let licenseListPath = URL(string: String(format: remotePathFormat, "LicenseList"))!
    private static let licenseListItemPath = URL(string: String(format: remotePathFormat, "LicenseListItem"))!

    private init() {}
    static let shared = TemplateManager()
    private var _license: String?
    private var _licenseList: String?
    private var _licenseListItem: String?

    var license: String {
        if let r = _license {
            return r
        }
        let r = try! String(contentsOf: type(of: self).licensePath)
        _license = r
        return r
    }
    var licenseList: String {
        if let r = _licenseList {
            return r
        }
        let r = try! String(contentsOf: type(of: self).licenseListPath)
        _licenseList = r
        return r
    }
    var licenseListItem: String {
        if let r = _licenseListItem {
            return r
        }
        let r = try! String(contentsOf: type(of: self).licenseListItemPath)
        _licenseListItem = r
        return r
    }
}
