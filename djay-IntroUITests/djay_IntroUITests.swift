//
//  djay_IntroUITests.swift
//  djay-IntroUITests
//
//  Created by David James on 16/02/2026.
//

import XCTest

// Testing scenarios:
// - iPhone SE, iPhone 16 Pro, iPhone 16 Pro Max
// - orientations:
//   - start in portrait
//   - portrait to landscape
//   - portrait to landscape and back
//   - advance step
//   - start in landscape
//   - landscape to portrait
//   - landscape to portrait and back to landscape
//   - advance step


final class djay_IntroUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
