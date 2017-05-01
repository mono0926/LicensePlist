import Foundation
import RxSwift
import APIKit
import LoggerAPI

// TODO: set license url
public protocol LicenseCollectorProtocol {
    func collect(with library: Library) -> Observable<License>
    func collect(with libraries: [Library]) -> Observable<License>
}

class LicenseCollector: LicenseCollectorProtocol {
    private var failedNames = Set<String>()

    func collect(with library: Library) -> Observable<License> {
        let name = library.name
        if let owner = library.owner {
            Log.info("license download start(owner: \(owner), name: \(name))")
            return Session.shared.rx.response(RepoRequests.License(owner: owner, repo: name))
                .flatMap { response in
                    response.downloadUrl.downloadContent()
                        .map {
                            return License(library: library,
                                           license: response,
                                           body: $0)
                        }
                }
                .catchError { error in
                    let handleError = { () -> Observable<License> in
                        assert(false, String(describing: error))
                        return Observable.error(error)
                    }
                    if !error.isSessionTask404 {
                        return handleError()
                    }
                    Log.error("404 error, license download failed(owner: \(owner), name: \(name))")
                    if self.failedNames.contains(name) {
                        Log.error("Retried, but failed again...")
                        return Observable.empty()
                    }
                    self.failedNames.insert(name)
                    Log.info("Retrying...")
                    return Session.shared.rx.response(RepoRequests.Get(owner: owner, repo: name))
                        .catchError { error in
                            if error.isSessionTask404 {
                                Log.error("404 error, license download failed(owner: \(owner), name: \(name))")
                                return Observable.empty()
                            }
                            return Observable.error(error)
                        }
                        .flatMap { response -> Observable<License> in
                            if let parent = response.parent {
                                var library = library
                                library.owner = parent.owner.login
                                return self.collect(with: library)
                            } else {
                                Log.error("\(name)'s original and parent's license not found on GitHub")
                                return Observable.empty()
                            }
                    }
            }
        }
        return Session.shared.rx.response(SearchRequests.Repositories(query: name))
            .flatMap { response -> Observable<License> in
                if let first = response.items.first, first.name == name {
                    var library = library
                    library.owner = first.owner.login
                    return self.collect(with: library)
                } else {
                    Log.error("\(name) not found on GitHub")
                    return Observable.empty()
                }
        }
    }
    func collect(with libraries: [Library]) -> Observable<License> {
        let observables = libraries.map { self.collect(with: $0) }
        return Observable.merge(observables)
    }
}

extension Error {
    var isSessionTask404: Bool {
        guard let taskError = self as? SessionTaskError else {
            return false
        }
        switch taskError {
        case .responseError(let error):
            return String(describing: error) == "unacceptableStatusCode(404)"
        default:
            return false
        }
    }
}
