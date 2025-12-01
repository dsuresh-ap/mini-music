//
//  Mini_MusicUITests.swift
//  Mini MusicUITests
//
//  Created by Dhananjay Suresh on 10/5/25.
//

import XCTest

final class Mini_MusicUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - Tests

    func testSelectingTrackShowsFullScreenThenMiniPlayer() {
        let app = launchFixturesApp()

        tapFirstTrack(in: app)

        let fullPlayer = app.otherElements["fullScreenPlayer"]
        XCTAssertTrue(fullPlayer.waitForExistence(timeout: 3))

        app.buttons["player.closeButton"].tap()

        XCTAssertFalse(fullPlayer.waitForExistence(timeout: 1))
        XCTAssertTrue(app.otherElements["miniPlayer"].waitForExistence(timeout: 2))
    }

    func testMiniPlayerExpandsToFullScreen() {
        let app = launchFixturesApp()
        tapFirstTrack(in: app)

        app.buttons["player.closeButton"].tap()

        let miniPlayer = app.otherElements["miniPlayer"]
        XCTAssertTrue(miniPlayer.waitForExistence(timeout: 2))

        miniPlayer.tap()

        XCTAssertTrue(app.otherElements["fullScreenPlayer"].waitForExistence(timeout: 2))
    }

    func testPlayPauseButtonTogglesState() {
        let app = launchFixturesApp()
        tapFirstTrack(in: app)

        let pauseButton = app.buttons["Pause"]
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 2))
        pauseButton.tap()

        let playButton = app.buttons["Play"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 2))
        playButton.tap()

        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 2))
    }

    func testSwipeDownDismissesFullScreen() {
        let app = launchFixturesApp()
        tapFirstTrack(in: app)

        let fullPlayer = app.otherElements["fullScreenPlayer"]
        XCTAssertTrue(fullPlayer.waitForExistence(timeout: 2))

        fullPlayer.swipeDown()

        XCTAssertFalse(fullPlayer.waitForExistence(timeout: 1))
        XCTAssertTrue(app.otherElements["miniPlayer"].waitForExistence(timeout: 2))
    }

    // MARK: - Helpers

    private func launchFixturesApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("--uitest-fixtures")
        app.launch()
        return app
    }

    private func tapFirstTrack(in app: XCUIApplication) {
        let trackTile = app.otherElements["track-fixture-1"]
        XCTAssertTrue(trackTile.waitForExistence(timeout: 5))
        trackTile.tap()
    }
}
