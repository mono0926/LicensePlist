import Foundation

struct Shell {
    @discardableResult
    static func execute(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }

    @discardableResult
    static func open(_ path: String) -> Int32 {
        let r = execute("open", path)
        assert(r == 0)
        return r
    }
}
