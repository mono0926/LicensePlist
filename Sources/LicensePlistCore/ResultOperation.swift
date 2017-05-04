import Foundation
import Result
import LoggerAPI

public class ResultOperation<T, E: Error>: Operation {
    typealias ResultType = Result<T, E>
    var result: ResultType?
    let closure: ((ResultOperation) -> ResultType)
    init(_ closure: @escaping ((ResultOperation) -> ResultType)) {
        self.closure = closure
    }
    public override func main() {
        if isCancelled {
            Log.debug("canncelled")
            return
        }
        result = closure(self)
    }
    func blocking() -> Self {
        if isFinished {
            return self
        }
        let queue = OperationQueue()
        queue.addOperations([self], waitUntilFinished: true)
        return self
    }
}
