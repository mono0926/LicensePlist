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
                let statusCode = self.statusCode(from: error)
                if statusCode != 404 {
                    assert(false, String(describing: error))
                    if statusCode == 403 {
                        Log.warning("Failed to download \(name).\nYou can try `--github-token YOUR_REPO_SCOPE_TOKEN` option")
                    } else {
                        Log.warning("Failed to download \(name).\nError: \(error)")
                    }
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

    private static func statusCode(from error: Error) -> Int? {
        guard let taskError = error as? SessionTaskError else {
            return nil
        }
        switch taskError {
        case .responseError(let error):
            if let error = error as? ResponseError {
                if case .unacceptableStatusCode(let code) = error {
                    return code
                }
            }
            return nil
        default:
            return nil
        }
    }
}
