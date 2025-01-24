//
//  AutoColorModeTests.swift
//
//
//  Created by acevif (acevif@gmail.com) on 2022/09/16.
//

import Foundation
import XCTest
@preconcurrency import SwiftParamTest
@testable import LicensePlistCore

class AutoColorModeTests: XCTestCase {

    /// Please see table.md attached to the test report for more details. It is generated after runnig this test.
    func testUsedColorMode() throws {
        assert(to: UsedColorMode._usedColorMode,
               header: ["Command line flag", "$NO_COLOR", "isatty(fd)", "$TERM"]) {

            // swiftlint:disable comma colon
            args(        UserDesignatedColorMode.color, "0", 0 as Int32, "xterm-256color", expect:   UsedColorMode.color)
            args(        UserDesignatedColorMode.color, "0", 0 as Int32,           "dumb", expect:   UsedColorMode.color)
            args(        UserDesignatedColorMode.color, "0", 1 as Int32, "xterm-256color", expect:   UsedColorMode.color)
            args(        UserDesignatedColorMode.color, "0", 1 as Int32,           "dumb", expect:   UsedColorMode.color)
            args(        UserDesignatedColorMode.color, "1", 0 as Int32, "xterm-256color", expect:   UsedColorMode.color)
            args(        UserDesignatedColorMode.color, "1", 0 as Int32,           "dumb", expect:   UsedColorMode.color)
            args(        UserDesignatedColorMode.color, "1", 1 as Int32, "xterm-256color", expect:   UsedColorMode.color)
            args(        UserDesignatedColorMode.color, "1", 1 as Int32,           "dumb", expect:   UsedColorMode.color)

            args(      UserDesignatedColorMode.noColor, "0", 0 as Int32, "xterm-256color", expect: UsedColorMode.noColor)
            args(      UserDesignatedColorMode.noColor, "0", 0 as Int32,           "dumb", expect: UsedColorMode.noColor)
            args(      UserDesignatedColorMode.noColor, "0", 1 as Int32, "xterm-256color", expect: UsedColorMode.noColor)
            args(      UserDesignatedColorMode.noColor, "0", 1 as Int32,           "dumb", expect: UsedColorMode.noColor)
            args(      UserDesignatedColorMode.noColor, "1", 0 as Int32, "xterm-256color", expect: UsedColorMode.noColor)
            args(      UserDesignatedColorMode.noColor, "1", 0 as Int32,           "dumb", expect: UsedColorMode.noColor)
            args(      UserDesignatedColorMode.noColor, "1", 1 as Int32, "xterm-256color", expect: UsedColorMode.noColor)
            args(      UserDesignatedColorMode.noColor, "1", 1 as Int32,           "dumb", expect: UsedColorMode.noColor)

            args(UserDesignatedColorMode.noDesignation, "0", 0 as Int32, "xterm-256color", expect: UsedColorMode.noColor)
            args(UserDesignatedColorMode.noDesignation, "0", 0 as Int32,           "dumb", expect: UsedColorMode.noColor)
            args(UserDesignatedColorMode.noDesignation, "0", 1 as Int32, "xterm-256color", expect:   UsedColorMode.color)
            args(UserDesignatedColorMode.noDesignation, "0", 1 as Int32,           "dumb", expect: UsedColorMode.noColor)
            args(UserDesignatedColorMode.noDesignation, "1", 0 as Int32, "xterm-256color", expect: UsedColorMode.noColor)
            args(UserDesignatedColorMode.noDesignation, "1", 0 as Int32,           "dumb", expect: UsedColorMode.noColor)
            args(UserDesignatedColorMode.noDesignation, "1", 1 as Int32, "xterm-256color", expect: UsedColorMode.noColor)
            args(UserDesignatedColorMode.noDesignation, "1", 1 as Int32,           "dumb", expect: UsedColorMode.noColor)

            args(    UserDesignatedColorMode.forceAuto, "0", 0 as Int32, "xterm-256color", expect: UsedColorMode.noColor)
            args(    UserDesignatedColorMode.forceAuto, "0", 0 as Int32,           "dumb", expect: UsedColorMode.noColor)
            args(    UserDesignatedColorMode.forceAuto, "0", 1 as Int32, "xterm-256color", expect:   UsedColorMode.color)
            args(    UserDesignatedColorMode.forceAuto, "0", 1 as Int32,           "dumb", expect: UsedColorMode.noColor)
            args(    UserDesignatedColorMode.forceAuto, "1", 0 as Int32, "xterm-256color", expect: UsedColorMode.noColor)
            args(    UserDesignatedColorMode.forceAuto, "1", 0 as Int32,           "dumb", expect: UsedColorMode.noColor)
            args(    UserDesignatedColorMode.forceAuto, "1", 1 as Int32, "xterm-256color", expect:   UsedColorMode.color)
            args(    UserDesignatedColorMode.forceAuto, "1", 1 as Int32,           "dumb", expect: UsedColorMode.noColor)
            // swiftlint:enable comma colon
        }
    }

    override func setUp() {
        ParameterizedTest.option = ParameterizedTest.Option(
            traceTable: .markdown,
            saveTableToAttachement: .markdown
        )
    }
}
