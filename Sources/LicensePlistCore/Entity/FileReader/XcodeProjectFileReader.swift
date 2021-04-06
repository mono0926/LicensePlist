//
//  XcodeProjectFileReader.swift
//  LicensePlistCore
//
//  Created by yosshi4486 on 2021/04/06.
//

import Foundation

/// An object that reads a xcodeproj file.
struct XcodeProjectFileReader: FileReader {

    typealias ResultType = String?

    let path: URL

    /// The path which specifies "xcodeproj" file.
    var projectPath: URL? {
        if path.lastPathComponent.contains("*") {
            // find first "xcodeproj" in directory
            return path.deletingLastPathComponent().lp.listDir().first { $0.pathExtension == Consts.xcodeprojExtension }
        } else {
            // use the specified path
            return path
        }
    }

    func read() throws -> String? {
        guard let validatedPath = projectPath else { return nil }

        if validatedPath.pathExtension != Consts.xcodeprojExtension {
            return nil
        }
        let packageResolvedPath = validatedPath
            .appendingPathComponent("project.xcworkspace")
            .appendingPathComponent("xcshareddata")
            .appendingPathComponent("swiftpm")
            .appendingPathComponent("Package.resolved")
        if packageResolvedPath.lp.isExists {
            return readSwiftPackages(path: packageResolvedPath)
        } else {
            let packageResolvedPath = validatedPath
            .deletingPathExtension()
            .appendingPathExtension("xcworkspace")
            .appendingPathComponent("xcshareddata")
            .appendingPathComponent("swiftpm")
            .appendingPathComponent("Package.resolved")
            return readSwiftPackages(path: packageResolvedPath)
        }
    }

}
