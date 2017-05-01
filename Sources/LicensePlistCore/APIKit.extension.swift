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
    public func response<T: Request>(_ request: T) -> Observable<T.Response> {
        return Observable.create { [weak base] observer in
            let task = base?.send(request) { result in
                switch result {
                case .success(let response):
                    observer.on(.next(response))
                    observer.on(.completed)
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create {
                task?.cancel()
            }
        }
    }
}

public extension URL {
    public func downloadContent() -> Observable<String> {
        return Observable.create { observer in
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    let result = try String(contentsOf: self)
                    observer.on(.next(result))
                    observer.on(.completed)
                } catch let e {
                    observer.on(.error(e))
                }
            }
            return Disposables.create()
        }
    }
}
