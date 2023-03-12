import Foundation

public extension Optional where Wrapped == String {
    func asPathURL(in relativeURL: URL?, isDirectory: Bool = false) -> URL? {
        return map { URL(fileURLWithPath: $0, isDirectory: isDirectory, relativeTo: relativeURL) }
    }

    func asPathURL(other otherURL: URL?, default defaultPath: String, isDirectory: Bool = false) -> URL {
        return asPathURL(other: otherURL, isDirectory: isDirectory) ?? URL(fileURLWithPath: defaultPath, isDirectory: isDirectory)
    }

    func asPathURL(other otherURL: URL?, isDirectory: Bool = false) -> URL? {
        if let path = self {
            return URL(fileURLWithPath: path, isDirectory: isDirectory)
        }
        if let url = otherURL {
            return url
        }
        return nil
    }
}
