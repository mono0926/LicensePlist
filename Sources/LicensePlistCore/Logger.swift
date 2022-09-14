import HeliumLogger
import LoggerAPI
import Foundation

public struct LoggerConfiguration {
    public var silence: Bool
    public var colored: Bool
    public var verbose: Bool

    public static let noColorEnv = "NO_COLOR"
    
    public init(silenceModeCommandLineFlag: Bool,
                noColorCommandLineFlag: Bool,
                verboseCommandLineFlag: Bool){
        silence = silenceModeCommandLineFlag
        
        colored = {
            if noColorCommandLineFlag {
                return false
            }
            
            if ProcessInfo.processInfo.environment[LoggerConfiguration.noColorEnv] == "1" {
                return false
            }
            
            return true
        }()
        
        self.verbose = verboseCommandLineFlag
    }
}

public struct Logger {
    public static func configure(with loggerConfiguration: LoggerConfiguration) {
        if loggerConfiguration.silence {
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
