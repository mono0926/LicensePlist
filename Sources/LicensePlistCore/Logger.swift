import HeliumLogger
import LoggerAPI

public struct Logger {
    public static func configure(silenceModeCommandLineFlag: Bool,
                                 colorCommandLineFlag: Bool?,
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

        let colorMode = AutoColorMode.usedColorMode(commandLineDesignation: UserDesignatedColorMode(from: colorCommandLineFlag))
        logger.colored = colorMode.boolValue
        
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


extension UserDesignatedColorMode {
    init(from flag: Bool?) {
        switch flag {
        case .none: self = .noDesignation
        case .some(true): self = .color
        case .some(false): self = .noColor
        }
    }
}

extension UsedColorMode {
    var boolValue: Bool {
        switch self {
        case .color: return true
        case .noColor: return false
        }
    }
}
