import Foundation

struct Extension<Base> {
    let base: Base
    init (_ base: Base) {
        self.base = base
    }
}

protocol ExtensionCompatible {
    associatedtype Compatible
    static var lp: Extension<Compatible>.Type { get }
    var lp: Extension<Compatible> { get }
}

extension ExtensionCompatible {
    static var lp: Extension<Self>.Type {
        return Extension<Self>.self
    }

    var lp: Extension<Self> {
        return Extension(self)
    }
}
