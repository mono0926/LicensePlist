//
//  Environment.swift
//  
//
//  Created by acevif (acevif@gmail.com) on 2022/09/15.
//

import Foundation

public protocol EnvironmentProtocol {
    associatedtype Keys : EnvironmentKeyProtocol
    
    subscript(key: Keys) -> String? { get }
}

public protocol EnvironmentKeyProtocol : RawRepresentable where RawValue == String {}


public let shared = EnvironmentImpl<KeysImpl>()

public struct EnvironmentImpl<T:EnvironmentKeyProtocol> : EnvironmentProtocol {
    public typealias Keys = T
    
    public subscript<T : EnvironmentKeyProtocol>(key: T) -> String? {
        ProcessInfo.processInfo.environment[key.rawValue]
    }
}

public enum KeysImpl: String, EnvironmentKeyProtocol, RawRepresentable {
    case githubToken = "LICENSE_PLIST_GITHUB_TOKEN"
    case noColor = "NO_COLOR"
    case term = "TERM"
}
