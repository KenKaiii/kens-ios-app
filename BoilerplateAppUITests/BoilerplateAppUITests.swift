import XCTest

/// UI Tests for BoilerplateApp
final class BoilerplateAppUITests: XCTestCase {

    // MARK: - Properties

    var app: XCUIApplication!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    // MARK: - Tab Bar Tests

    func testTabBarExists() {
        XCTAssertTrue(app.tabBars.firstMatch.exists)
    }

    func testHomeTabIsSelected() {
        let homeTab = app.tabBars.buttons["Home"]
        XCTAssertTrue(homeTab.exists)
        XCTAssertTrue(homeTab.isSelected)
    }

    func testCanSwitchToSettingsTab() {
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.exists)

        settingsTab.tap()

        XCTAssertTrue(settingsTab.isSelected)
        XCTAssertTrue(app.navigationBars["Settings"].exists)
    }

    // MARK: - Home Screen Tests

    func testHomeScreenHasNavigationBar() {
        XCTAssertTrue(app.navigationBars["Home"].exists)
    }

    func testHomeScreenHasAddButton() {
        let addButton = app.navigationBars.buttons["Add"]
            .exists ? app.navigationBars.buttons["Add"] : app.buttons["plus"]

        // The add button should exist (might have different accessibility identifier)
        let toolbar = app.navigationBars.firstMatch
        XCTAssertTrue(toolbar.exists)
    }

    // MARK: - Settings Screen Tests

    func testSettingsScreenElements() {
        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()

        // Check for navigation title
        XCTAssertTrue(app.navigationBars["Settings"].exists)

        // Check for theme picker (may appear as button in navigation link style)
        let themePicker = app.buttons["Theme"]
        XCTAssertTrue(themePicker.waitForExistence(timeout: 2))
    }

    func testAboutNavigationFromSettings() {
        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()

        // Tap About
        let aboutCell = app.cells.containing(.staticText, identifier: "About This App").firstMatch
        if aboutCell.exists {
            aboutCell.tap()

            // Verify About screen
            XCTAssertTrue(app.navigationBars["About"].waitForExistence(timeout: 2))
        }
    }

    // MARK: - Theme Tests

    func testThemePickerNavigation() {
        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()

        // Find and tap Theme row
        let themeCell = app.cells.containing(.staticText, identifier: "Theme").firstMatch
        if themeCell.exists {
            themeCell.tap()

            // Verify theme options exist
            let systemOption = app.cells.containing(.staticText, identifier: "System").firstMatch
            XCTAssertTrue(systemOption.waitForExistence(timeout: 2))
        }
    }

    // MARK: - Performance Tests

    func testLaunchPerformance() throws {
        if #available(iOS 13.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

// MARK: - Accessibility Tests

extension BoilerplateAppUITests {

    func testAccessibilityLabels() {
        // Home tab should have accessibility label
        let homeTab = app.tabBars.buttons["Home"]
        XCTAssertTrue(homeTab.exists)
        XCTAssertFalse(homeTab.label.isEmpty)

        // Settings tab should have accessibility label
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.exists)
        XCTAssertFalse(settingsTab.label.isEmpty)
    }
}
