import HeliumLogger
import LoggerAPI
import Foundation
import TSCBasic
import System

public struct LoggerConfiguration {
    public var silence: Bool
    public var colored: Bool
    public var verbose: Bool

    public static let noColorEnv = "NO_COLOR"
    private static let env = ProcessInfo.processInfo.environment
    
    public init(silenceModeCommandLineFlag: Bool,
                noColorCommandLineFlag: Bool,
                colorCommandLineFlag: Bool,
                verboseCommandLineFlag: Bool){
        silence = silenceModeCommandLineFlag
        
        colored = {
            do {
                if noColorCommandLineFlag {
                    return false
                }
                
                if colorCommandLineFlag {
                    return true
                }
                
                if Self.env[Self.noColorEnv] == "1" {
                    return false
                }
                
                // パイプならno-color
    //            TextOutputStream
                //FileDescriptor.standardOutput
    //            FileHandle.standardOutput
    //            standardOutput

    //            if isatty()
    //            // check terminal
    //            if env["TERM"] == "xterm-256color"
    //            if TerminalController.terminalType(LocalFileOutputByteStream) == .file {
    //                return false
    //            }

                // FILEPointer(aka UnsafeMutablePointer<FILE>)は FILE* と同じと仮定
                // fdopenで fileDescriptorから filePointerを作り、
                // FILEPointerからLocalFileOutputByteStream を作り、terminalTypeを取得
                let fileDescriptor: Int32 = {
                    if #available(macOS 11,*) {
                        return FileDescriptor.standardOutput.rawValue as Int32
                    } else {
                        return 1 as Int32
                    }
                }()
                
                let mode = "r"
                let terminalType:TerminalController.TerminalType = try mode.withCString { (cstr: UnsafePointer<CChar>) -> TerminalController.TerminalType in
                    let filePointer: FILEPointer! = fdopen(fileDescriptor, mode)
                    let s = try LocalFileOutputByteStream(filePointer: filePointer)
                    return TerminalController.terminalType(s)
                }
                
                if terminalType == .file {
                    return false
                }
                
                return true
            } catch {
                return false
            }
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

//extension String {
//    func toUnsafePointer() -> UnsafePointer<CChar>? {
//        self.withCString{ (p:UnsafePointer<Int8>) in
//            return p
//        }
//
////        // Write to output stream:
////        let outputStream: NSOutputStream = ... // the stream that you want to write to
////        let bytesWritten = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count) }
//
//    }
//
//
//}

