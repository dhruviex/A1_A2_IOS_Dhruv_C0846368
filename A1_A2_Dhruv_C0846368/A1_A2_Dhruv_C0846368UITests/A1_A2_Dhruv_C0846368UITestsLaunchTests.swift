//
//  A1_A2_Dhruv_C0846368UITestsLaunchTests.swift
//  A1_A2_Dhruv_C0846368UITests
//
//  Created by Dhruv Bakshi on 2022-05-24.
//

import XCTest

class A1_A2_Dhruv_C0846368UITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}