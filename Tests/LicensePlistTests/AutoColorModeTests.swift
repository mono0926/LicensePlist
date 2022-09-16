import Foundation
import XCTest
import SwiftParamTest
@testable import LicensePlistCore

class AutoColorModeTests: XCTestCase {
    func testUsedColorMode() throws {
        assert(to: AutoColorMode._usedColorMode) {
            args(UserDesignatedColorMode.color, "0", Int32(1), "xterm-256color", expect: UsedColorMode.color)
            args(UserDesignatedColorMode.color, "0", Int32(0), "xterm-256color", expect: UsedColorMode.color)
            args(UserDesignatedColorMode.color, "0", Int32(1), "dumb", expect: UsedColorMode.color)
            args(UserDesignatedColorMode.color, "1", Int32(1), "xterm-256color", expect: UsedColorMode.color)
            
            args(UserDesignatedColorMode.noColor,  "0", Int32(1), "xterm-256color", expect: UsedColorMode.noColor)

            args(UserDesignatedColorMode.auto,  "0", Int32(1), "xterm-256color", expect: UsedColorMode.color)
            args(UserDesignatedColorMode.auto,  "0", Int32(1), "dumb", expect: UsedColorMode.noColor)
            args(UserDesignatedColorMode.auto,  "0", Int32(0), "xterm-256color", expect: UsedColorMode.noColor)
            
        }
//        logger.colored = AutoColorMode.usedColorMode(userDesignated: commandLineColorMode).boolValue
    }
    
    func testUsedColorMode_boolValue() throws {
        //AutoColorMode.usedColorMode(userDesignated: commandLineColorMode).boolValue
    }
    
//    let commandLineColorMode : AutoColorMode.UserDesignatedColorMode = AutoColor.DesignatedColor(colorCommandLineFlag)
}
