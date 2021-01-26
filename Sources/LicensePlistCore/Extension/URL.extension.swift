import Foundation
import LoggerAPI

extension URL: LicensePlistCompatible {}

extension LicensePlistExtension where Base == URL {
    func download() -> ResultOperation<String, Error> {
        let operation = ResultOperation<String, Error> { _ in
            do {
                return Result(catching: {
                    try String(contentsOf: self.base)
                })
            }
        }
        return operation
    }
}

private let fm = FileManager.default
public extension LicensePlistExtension where Base == URL {
    var isExists: Bool { return fm.fileExists(atPath: base.path) }

    var isDirectory: Bool {
        var result: ObjCBool = false
        fm.fileExists(atPath: base.path, isDirectory: &result)
        return result.boolValue
    }

    func read() -> String? {
        if !isExists {
            Log.warning("Not found: \(base).")
            return nil
        }
        return getResultOrDefault {
            try String(contentsOf: base, encoding: Consts.encoding)
        }
    }

    func write(content: String) {
        return run {
            try content.write(to: base, atomically: false, encoding: Consts.encoding)
        }
    }

    func deleteIfExits() -> Bool {
        if !isExists {
            return false
        }
        return getResultOrDefault {
            try fm.removeItem(at: base)
            return true
        }
    }

    func createDirectory(withIntermediateDirectories: Bool = true) {
        return run {
            try fm.createDirectory(at: base,
                                   withIntermediateDirectories: withIntermediateDirectories,
                                   attributes: nil)
        }
    }

    func listDir() -> [URL] {
        return getResultOrDefault {
            try fm.contentsOfDirectory(at: base, includingPropertiesForKeys: nil, options: [])
        }
    }

    private func getResultOrDefault<T: HasDefaultValue>(closure: () throws -> T) -> T {
        do {
            return try closure()
        } catch let e {
            handle(error: e)
            return T.default
        }
    }

    private func run(closure: () throws -> Void) {
        do {
            try closure()
        } catch let e {
            handle(error: e)
        }
    }

    private func handle(error: Error) {
        let message = String(describing: error)
        assertionFailure(message)
        Log.error(message)
    }
}

protocol HasDefaultValue {
    static var `default`: Self { get }
}

extension Bool: HasDefaultValue {
    static var `default`: Bool { return false }
}

extension Array: HasDefaultValue {
    static var `default`: [Element] { return [] }
}

extension Optional: HasDefaultValue {
    static var `default`: Wrapped? { return nil }
}
