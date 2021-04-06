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

        let xcodeprojPackageResolvedPath = validatedPath
            .appendingPathComponent("project.xcworkspace")
            .appendingPathComponent("xcshareddata")
            .appendingPathComponent("swiftpm")
            .appendingPathComponent("Package.resolved")

        let xcworkspacePackageResolvedPath = validatedPath
            .deletingPathExtension()
            .appendingPathExtension("xcworkspace")
            .appendingPathComponent("xcshareddata")
            .appendingPathComponent("swiftpm")
            .appendingPathComponent("Package.resolved")

        let defaultPath = xcworkspacePackageResolvedPath

        /*
         Xcode only update one Package.resolved that associated with workspace you work in. so, the files may be inconsistent at any time.
         This implementation compare modificationDate and use new one to avoid referring old Package.resolved.
         */
        switch (xcodeprojPackageResolvedPath.lp.isExists, xcworkspacePackageResolvedPath.lp.isExists) {
        case (true, true):
            guard
                let xcodeprojPackageResolvedModifiedDate = try xcodeprojPackageResolvedPath
                    .resourceValues(forKeys: [.attributeModificationDateKey])
                    .attributeModificationDate,
                let xcworkspacePackageResolveModifiedDate = try xcworkspacePackageResolvedPath
                    .resourceValues(forKeys: [.attributeModificationDateKey])
                    .attributeModificationDate
            else {
                return try SwiftPackageFileReader(path: defaultPath).read()
            }

            if xcworkspacePackageResolveModifiedDate >= xcodeprojPackageResolvedModifiedDate {
                return try SwiftPackageFileReader(path: xcworkspacePackageResolvedPath).read()
            } else {
                return try SwiftPackageFileReader(path: xcodeprojPackageResolvedPath).read()
            }

        case (true, false):
            return try SwiftPackageFileReader(path: xcodeprojPackageResolvedPath).read()

        case (false, true):
            return try SwiftPackageFileReader(path: xcworkspacePackageResolvedPath).read()

        case (false, false):
            return try SwiftPackageFileReader(path: defaultPath).read()
        }
    }

}
