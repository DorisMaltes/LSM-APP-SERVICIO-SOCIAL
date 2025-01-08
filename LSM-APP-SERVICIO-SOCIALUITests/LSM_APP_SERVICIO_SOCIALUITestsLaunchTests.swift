//
//  LSM_APP_SERVICIO_SOCIALUITestsLaunchTests.swift
//  LSM-APP-SERVICIO-SOCIALUITests
//
//  Created by Doris Elena  on 07/01/25.
//

import XCTest

final class LSM_APP_SERVICIO_SOCIALUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
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
