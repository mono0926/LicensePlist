import Foundation

public struct Extension<Base> {
    let base: Base
    init (_ base: Base) {
        self.base = base
    }
}

public protocol ExtensionCompatible {
    associatedtype Compatible
    static var lp: Extension<Compatible>.Type { get }
    var lp: Extension<Compatible> { get }
}

extension ExtensionCompatible {
    public static var lp: Extension<Self>.Type {
        return Extension<Self>.self
    }

    public var lp: Extension<Self> {
        return Extension(self)
    }
}
