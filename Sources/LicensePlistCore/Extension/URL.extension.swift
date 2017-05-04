import Foundation
import Result

public extension URL {
    public func downloadContent() -> ResultOperation<String, NSError> {
        let operation =  ResultOperation<String, NSError> { _ in
            do {
                return Result.init(value: try String(contentsOf: self))
            } catch let e {
                return Result(error: e as NSError)
            }
        }
        return operation
    }
}
