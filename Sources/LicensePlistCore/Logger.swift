import HeliumLogger
import LoggerAPI
import Foundation

public struct Logger {
    public static func configure(noColor: Bool) {
        let logger = createDefaultLogger()
//        let logger = createDebugLogger()
        logger.colored = !noColor
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
