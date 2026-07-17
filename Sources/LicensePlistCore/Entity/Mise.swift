import TOMLKit

enum Mise {
  nonisolated(unsafe) private static let toolKeyRegex = /(?:github|ubi|aqua):([\w.-]+)\/([\w.-]+)/

  static func load(content: String?, renames: [String: String]) -> [GitHub] {
    guard let content, let table = try? TOMLTable(string: content) else { return [] }
    guard let tools = table["tools"]?.table else { return [] }

    return tools.compactMap { key, value -> GitHub? in
      guard let match = try? toolKeyRegex.wholeMatch(in: key) else { return nil }
      let (_, owner, name) = match.output
      let version = value.string ?? value.table?["version"]?.string
      return GitHub(
        name: String(name), nameSpecified: renames[String(name)], owner: String(owner),
        version: version)
    }
  }
}
