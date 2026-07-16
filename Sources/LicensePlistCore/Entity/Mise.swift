import Foundation
import TOMLKit

enum Mise {
  private static let toolKeyRegex = try! NSRegularExpression(
    pattern: "^(?:github|ubi|aqua):([\\w\\.\\-]+)/([\\w\\.\\-]+)$", options: [])

  static func load(content: String?, renames: [String: String]) -> [GitHub] {
    guard let content = content, let table = try? TOMLTable(string: content) else { return [] }
    guard let tools = table["tools"]?.table else { return [] }

    return tools.compactMap { key, value -> GitHub? in
      let nsKey = key as NSString
      guard
        let match = toolKeyRegex.firstMatch(
          in: key, options: [], range: NSRange(location: 0, length: nsKey.length))
      else { return nil }
      let owner = nsKey.substring(with: match.range(at: 1))
      let name = nsKey.substring(with: match.range(at: 2))
      let version = value.string ?? value.table?["version"]?.string
      return GitHub(name: name, nameSpecified: renames[name], owner: owner, version: version)
    }
  }
}
