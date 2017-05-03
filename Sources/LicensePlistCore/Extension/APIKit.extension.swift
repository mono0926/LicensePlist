import Foundation
import APIKit
import Result
import RxSwift

extension Session: ExtensionCompatible {}

extension Extension where Base: Session {
    func sendSync<T: Request>(_ request: T) -> Result<T.Response, SessionTaskError> {
        var result: Result<T.Response, SessionTaskError>!
        let semaphor = DispatchSemaphore(value: 0)
        self.base.send(request, callbackQueue: .sessionQueue) { _result in
            result = _result
            semaphor.signal()
        }
        semaphor.wait()
        return result
    }
}

extension Session: ReactiveCompatible {}

public extension Reactive where Base: Session {
    public func response<T: Request>(_ request: T) -> Single<T.Response> {
        return Single.create { [weak base] observer in
            let task = base?.send(request) { result in
                switch result {
                case .success(let response):
                    observer(.success(response))
                case .failure(let error):
                    observer(.error(error))
                }
            }
            return Disposables.create {
                task?.cancel()
            }
        }
    }
}
