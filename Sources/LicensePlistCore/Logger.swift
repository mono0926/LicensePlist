import HeliumLogger
import LoggerAPI
import Foundation
//import TSCBasic
//import System
//import Darwin

public struct Logger {
    public static func configure(silenceModeCommandLineFlag: Bool,
                                 noColorCommandLineFlag: Bool,
                                 colorCommandLineFlag: Bool,
                                 verboseCommandLineFlag: Bool) {
        
        let loggerConfiguration = LoggerConfiguration(silenceModeCommandLineFlag: silenceModeCommandLineFlag,
                                                      noColorCommandLineFlag: noColorCommandLineFlag,
                                                      colorCommandLineFlag: colorCommandLineFlag,
                                                      verboseCommandLineFlag: verboseCommandLineFlag)
        
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
        
        logger.colored = loggerConfiguration.colored.rawValue
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
    public var silenceMode: Bool
    public var colored: Colored
    public var verbose: Bool

    public init(silenceModeCommandLineFlag: Bool,
                noColorCommandLineFlag: Bool,
                colorCommandLineFlag: Bool,
                verboseCommandLineFlag: Bool){
        let env: [String:String] = ProcessInfo.processInfo.environment

        silenceMode = silenceModeCommandLineFlag
        self.colored = Self.colored(noColorCommandLineFlag: noColorCommandLineFlag,
                        colorCommandLineFlag: colorCommandLineFlag,
                        env: env)
        self.verbose = verboseCommandLineFlag
    }
    
    enum Colored: RawRepresentable {
        init?(rawValue: Bool) {
            switch rawValue {
            case true: self = .colored
            case false: self = .noColor
            }
        }
        
        var rawValue: Bool {
            switch self {
            case .colored: return true
            case .noColor: return false
            }
        }
        
        typealias RawValue = Bool
        
        case colored
        case noColor
    }
    
    private static func colored(noColorCommandLineFlag: Bool,
                               colorCommandLineFlag: Bool,
                               env: [String:String]) -> Colored {
        // commandline options:
        if noColorCommandLineFlag {
            return .noColor
        }
        if colorCommandLineFlag {
            return .colored
        }
        
        // environment variable:
        if env[Consts.EnvironmentVariableKey.noColor] == "1" {
            return .noColor
        }
        
        // auto:
        func isTTY(_ fd:Int32) -> Bool {
            return isatty(fd) == 1
        }
        if !isTTY(STDOUT_FILENO) {
            return .noColor
        }
        
        // TODO: detect pipe (and return no-color)
        
        if env["TERM"] == "dumb" {
            return .noColor
        }
        
        if env["TERM"] == "xterm-256color" {
            return .colored
        }
        
        return .noColor // to be on the safe side
    }

//    private static func terminalType() -> TerminalController.TerminalType? {
//        // cf. FILEPointer = UnsafeMutablePointer<FILE> = FILE* in C
//
//        // fdopenで fileDescriptorから filePointerを作り、
//        // FILEPointerからLocalFileOutputByteStream を作り、terminalTypeを取得
//        let stdOutFileDescriptor: Int32 = {
////            if #available(macOS 11,*) {
////                return //FileDescriptor.standardOutput.rawValue as Int32
////            } else {
//                return STDOUT_FILENO as Int32
////            }
//        }()
//        // TODO: 本当に標準出力でいいのか確認。標準エラー出力にログを吐いている可能性も
//
////        fdopen(<#T##Int32#>, <#T##UnsafePointer<CChar>!#>)
//
//        do {
//            let mode = "r"
//            let terminalType:TerminalController.TerminalType = try mode.withCString {
//                (modeCString: UnsafePointer<CChar>) -> TerminalController.TerminalType in
//
//                    //open()
//                let filePointer: FILEPointer = fdopen(stdOutFileDescriptor, O_RDONLY)
//                let stream = try LocalFileOutputByteStream(filePointer: filePointer)
//                // TerminalController.terminalType() use isatty() inside.
//                return TerminalController.terminalType(stream)
//            }
//
//            let isatty = isatty(STDOUT_FILENO)
//
//            #if !os(Windows)
//                    if ProcessInfo.processInfo.environment["TERM"] == "dumb" {
//                        return .noColor
//                    }
//            #endif
//            let isTTY = isatty(fileno(stream.filePointer)) != 0
//        return isTTY ? .tty : .file
//    }
//
//            debugPrint(terminalType) // debug
//            return terminalType
//        } catch is FileSystemError {
//            return nil
//        } catch {
//            assertionFailure("An unexpected/unhandled error occured.")
//            return nil
//        }
//    }
}
