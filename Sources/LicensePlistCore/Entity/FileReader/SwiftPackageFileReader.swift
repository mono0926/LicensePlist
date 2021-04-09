//
//  SwiftPackageFileReader.swift
//  LicensePlistCore
//
//  Created by yosshi4486 on 2021/04/06.
//

import Foundation

/// An object that reads a Package.swift or Package.resolved file.
struct SwiftPackageFileReader: FileReader {

    struct FileReaderError: Swift.Error {
        let path: URL

        var localizedDescription: String? {
            return "Invalide Package.swift name: \(path.lastPathComponent)"
        }

    }

    typealias ResultType = String?

    let path: URL

    func read() throws -> String? {
        if path.lastPathComponent != Consts.packageName && path.lastPathComponent != "Package.resolved" {
            throw FileReaderError(path: path)
        }

        if let content = path.deletingPathExtension().appendingPathExtension("resolved").lp.read() {
            return content
        }
        return path.lp.read()
    }

}
