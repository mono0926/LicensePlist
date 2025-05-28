import Foundation
import APIKit
import LoggerAPI

extension Session: LicensePlistCompatible {}

extension LicensePlistExtension where Base: Session {
    func sendSync<T: Request>(_ request: T) -> Result<T.Response, SessionTaskError> {
        var result: Result<T.Response, SessionTaskError>!
        let semaphore = DispatchSemaphore(value: 0)
        self.base.send(request, callbackQueue: .sessionQueue) { _result in
            result = _result
            semaphore.signal()
        }
        semaphore.wait()
        return result
    }
    func send<T: Request>(_ request: T) -> ResultOperation<T.Response, SessionTaskError> {
        return ResultOperation<T.Response, SessionTaskError> { _ in
            return self.sendSync(request)
        }
    }

    static var gitHub: Session {
        Session(adapter: GitHubURLSessionAdapter(configuration: .default))
    }
}

final class GitHubURLSessionAdapter: URLSessionAdapter {
    // If the new request URL host matches the original request URL host, forward the Authorization HTTP header
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest? {
        guard let authorizationHTTPHeaderValue = task.originalRequest?.value(forHTTPHeaderField: "Authorization") else {
          return request
        }

        guard let originalRequestURLHost = task.originalRequest?.url?.host else {
          return request
        }

        guard let newRequestURLHost = request.url?.host else {
          return request
        }

        guard originalRequestURLHost == newRequestURLHost else {
          Log.debug("Not forwarding Authorization HTTP header because new request host is different: \(originalRequestURLHost) -> \(newRequestURLHost)")
          return request
        }

        var request = request
        request.setValue(authorizationHTTPHeaderValue, forHTTPHeaderField: "Authorization")
        Log.debug("Forwarding HTTP Authorization HTTP header")
        return request
    }
}
