import XCTest
@testable import Water

final class WaterStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private let suite = "water.tests"

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suite)
        defaults.removePersistentDomain(forName: suite)
    }

    func testDefaultGoalIs2000() {
        XCTAssertEqual(WaterStore(defaults: defaults).goal, 2000)
    }

    func testAddAndTotal() {
        let store = WaterStore(defaults: defaults)
        store.add(250)
        store.add(500)
        XCTAssertEqual(store.total(on: .now), 750)
        XCTAssertEqual(store.progress(on: .now), 0.375, accuracy: 0.0001)
    }

    func testProgressIsCappedAtOne() {
        let store = WaterStore(defaults: defaults)
        for _ in 0..<5 { store.add(500) }
        XCTAssertEqual(store.progress(on: .now), 1)
    }

    func testUndoRemovesLatestOnly() {
        let store = WaterStore(defaults: defaults)
        store.add(250, at: Date().addingTimeInterval(-60))
        store.add(500)
        XCTAssertTrue(store.undoLast())
        XCTAssertEqual(store.total(on: .now), 250)
        XCTAssertTrue(store.undoLast())
        XCTAssertFalse(store.undoLast())
    }

    func testDataSurvivesRestart() {
        let first = WaterStore(defaults: defaults)
        first.add(250)
        first.setGoal(2500)
        let second = WaterStore(defaults: defaults)
        XCTAssertEqual(second.total(on: .now), 250)
        XCTAssertEqual(second.goal, 2500)
    }

    func testLastSevenDays() {
        let store = WaterStore(defaults: defaults)
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        store.add(300, at: yesterday)
        store.add(250, at: now)
        let days = store.lastDays(7, endingAt: now)
        XCTAssertEqual(days.count, 7)
        XCTAssertEqual(days.last?.ml, 250)
        XCTAssertEqual(days[5].ml, 300)
        XCTAssertEqual(days.first?.ml, 0)
    }

    func testGoalIsClamped() {
        let store = WaterStore(defaults: defaults)
        store.setGoal(1)
        XCTAssertEqual(store.goal, 250)
        store.setGoal(999_999)
        XCTAssertEqual(store.goal, 10000)
    }
}
