import HeliumLogger
import LoggerAPI

public struct Logger {
    public static func configure(silenceModeCommandLineFlag: Bool,
                                 colorCommandLineFlag: Bool,
                                 verboseCommandLineFlag: Bool) {
        if silenceModeCommandLineFlag {
            return
        }

        let logger: HeliumLogger = {
            if verboseCommandLineFlag {
                return createDebugLogger()
            } else {
                return createDefaultLogger()
            }
        }()
        
        logger.colored = colorCommandLineFlag
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
