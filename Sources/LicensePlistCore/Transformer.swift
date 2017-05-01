import Foundation

protocol TransformerProtocol {
    func normalize(_ source: [LibraryName]...) -> [LibraryName]
}

class Transformer: TransformerProtocol {

    func normalize(_ sources: [LibraryName]...) -> [LibraryName] {
        return sources.reversed().flatMap { $0 }.reduce([String: LibraryName]()) { sum, e in
            if let existing = sum[e.repoName] {
                if case .gitHub = existing, case .name = e {
                    return sum
                }
            }
            var sum = sum
            sum[e.repoName] = e
            return sum
        }
            .values.sorted { $0.repoName < $1.repoName }
    }
}
