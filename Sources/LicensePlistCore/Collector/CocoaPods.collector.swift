import RxSwift

extension CocoaPodsLicense: Collector {
    public static func collect(_ library: CocoaPods) -> Maybe<CocoaPodsLicense> {
        return Maybe.empty()
    }
}
