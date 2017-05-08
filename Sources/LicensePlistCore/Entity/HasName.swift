import LoggerAPI

public protocol HasName {
    var name: String { get }
}

extension Array where Element: HasName {
    func filterExcluded(config: Config?) -> [Element] {
        return filter {
            let name = $0.name
            guard let config = config else { return true }
            let result = !config.excluded(name: name)
            if !result {
                Log.warning("\(type(of: self))'s \(name) was excluded according to config yaml.")
            }
            return result
        }
    }
}
