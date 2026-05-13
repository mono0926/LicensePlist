import Foundation

public extension Optional where Wrapped == String {
    func asPathURL() -> URL? {
        if let self = self {
            return URL(fileURLWithPath: self, isDirectory: true, relativeTo: nil)
        }
        return nil
    }
    
    func asPathURL(in relativeURL: URL?, isDirectory: Bool = false) -> URL? {
        return map { URL(fileURLWithPath: $0, isDirectory: isDirectory, relativeTo: relativeURL) }
    }

    func asPathURL(other otherURL: URL?, default defaultPath: String, isDirectory: Bool = false, relativeTo: URL?) -> URL {
        return asPathURL(other: otherURL, isDirectory: isDirectory, relativeTo: relativeTo) ?? URL(fileURLWithPath: defaultPath, isDirectory: isDirectory, relativeTo: relativeTo)
    }

    func asPathURL(other otherURL: URL?, isDirectory: Bool = false, relativeTo: URL?) -> URL? {
        if let path = self {
            return URL(fileURLWithPath: path, isDirectory: isDirectory, relativeTo: relativeTo)
        }
        if let url = otherURL {
            return url
        }
        return nil
    }
}
