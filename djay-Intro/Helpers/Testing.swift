//
//  Testing.swift
//  djay-Intro
//
//  Created by David James on 25/02/2026.
//

import Foundation

/// Use this to determine that the current process is part of a test pass
func isTestingEnvironment() -> Bool {
    ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
}
