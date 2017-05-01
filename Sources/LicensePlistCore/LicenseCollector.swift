import Foundation
import RxSwift
import APIKit
import LoggerAPI

public protocol LicenseCollectorProtocol {
    func collect(with name: LibraryName) -> Observable<LicenseCollectResult>
    func collect(with names: [LibraryName]) -> Observable<LicenseCollectResult>
}

public struct LicenseCollectResult {
    let name: String
    let license: String
}

class LicenseCollector: LicenseCollectorProtocol {
    private var failedInfo = Set<String>()

    func collect(with name: LibraryName) -> Observable<LicenseCollectResult> {
        switch name {
        case .gitHub(let owner, let repo):
            return download(owner: owner, repo: repo)
        case .name(let name):
            return collect(with: name)
        }
    }
    func collect(with names: [LibraryName]) -> Observable<LicenseCollectResult> {
        let observables = names.map { self.collect(with: $0) }
        return Observable.merge(observables)
    }

    private func download(owner: String, repo: String) -> Observable<LicenseCollectResult> {
        Log.info("license download start(owner: \(owner), repo: \(repo))")
        return Session.shared.rx.response(RepoRequests.License(owner: owner, repo: repo))
            .flatMap { response in
                response.downloadUrl.downloadContent()
        }
            .map { LicenseCollectResult(name: repo, license: $0) }
            .catchError { error in
                if let error = error as? SessionTaskError {
                    switch error {
                    case .responseError(let error):
                        let errorMessage = String(describing: error)
                        if errorMessage == "unacceptableStatusCode(404)" {
                            Log.error("license download failed(owner: \(owner), repo: \(repo))")
                            Log.error("error: \(errorMessage)")
                            if self.failedInfo.contains(repo) {
                                Log.error("Retried, but failed again...")
                                return Observable.empty()
                            } else {
                                self.failedInfo.insert(repo)
                                Log.info("Retrying...")
                                return self.collectParent(with: owner, name: repo)
                            }
                        }
                    case .requestError, .connectionError:
                        break
                    }
                }
                assert(false, String(describing: error))
                return Observable.error(error)
        }
    }

    private func collect(with name: String) -> Observable<LicenseCollectResult> {
        return Session.shared.rx.response(SearchRequests.Repositories(query: name))
            .flatMap { response -> Observable<LicenseCollectResult> in
                if let first = response.items.first, first.name == name {
                    return self.download(owner: first.owner.login, repo: name)
                } else {
                    Log.error("\(name) not found on GitHub")
                    return Observable.empty()
                }
        }
    }

    private func collectParent(with owner: String, name: String) -> Observable<LicenseCollectResult> {
        return Session.shared.rx.response(RepoRequests.Get(owner: owner, repo: name))
            .flatMap { response -> Observable<LicenseCollectResult> in
                if let parent = response.parent {
                    return self.download(owner: parent.owner.login, repo: name)
                } else {
                    Log.error("\(name)'s original and parent's license not found on GitHub")
                    return Observable.empty()
                }
        }
    }
}
