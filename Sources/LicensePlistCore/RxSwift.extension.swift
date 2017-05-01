import Foundation
import RxSwift
import RxCocoa
import APIKit

extension Observable {
    func result() -> [Element] {
        var r = [Element]()
        var finished = false
        _ = subscribe { event in
            switch event {
            case .error(let error):
                // TODO:
                assert(false, String(describing: error))
                finished = true
            case .next(let e):
                r.append(e)
            case .completed:
                finished = true
            }
        }
        while !finished && RunLoop.current.run(mode: .defaultRunLoopMode, before: Date(timeIntervalSinceNow: 0.1))  {}
        return r
    }
}
