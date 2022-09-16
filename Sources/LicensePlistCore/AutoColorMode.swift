//
//  AutoColorMode.swift
//  
//
//  Created by acevif (acevif@gmail.com) on 2022/09/16.
//

import Foundation

// Facade
public struct AutoColorMode {
    public static func usedColorMode(commandLineDesignation: UserDesignatedColorMode) -> UsedColorMode {
        return UsedColorMode(commandLineDesignation: commandLineDesignation)
    }
}

public enum UserDesignatedColorMode {
    case color
    case noColor
    case forceAuto
    case noDesignation
}

public enum UsedColorMode {
    case color
    case noColor

    public init(commandLineDesignation: UserDesignatedColorMode) {
        let termEnv: String? = Environment.shared[.term]
        let noColorEnv: String? = Environment.shared[.noColor]
        // TODO: Support STDERR
        let isattyResult = isatty(STDOUT_FILENO)

        self = Self._usedColorMode(commandLineDesignation: commandLineDesignation,
                                   noColorEnvironmentVariable: noColorEnv,
                                   isattyResultValue: isattyResult,
                                   termEnvEnvironmentVariable: termEnv)
    }

    internal static func _usedColorMode(commandLineDesignation: UserDesignatedColorMode,
                                        noColorEnvironmentVariable: String?,
                                        isattyResultValue: Int32,
                                        termEnvEnvironmentVariable: String?) -> UsedColorMode {
        // command line options:
        switch commandLineDesignation {
        case .noColor:
            return .noColor
        case .color:
            return .color
        case .noDesignation:
            // -> env -> auto
            break
        case .forceAuto:
            // -> auto
            let isTTY: Bool = isattyResultValue == 1
            return autoColor(termEnv: termEnvEnvironmentVariable, isTTY: isTTY)
        }

        // environment variable:
        if noColorEnvironmentVariable == "1" {
            return .noColor
        }

        // auto:
        let isTTY: Bool = isattyResultValue == 1
        return autoColor(termEnv: termEnvEnvironmentVariable, isTTY: isTTY)
    }

    private static func autoColor(termEnv: String?, isTTY: Bool) -> UsedColorMode {
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
}
