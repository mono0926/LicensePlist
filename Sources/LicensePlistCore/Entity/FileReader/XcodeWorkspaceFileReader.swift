import Foundation

/// An object that reads a xcodeproj file.
struct XcodeWorkspaceFileReader: FileReader {

    typealias ResultType = String?

    let path: URL

    /// The path which specifies `"*.xcworkspace` file wrapper.
    var workspacePath: URL? {
        if path.lastPathComponent.contains("*") {
            // find first "xcworkspace" in directory
            return path.deletingLastPathComponent().lp.listDir().first { $0.pathExtension == Consts.xcworkspaceExtension }
        } else {
            // use the specified path
            return path
        }
    }

    func read() throws -> String? {
        guard let validatedPath = workspacePath else { return nil }

        if validatedPath.pathExtension != Consts.xcworkspaceExtension {
            return nil
        }

        let packageResolvedPath = validatedPath
            .appendingPathComponent("xcshareddata")
            .appendingPathComponent("swiftpm")
            .appendingPathComponent("Package.resolved")

        guard packageResolvedPath.lp.isExists else {
            return nil
        }

        return try SwiftPackageFileReader(path: packageResolvedPath).read()
    }

}
