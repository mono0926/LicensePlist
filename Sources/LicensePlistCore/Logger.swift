import HeliumLogger
import LoggerAPI

public enum Logger {
    public static func configure() {
        let logger = createDefaultLogger()
//        let logger = createDebugLogger()
        logger.colored = true
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
