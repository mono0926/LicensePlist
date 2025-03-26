import APIKit
import Foundation
import LoggerAPI

public struct GitHubLicense: License, Equatable {
  public let library: GitHub
  public let body: String
  let githubResponse: LicenseResponse?

  public static func == (lhs: GitHubLicense, rhs: GitHubLicense) -> Bool {
    return lhs.library == rhs.library && lhs.body == rhs.body
  }
}

extension GitHubLicense: CustomStringConvertible {
  public var description: String { library.description }
}

extension GitHubLicense {

  public enum DownloadError: Error {
    case
      unexpected(Error)
    case
      notFound(String)
  }

  public static func download(_ library: GitHub) -> ResultOperation<GitHubLicense, DownloadError> {
    let owner = library.owner
    let name = library.name
    Log.info("license download start(owner: \(owner), name: \(name))")
    return ResultOperation<GitHubLicense, DownloadError> { _ in
      let result = Session.shared.lp.sendSync(RepoRequests.License(owner: owner, repo: name))
      switch result {
      case .failure(let error):
        let statusCode = self.statusCode(from: error)
        if statusCode != 404 {
          assert(false, String(describing: error))
          if statusCode == 403 {
            Log.warning(
              "Failed to download \(name).\nYou can try `--github-token YOUR_REPO_SCOPE_TOKEN` option"
            )
          } else {
            Log.warning("Failed to download \(name).\nError: \(error)")
          }
          return Result.failure(DownloadError.unexpected(error))
        }
        Log.warning(
          "404 error, license download failed(owner: \(owner), name: \(name)), so finding parent..."
        )
        let result = Session.shared.lp.sendSync(RepoRequests.Get(owner: owner, repo: name))
        switch result {
        case .failure(let error):
          return Result.failure(DownloadError.unexpected(error))
        case .success(let response):
          if let parent = response.parent {
            var library = library
            library.owner = parent.owner.login
            return download(library).resultSync()
          } else {
            Log.warning("\(name)'s original and parent's license not found on GitHub")
            return Result.failure(.notFound("\(name)'s original and parent's"))
          }
        }
      case .success(let response):
          return Result.success(GitHubLicense(
            library: GitHub(
                name: library.name,
                nameSpecified: library.nameSpecified,
                owner: library.owner,
                version: library.version,
                licenseType: LicenseType(id: response.kind.spdxId)),
            body: response.contentDecoded,
            githubResponse: response))
      }
    }
  }

  public static func readFromDisk(
    _ libraries: [GitHub], checkoutPath: URL, licenseFileNames: [String]
  ) -> [GitHubLicense] {
    return libraries.compactMap { library in
      let owner = library.owner
      let name = library.name
      Log.info("license reading from disk start(owner: \(owner), name: \(name))")

      let libraryUrl = checkoutPath.appendingPathComponent(name)
      let libraryFileUrls = libraryUrl.lp.listDir().filter { !$0.lp.isDirectory }

      // Check several variants of license file name
      for fileName in licenseFileNames {
        guard let url = findFile(with: fileName, in: libraryFileUrls) else {
          continue
        }
        do {
          let content = try String(contentsOf: url)
          // Return the content of the first matched file
          return GitHubLicense(library: library, body: content, githubResponse: nil)
        } catch {
          continue
        }
      }

      Log.warning("Failed to read from disk \(name)")
      return nil
    }
  }

  private static func findFile(with fileName: String, in fileUrls: [URL]) -> URL? {
    let anyExtensionSuffix = ".*"
    if fileName.hasSuffix(anyExtensionSuffix) {
      // Check file names without extensions
      let fileNameWithoutExtension = String(
        fileName.prefix(fileName.count - anyExtensionSuffix.count))
      let lowercasedFileName = fileNameWithoutExtension.lowercased()
      for fileUrl in fileUrls {
        let candidateFileName = fileUrl.deletingPathExtension().lastPathComponent
        if candidateFileName.lowercased() == lowercasedFileName {
          return fileUrl
        }
      }
    } else {
      // Check lowercased file names
      let lowercasedFileName = fileName.lowercased()
      for fileUrl in fileUrls where fileUrl.lastPathComponent.lowercased() == lowercasedFileName {
        return fileUrl
      }
    }
    return nil
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
