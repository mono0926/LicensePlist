//
//  AutoColor.swift
//  
//
//  Created by acevif (acevif@gmail.com) on 2022/09/16.
//

import Foundation

public struct AutoColorMode {
    static func defaultForColorFlag() -> UsedColorMode {
        // environment variable:
        if Environment.shared[.noColor] == "1" {
            return .noColor
        }

        // auto:
        let termEnv: String? = Environment.shared[.term]
        let isTTY:Bool = isatty(STDOUT_FILENO) == 1
        return autoColor(termEnv: termEnv, isTTY: isTTY)
    }
    
    public static func usedColorMode(commandLineDesignation commandLine: UserDesignatedColorMode) -> UsedColorMode {
        
        let termEnv: String? = Environment.shared[.term]
        let noColorEnv: String? = Environment.shared[.noColor]
        let isattyResult = isatty(STDOUT_FILENO)
        
        
        return _usedColorMode(commandLineDesignation: commandLine,
                              noColorEnvironmentVariable: noColorEnv,
                              isattyResultValue: isattyResult,
                              termEnvEnvironmentVariable: termEnv)
    }

    static func autoColor(termEnv: String?, isTTY: Bool) -> UsedColorMode {
        if !isTTY {
            return .noColor
        }

        if termEnv == "dumb" {
            return .noColor
        }

        if termEnv == "xterm-256color" {
            return .color
        }

        return .noColor // to be on the safe side
    }
    
    static func _usedColorMode(commandLineDesignation: AutoColorMode.UserDesignatedColorMode,
                                          noColorEnvironmentVariable: String?,
                                          isattyResultValue: Int32,
                                          termEnvEnvironmentVariable: String?) -> UsedColorMode {
        // command line options:
        switch commandLineDesignation {
            case .noColor: return .noColor
            case .color: return .color
            case .auto: break
        }
        
        // environment variable:
        if Environment.shared[.noColor] == "1" {
            return .noColor
        }

        // auto:
        let termEnv: String? = Environment.shared[.term]
        let isTTY:Bool = isatty(STDOUT_FILENO) == 1
        return autoColor(termEnv: termEnv, isTTY: isTTY)
    }
    
    public enum UserDesignatedColorMode {
        case color
        case noColor
        case auto
    }
    
    public enum UsedColorMode {
        case color
        case noColor
    }
}

typealias UsedColorMode = AutoColorMode.UsedColorMode
typealias UserDesignatedColorMode = AutoColorMode.UserDesignatedColorMode
