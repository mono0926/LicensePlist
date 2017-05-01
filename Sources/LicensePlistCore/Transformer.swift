import Foundation

public protocol TransformerProtocol {
    func normalize(_ source: [Library]...) -> [Library]
}

class Transformer: TransformerProtocol {

    func normalize(_ sources: [Library]...) -> [Library] {
        return sources.reversed().flatMap { $0 }.reduce([String: Library]()) { sum, e in
            if let existing = sum[e.name] {
                if existing.priority > e.priority {
                    return sum
                }
            }
            var sum = sum
            sum[e.name] = e
            return sum
        }
            .values.sorted { $0.name < $1.name }
    }
}
