import Foundation
import LoggerAPI
import Yams

public struct Exclude: Sendable {
  public let name: String?
  public let owner: String?
  public let source: String?
  public let licenseType: String?

  public init(
    name: String? = nil, owner: String? = nil, source: String? = nil, licenseType: String? = nil
  ) {
    self.name = name
    self.owner = owner
    self.source = source
    self.licenseType = licenseType
  }

  public init?(from yaml: Node) {
    if let name = yaml.string {
      self.init(name: name, owner: nil, source: nil, licenseType: nil)
      return
    }
    guard let dictionary = yaml.mapping else {
      Log.warning("Attempt to load exclude failed. Supported YAML types are String and Dictionary.")
      return nil
    }

    let name = dictionary["name"]?.string
    let owner = dictionary["owner"]?.string
    let source = dictionary["source"]?.string
    let licenseType = dictionary["licenseType"]?.string

    if name == nil && owner == nil && source == nil && licenseType == nil {
      Log.warning("Attempt to load exclude failed. At least one exclude matcher must be specified.")
      return nil
    }

    self.init(
      name: name,
      owner: owner,
      source: source,
      licenseType: licenseType)
  }
}

extension Exclude: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.name == rhs.name && lhs.owner == rhs.owner && lhs.source == rhs.source
      && lhs.licenseType == rhs.licenseType
  }
}
