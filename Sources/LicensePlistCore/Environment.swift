//
//  Environment.swift
//  
//
//  Created by acevif (acevif@gmail.com) on 2022/09/15.
//

import Foundation

public struct Environment {
    public enum Keys: String {
        case githubToken = "LICENSE_PLIST_GITHUB_TOKEN"
        case noColor = "NO_COLOR"
        case term = "TERM"
    }

    public subscript(key: Keys) -> String? {
        get {
            return ProcessInfo.processInfo.environment[key.rawValue]
        }
    }

    public static let shared = Environment()
}
