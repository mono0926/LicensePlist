import HeliumLogger
import LoggerAPI
import Foundation
import TSCBasic
import System

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
    public var silenceMode: Bool
    public var colored: Bool
    public var verbose: Bool

    public init(silenceModeCommandLineFlag: Bool,
                noColorCommandLineFlag: Bool,
                colorCommandLineFlag: Bool,
                verboseCommandLineFlag: Bool){
        let env: [String:String] = ProcessInfo.processInfo.environment

        silenceMode = silenceModeCommandLineFlag
        colored = Self.color(noColorCommandLineFlag: noColorCommandLineFlag,
                        colorCommandLineFlag: colorCommandLineFlag,
                        env: env)
        self.verbose = verboseCommandLineFlag
    }
    
    private static func color(noColorCommandLineFlag: Bool,
                               colorCommandLineFlag: Bool,
                               env: [String:String]) -> Bool {
        // commandline options:
        if noColorCommandLineFlag {
            return false
        }
        if colorCommandLineFlag {
            return true
        }
        
        // environment variable:
        if env[Consts.EnvironmentVariableKey.noColor] == "1" {
            return false
        }
        
        // auto:
        switch terminalType() {
        case .file:
            return false
        case .dumb:
            return false // Dumb terminals don't interpret escape sequences
        case .tty:
            break // Keep guessing
        case .none:
            return false // to be on the safe side
        }

        // TODO: detect pipe (and return no-color)
        // see https://stackoverflow.com/questions/899764/distinguishing-a-pipe-from-a-file-in-unix for more details
        
        if env["TERM"] == "xterm-256color" {
            return true
        }
        
        return false
    }

    private static func terminalType() -> TerminalController.TerminalType? {
        // FILEPointer(aka UnsafeMutablePointer<FILE>)はCのFILE*と同じと仮定
        // fdopenで fileDescriptorから filePointerを作り、
        // FILEPointerからLocalFileOutputByteStream を作り、terminalTypeを取得
        let stdOutFileDescriptor: Int32 = {
            if #available(macOS 11,*) {
                return FileDescriptor.standardOutput.rawValue as Int32
            } else {
                return 1 as Int32
            }
        }()
        // TODO: 本当に標準出力でいいのか確認。標準エラー出力にログを吐いている可能性も
        
        do {
            let mode = "r"
            let terminalType:TerminalController.TerminalType = try mode.withCString {
                (modeCString: UnsafePointer<CChar>) -> TerminalController.TerminalType in
                
                let filePointer: FILEPointer = fdopen(stdOutFileDescriptor, modeCString)
                let stream = try LocalFileOutputByteStream(filePointer: filePointer)
                // TerminalController.terminalType() use isatty() inside.
                return TerminalController.terminalType(stream)
            }
            
            debugPrint(terminalType) // debug
            return terminalType
        } catch is FileSystemError {
            return nil
        } catch {
            assertionFailure("An unexpected/unhandled error occured.")
            return nil
        }
    }
}
