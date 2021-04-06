//
//  FileReader.swift
//  APIKit
//
//  Created by yosshi4486 on 2021/04/06.
//

import Foundation

/// An object that reads any file from the given path.
protocol FileReader {

    /// The result parameter type of reading a file.
    associatedtype ResultType

    /// Returns a concrete result by reading a file which the given path specifies.
    ///
    /// - Parameter path: The path which the file located.
    func read(path: URL) -> ResultType

}
