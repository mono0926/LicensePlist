import APIKit
import Foundation
import LoggerAPI

public struct CocoaPods: Library {
  public let name: String
  public let nameSpecified: String?
  public let version: String?
  public var source: String? { "https://cocoapods.org/pods/\(name)" }
  public let licenseType: LicenseType

  public init(
    name: String, nameSpecified: String?, version: String?, licenseType: LicenseType = .unknown
  ) {
    self.name = name
    self.nameSpecified = nameSpecified
    self.version = version
    self.licenseType = licenseType
  }
}

extension CocoaPods {
  public static func == (lhs: CocoaPods, rhs: CocoaPods) -> Bool {
    return lhs.name == rhs.name && lhs.nameSpecified == rhs.nameSpecified
      && lhs.version == rhs.version
  }
}
