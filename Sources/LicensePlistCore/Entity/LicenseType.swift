import Foundation

public enum LicenseType: String, CaseIterable {
    case agpl = "AGPL-3.0"
    case apache = "Apache-2.0"
    case bsd2 = "BSD-2-Clause"
    case bsd3 = "BSD-3-Clause"
    case bsl = "BSL-1.0"
    case cc0 = "CC0-1.0"
    case epl = "EPL-2.0"
    case gpl2 = "GPL-2.0"
    case gpl3 = "GPL-3.0"
    case isc = "ISC"
    case lgpl = "LGPL-2.1"
    case mit = "MIT"
    case mpl = "MPL-2.0"
    case unlicense = "Unlicense"
    case unknown
    case zlib = "Zlib"
}

extension LicenseType {

    init(id: String?) {
        self = Self(rawValue: id ?? "") ?? Self.allCases.first(where: { $0.rawValue.replacingOccurrences(of: "-", with: " ") == id }) ?? .unknown
    }
}
