import Foundation

public struct LicensePlistExtension<Base> {
    let base: Base
    init (_ base: Base) {
        self.base = base
    }
}

public protocol LicensePlistCompatible {
    associatedtype Compatible
    static var lp: LicensePlistExtension<Compatible>.Type { get }
    var lp: LicensePlistExtension<Compatible> { get }
}

extension LicensePlistCompatible {
    public static var lp: LicensePlistExtension<Self>.Type {
        return LicensePlistExtension<Self>.self
    }

    public var lp: LicensePlistExtension<Self> {
        return LicensePlistExtension(self)
    }
}
