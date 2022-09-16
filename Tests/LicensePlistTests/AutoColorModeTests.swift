//
//  AutoColorModeTests.swift
//
//
//  Created by acevif (acevif@gmail.com) on 2022/09/16.
//

import Foundation
import XCTest
import SwiftParamTest
@testable import LicensePlistCore

class AutoColorModeTests: XCTestCase {
    func testUsedColorMode() throws {
        assert(to: UsedColorMode._usedColorMode) {
            args(        UserDesignatedColorMode.color, "0", Int32(0), "xterm-256color", expect:   UsedColorMode.color)
            args(        UserDesignatedColorMode.color, "0", Int32(0),           "dumb", expect:   UsedColorMode.color)
            args(        UserDesignatedColorMode.color, "0", Int32(1), "xterm-256color", expect:   UsedColorMode.color)
            args(        UserDesignatedColorMode.color, "0", Int32(1),           "dumb", expect:   UsedColorMode.color)
            args(        UserDesignatedColorMode.color, "1", Int32(0), "xterm-256color", expect:   UsedColorMode.color)
            args(        UserDesignatedColorMode.color, "1", Int32(0),           "dumb", expect:   UsedColorMode.color)
            args(        UserDesignatedColorMode.color, "1", Int32(1), "xterm-256color", expect:   UsedColorMode.color)
            args(        UserDesignatedColorMode.color, "1", Int32(1),           "dumb", expect:   UsedColorMode.color)
            
            args(      UserDesignatedColorMode.noColor, "0", Int32(0), "xterm-256color", expect: UsedColorMode.noColor)
            args(      UserDesignatedColorMode.noColor, "0", Int32(0),           "dumb", expect: UsedColorMode.noColor)
            args(      UserDesignatedColorMode.noColor, "0", Int32(1), "xterm-256color", expect: UsedColorMode.noColor)
            args(      UserDesignatedColorMode.noColor, "0", Int32(1),           "dumb", expect: UsedColorMode.noColor)
            args(      UserDesignatedColorMode.noColor, "1", Int32(0), "xterm-256color", expect: UsedColorMode.noColor)
            args(      UserDesignatedColorMode.noColor, "1", Int32(0),           "dumb", expect: UsedColorMode.noColor)
            args(      UserDesignatedColorMode.noColor, "1", Int32(1), "xterm-256color", expect: UsedColorMode.noColor)
            args(      UserDesignatedColorMode.noColor, "1", Int32(1),           "dumb", expect: UsedColorMode.noColor)
            
            args(UserDesignatedColorMode.noDesignation, "0", Int32(0), "xterm-256color", expect: UsedColorMode.noColor)
            args(UserDesignatedColorMode.noDesignation, "0", Int32(0),           "dumb", expect: UsedColorMode.noColor)
            args(UserDesignatedColorMode.noDesignation, "0", Int32(1), "xterm-256color", expect:   UsedColorMode.color)
            args(UserDesignatedColorMode.noDesignation, "0", Int32(1),           "dumb", expect: UsedColorMode.noColor)
            args(UserDesignatedColorMode.noDesignation, "1", Int32(0), "xterm-256color", expect: UsedColorMode.noColor)
            args(UserDesignatedColorMode.noDesignation, "1", Int32(0),           "dumb", expect: UsedColorMode.noColor)
            args(UserDesignatedColorMode.noDesignation, "1", Int32(1), "xterm-256color", expect: UsedColorMode.noColor)
            args(UserDesignatedColorMode.noDesignation, "1", Int32(1),           "dumb", expect: UsedColorMode.noColor)
            
            args(    UserDesignatedColorMode.forceAuto, "0", Int32(0), "xterm-256color", expect: UsedColorMode.noColor)
            args(    UserDesignatedColorMode.forceAuto, "0", Int32(0),           "dumb", expect: UsedColorMode.noColor)
            args(    UserDesignatedColorMode.forceAuto, "0", Int32(1), "xterm-256color", expect:   UsedColorMode.color)
            args(    UserDesignatedColorMode.forceAuto, "0", Int32(1),           "dumb", expect: UsedColorMode.noColor)
            args(    UserDesignatedColorMode.forceAuto, "1", Int32(0), "xterm-256color", expect: UsedColorMode.noColor)
            args(    UserDesignatedColorMode.forceAuto, "1", Int32(0),           "dumb", expect: UsedColorMode.noColor)
            args(    UserDesignatedColorMode.forceAuto, "1", Int32(1), "xterm-256color", expect:   UsedColorMode.color)
            args(    UserDesignatedColorMode.forceAuto, "1", Int32(1),           "dumb", expect: UsedColorMode.noColor)
        }
    }
}
