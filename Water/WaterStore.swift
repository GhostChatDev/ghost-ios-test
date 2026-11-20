import Foundation
import Observation

struct Drink: Codable, Identifiable, Equatable {
    var id = UUID()
    var date: Date
    var ml: Int
}

struct DayTotal: Identifiable, Equatable {
    let day: Date
    let ml: Int
    var id: Date { day }
}

@Observable
final class WaterStore {
    static let defaultGoal = 2000
    static let drinksKey = "water.drinks"
    static let goalKey = "water.goal"

    private(set) var drinks: [Drink]
    private(set) var goal: Int

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let calendar: Calendar

    init(defaults: UserDefaults = .standard, calendar: Calendar = .current) {
        self.defaults = defaults
        self.calendar = calendar
        if let data = defaults.data(forKey: Self.drinksKey),
           let saved = try? JSONDecoder().decode([Drink].self, from: data) {
            drinks = saved
        } else {
            drinks = []
        }
        let savedGoal = defaults.integer(forKey: Self.goalKey)
        goal = savedGoal > 0 ? savedGoal : Self.defaultGoal
    }

    /// Store used by the app. With the "-uitest" launch argument it starts from a clean, throw-away
    /// store holding one drink, so the click test always sees the same screen.
    static func forLaunch(arguments: [String] = ProcessInfo.processInfo.arguments) -> WaterStore {
        guard arguments.contains("-uitest"), let suite = UserDefaults(suiteName: "water.uitest") else {
            return WaterStore()
        }
        suite.removePersistentDomain(forName: "water.uitest")
        let store = WaterStore(defaults: suite)
        store.add(250)
        return store
    }

    // MARK: - Reading

    func drinks(on day: Date) -> [Drink] {
        drinks.filter { calendar.isDate($0.date, inSameDayAs: day) }.sorted { $0.date < $1.date }
    }

    func total(on day: Date) -> Int {
        drinks(on: day).reduce(0) { $0 + $1.ml }
    }

    func progress(on day: Date) -> Double {
        min(1, Double(total(on: day)) / Double(max(goal, 1)))
    }

    /// Totals for the `days` days ending on `now`, oldest first.
    func lastDays(_ days: Int = 7, endingAt now: Date = .now) -> [DayTotal] {
        let today = calendar.startOfDay(for: now)
        return (0..<days).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return DayTotal(day: day, ml: total(on: day))
        }
    }

    // MARK: - Changing

    func add(_ ml: Int, at date: Date = .now) {
        guard ml > 0 else { return }
        drinks.append(Drink(date: date, ml: ml))
        save()
    }

    /// Removes the most recent drink of `day`. Returns false if there was none.
    @discardableResult
    func undoLast(on day: Date = .now) -> Bool {
        guard let last = drinks(on: day).last,
              let index = drinks.firstIndex(where: { $0.id == last.id }) else { return false }
        drinks.remove(at: index)
        save()
        return true
    }

    func setGoal(_ ml: Int) {
        goal = min(max(ml, 250), 10000)
        defaults.set(goal, forKey: Self.goalKey)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(drinks) {
            defaults.set(data, forKey: Self.drinksKey)
        }
    }
}
