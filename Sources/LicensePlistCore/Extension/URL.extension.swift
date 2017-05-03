import Foundation
import RxSwift

public extension URL {
    public func downloadContent() -> Single<String> {
        return Single.create { observer in
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    let result = try String(contentsOf: self)
                    observer(.success(result))
                } catch let e {
                    observer(.error(e))
                }
            }
            return Disposables.create()
        }
    }
}
