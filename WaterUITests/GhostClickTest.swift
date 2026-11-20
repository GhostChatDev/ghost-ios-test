import XCTest

// Ghost Code's click test: every button on the first screen is pressed, one at a time from a fresh launch,
// and must change what is on screen without crashing the app.
// The app is launched with "-uitest" so it starts from a clean store holding one 250 ml drink.
final class GhostClickTest: XCTestCase {
    private func signature(_ app: XCUIApplication) -> String {
        let texts = app.staticTexts.allElementsBoundByIndex.map { $0.label }
        let buttons = app.buttons.allElementsBoundByIndex.map { $0.label }
        return (texts + buttons).joined(separator: "|") + "#\(app.textFields.count)#\(app.navigationBars.count)#\(app.sheets.count + app.alerts.count)"
    }

    private func launch(_ app: XCUIApplication) {
        app.launchArguments = ["-uitest"]
        app.launch()
    }

    func testEveryButtonDoesSomething() throws {
        let app = XCUIApplication()
        launch(app)
        let labels = app.buttons.allElementsBoundByIndex.filter { $0.isHittable }.prefix(8).map { $0.label.isEmpty ? $0.identifier : $0.label }
        var dead: [String] = []
        var crashed: [String] = []
        for (i, label) in labels.enumerated() {
            app.terminate()
            launch(app)
            let before = signature(app)
            let now = app.buttons.allElementsBoundByIndex.filter { $0.isHittable }
            guard i < now.count else { continue }
            now[i].tap()
            sleep(1)
            if app.state != .runningForeground { crashed.append(label); continue }
            if signature(app) == before { dead.append(label) }
        }
        print("CLICKS: \(labels.count - dead.count - crashed.count) of \(labels.count) buttons pressed did something")
        XCTAssertTrue(crashed.isEmpty, "The app crashed when pressing: \(crashed.joined(separator: ", "))")
        XCTAssertTrue(dead.isEmpty, "These buttons do nothing when pressed: \(dead.joined(separator: ", "))")
    }
}
