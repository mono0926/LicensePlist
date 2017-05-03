import LoggerAPI
import RxSwift
import APIKit


extension CarthageLicense: Collector {
    public static func collect(_ library: Carthage) -> Maybe<CarthageLicense> {
        let owner = library.owner
        let name = library.name
        Log.info("license download start(owner: \(owner), name: \(name))")
        return Session.shared.rx.response(RepoRequests.License(owner: owner, repo: name))
            .flatMap { response in
                response.downloadUrl.downloadContent()
                    .map {
                        return CarthageLicense(library: library,
                                               body: $0,
                                               githubResponse: response)
                }
            }
            .asObservable().asMaybe()
            .catchError { error -> Maybe<CarthageLicense> in
                if !self.isSessionTask404(error) {
                    assert(false, String(describing: error))
                    return Maybe.error(error)
                }
                Log.warning("404 error, license download failed(owner: \(owner), name: \(name)), so finding parent...")
                return Session.shared.rx.response(RepoRequests.Get(owner: owner, repo: name))
                    .asObservable().asMaybe()
                    .flatMap { response -> Maybe<CarthageLicense> in
                        if let parent = response.parent {
                            var library = library
                            library.owner = parent.owner.login
                            return collect(library)
                        } else {
                            Log.warning("\(name)'s original and parent's license not found on GitHub")
                            return Maybe.empty()
                        }
                }
        }
    }

    private static func isSessionTask404(_ error: Error) -> Bool {
        guard let taskError = error as? SessionTaskError else {
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
