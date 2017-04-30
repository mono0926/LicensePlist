import Foundation
import APIKit
import Result

extension Session: ExtensionCompatible {}

extension Extension where Base: Session {
    func sendSync<T: Request>(_ request: T) -> Result<T.Response, SessionTaskError> {
        var result: Result<T.Response, SessionTaskError>!
        var isRunning = true
        let runLoop = RunLoop.current
        base.send(request) { _result in
            result = _result
            isRunning = false
        }
        while isRunning && runLoop.run(mode: .defaultRunLoopMode, before: Date(timeIntervalSinceNow: 0.1)) {}
        return result
    }
}
