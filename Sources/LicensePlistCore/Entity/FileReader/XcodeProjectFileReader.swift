//
//  XcodeProjectFileReader.swift
//  LicensePlistCore
//
//  Created by yosshi4486 on 2021/04/06.
//

import Foundation

/// An object that reads a  xcodeproj file.
struct XcodeProjectFileReader: FileReader {

    typealias ResultType = String?

    let path: URL

    var projectPath: URL? {
        if path.lastPathComponent.contains("*") {
            // find first "xcodeproj" in directory
            return path.deletingLastPathComponent().lp.listDir().first { $0.pathExtension == Consts.xcodeprojExtension }
        } else {
            // use the specified path
            return path
        }
    }

    func read() -> String? {
        return nil
    }

}
