import Foundation
import RxSwift
import APIKit
import LoggerAPI

// TODO: set license url
public protocol LicenseCollectorProtocol {
}

class LicenseCollector: LicenseCollectorProtocol {

//    func collect<T>(with library: T) -> Maybe<License<T>> where T: Library {
//        let name = library.name
//        if let library = library as? CocoaPods {
//            return Session.shared.rx.response(SearchRequests.Repositories(query: name))
//                .asObservable()
//                .asMaybe()
//                .flatMap { response -> Maybe<License<T>> in
//                    if let first = response.items.first, first.name == name {
//                        var library = library
//                        library.owner = first.owner.login
//                        return self.collect(with: library)
//                    } else {
//                        Log.warning("\(name) not found on GitHub")
//                        return Maybe.empty()
//                    }
//            }
//        }
//        fatalError("only support Carthage and CocoaPods")
//    }
//    func collect<T>(with libraries: [T]) -> Observable<License<T>> where T: Library {
//        let observables = libraries.map { self.collect(with: $0).asObservable() }
//        return Observable.merge(observables)
//    }
}
