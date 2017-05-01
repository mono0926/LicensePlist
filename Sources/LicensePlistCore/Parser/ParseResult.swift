import Foundation

public struct Library {
    enum Source: Int {
        case
        podfile,
        cartfile
    }

    var priority: Int { return source.rawValue }

    let source: Source
    let name: String
    var owner: String?
}

extension Library: Equatable {
    public static func ==(lhs: Library, rhs: Library) -> Bool {
        return lhs.name == rhs.name && lhs.source == rhs.source && lhs.owner == rhs.owner
    }
}

extension Library: Hashable {
    public var hashValue: Int {
        return 17 + name.hash
    }
}

public struct License {
    let library: Library
    let license: LicenseResponse
    let body: String
}
