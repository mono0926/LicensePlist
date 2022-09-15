import HeliumLogger
import LoggerAPI
import Foundation

typealias Env = [String:String]

public struct Logger {
    public static func configure(silenceModeCommandLineFlag: Bool,
                                 noColorCommandLineFlag: Bool,
                                 colorCommandLineFlag: Bool,
                                 verboseCommandLineFlag: Bool) {
        
        let loggerConfiguration = LoggerConfiguration(silenceModeCommandLineArg: silenceModeCommandLineFlag,
                                                      noColorCommandLineArg: noColorCommandLineFlag,
                                                      colorCommandLineArg: colorCommandLineFlag,
                                                      verboseCommandLineArg: verboseCommandLineFlag)
        
        if loggerConfiguration.silenceMode {
            return
        }

        let logger: HeliumLogger = {
            if loggerConfiguration.verbose {
                return createDebugLogger()
            } else {
                return createDefaultLogger()
            }
        }()
        
        logger.colored = loggerConfiguration.colored
        Log.logger = logger
    }

    private static func createDefaultLogger() -> HeliumLogger {
        let logger = HeliumLogger(LoggerMessageType.info)
        logger.details = false
        return logger
    }

    private static func createDebugLogger() -> HeliumLogger {
        let logger = HeliumLogger(LoggerMessageType.debug)
        logger.details = true
        return logger
    }
}

fileprivate struct LoggerConfiguration {
    public let silenceMode: Bool
    public let verbose: Bool
    
    public var colored: Bool {
        return _colored == .color
    }
    private let _colored: Colored

    public init(silenceModeCommandLineArg: Bool,
                noColorCommandLineArg: Bool,
                colorCommandLineArg: Bool,
                verboseCommandLineArg: Bool){
        let env: Env = ProcessInfo.processInfo.environment

        silenceMode = silenceModeCommandLineArg
        _colored = Self.calculateColored(noColorCommandLineFlag: noColorCommandLineArg,
                        colorCommandLineFlag: colorCommandLineArg,
                        env: env)
        self.verbose = verboseCommandLineArg
    }
    
    fileprivate enum Colored {
        case color
        case monochrome
    }
    
    fileprivate static func calculateColored(noColorCommandLineFlag: Bool,
                               colorCommandLineFlag: Bool,
                               env: Env) -> Colored {
        // commandline options:
        if noColorCommandLineFlag {
            return .monochrome
        }
        if colorCommandLineFlag {
            return .color
        }
        
        // environment variable:
        if env[Consts.EnvironmentVariableKey.noColor] == "1" {
            return .monochrome
        }
        
        // auto:
        return calculateAutoColor(env: env, fileDescriptor: STDOUT_FILENO)
    }
    
    fileprivate static func calculateAutoColor(env: Env, fileDescriptor: Int32) -> Colored {
        func isTTY(_ fileDescriptor:Int32) -> Bool {
            return isatty(fileDescriptor) == 1
        }
        if !isTTY(fileDescriptor) {
            return .monochrome
        }

        if env[Consts.EnvironmentVariableKey.term] == "dumb" {
            return .monochrome
        }
        
        if env[Consts.EnvironmentVariableKey.term] == "xterm-256color" {
            return .color
        }
        
        return .monochrome // to be on the safe side
    }
}
