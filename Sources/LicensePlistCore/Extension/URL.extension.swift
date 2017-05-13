import Foundation
import Result

extension URL: ExtensionCompatible {}

extension Extension where Base == URL {
    func downloadContent() -> ResultOperation<String, NSError> {
        let operation =  ResultOperation<String, NSError> { _ in
            do {
                return Result(value: try String(contentsOf: self.base))
            } catch let e {
                return Result(error: e as NSError)
            }
        }
        return operation
    }
}
