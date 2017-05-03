import RxSwift

public protocol Collector: License {
    static func collect(_ library: Self.LibraryType) -> Maybe<Self>
}
