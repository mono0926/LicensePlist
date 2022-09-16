import HeliumLogger
import LoggerAPI
import ArgumentParser

public struct Logger {
    public static func configure(silenceModeCommandLineFlag: Int,
                                 colorCommandLineFlag: Bool?) {
        if silenceModeCommandLineFlag == 0 {
            return
        }

        let logger: HeliumLogger = {
            if silenceModeCommandLineFlag == 1 {
                return createDefaultLogger()
            } else {
                assert(2 <= silenceModeCommandLineFlag)
                return createDebugLogger()
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

public enum SilenceMode: Int, EnumerableFlag {
    init?(argument: String) {
        switch argument {
        case "silence-mode":
            self = .silenceMode
        case "verbose":
            self = .verbose
        default:
            return nil
        }
    }

    public static func name(for value: Self) -> NameSpecification {
        switch value {
        case .silenceMode:
            return [.long, .customLong("silent")]
        case .normal:
            return []
        case .verbose:
            return .long
        }
    }

    case silenceMode = 0
    case normal = 1
    case verbose = 2
}

