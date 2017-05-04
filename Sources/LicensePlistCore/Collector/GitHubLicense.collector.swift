import LoggerAPI
import APIKit
import Result
import Foundation

extension GitHubLicense: Collector {
    public static func collect(_ library: GitHub) -> ResultOperation<GitHubLicense, CollectorError> {
        let owner = library.owner
        let name = library.name
        Log.info("license download start(owner: \(owner), name: \(name))")
        return ResultOperation<GitHubLicense, CollectorError> { _ in
            let result = Session.shared.lp.sendSync(RepoRequests.License(owner: owner, repo: name))
            switch result {
            case .failure(let error):
                if !self.isSessionTask404(error) {
                    assert(false, String(describing: error))
                    return Result(error: CollectorError.unexpected(error))
                }
                Log.warning("404 error, license download failed(owner: \(owner), name: \(name)), so finding parent...")
                let result = Session.shared.lp.sendSync(RepoRequests.Get(owner: owner, repo: name))
                switch result {
                case .failure(let error):
                    return Result(error: CollectorError.unexpected(error))
                case .success(let response):
                    if let parent = response.parent {
                        var library = library
                        library.owner = parent.owner.login
                        return collect(library).blocking().result!
                    } else {
                        Log.warning("\(name)'s original and parent's license not found on GitHub")
                        return Result(error: .notFound("\(name)'s original and parent's"))
                    }
                }
            case .success(let response):
                let license = GitHubLicense(library: library,
                                                 body: response.downloadUrl.downloadContent().blocking().result!.value!,
                                                 githubResponse: response)
                return Result.init(value: license)
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
