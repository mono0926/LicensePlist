import Foundation
import LoggerAPI

public struct IOUtil {
    public static func read(path: URL) -> String? {
        let fm = FileManager.default
        if !fm.fileExists(atPath: path.path) {
            Log.warning("not found: \(path)")
            return nil
        }
        do {
            return try String(contentsOf: path, encoding: Consts.encoding)
        } catch let e {
            Log.warning(String(describing: e))
            return nil
        }
    }
}
