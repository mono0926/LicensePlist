import Foundation
import RxSwift
import APIKit
import LoggerAPI

public protocol License {
    associatedtype LibraryType: Library
    var library: LibraryType { get }
    var body: String { get }
}

public struct CarthageLicense: License {
    public let library: Carthage
    public let body: String
    let githubResponse: LicenseResponse
}

public struct CocoaPodsLicense: License {
    public let library: CocoaPods
    public let body: String
}
