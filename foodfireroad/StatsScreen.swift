import SwiftUI

struct StatsScreen: View {
    @EnvironmentObject var appState: AppState

    // MARK: - Totals (как было)
    private var totalIntake: Int {
        appState.meals.reduce(0) { $0 + $1.kcal }
    }

    private var totalBurn: Int {
        appState.activities.reduce(0) { $0 + $1.kcal }
    }

    // MARK: - Streaks
    private var dailyGoal: Int { appState.settings.dailyKcalGoal }
    private var streaks: Streaks { computeStreaks() }

    var body: some View {
        NavigationStack {
            List {
                // NEW: Streaks section
                Section("Streaks") {
                    HStack {
                        Text("Current")
                        Spacer()
                        Text("\(streaks.current) days")
                            .foregroundStyle(.primary)
                    }
                    HStack {
                        Text("Best")
                        Spacer()
                        Text("\(streaks.best) days")
                            .foregroundStyle(.primary)
                    }
                }

                Section("Overview") {
                    HStack {
                        Text("Total intake")
                        Spacer()
                        Text("\(totalIntake) kcal")
                            .foregroundStyle(.primary)
                    }
                    HStack {
                        Text("Total burn")
                        Spacer()
                        Text("\(totalBurn) kcal")
                            .foregroundStyle(.primary)
                    }
                    HStack {
                        Text("Balance")
                        Spacer()
                        Text("\(totalIntake - totalBurn) kcal")
                            .foregroundColor(totalIntake - totalBurn > 0 ? .red : .green)
                    }
                }

                Section("Top meals") {
                    ForEach(appState.meals.prefix(3)) { meal in
                        Text("\(meal.title) • \(meal.kcal) kcal")
                    }
                }

                Section("Top activities") {
                    ForEach(appState.activities.prefix(3)) { act in
                        Text("\(act.type) • \(act.kcal) kcal")
                    }
                }
            }
            .navigationTitle("Statistics")
        }
    }

    // MARK: - Streaks helpers

    /// Считаем streaks на непрерывном диапазоне дней (от самого раннего дня с записью до сегодняшнего).
    private func computeStreaks() -> Streaks {
        guard dailyGoal > 0 else { return Streaks(current: 0, best: 0, evaluatedDays: 0) }

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        // Собираем все даты приёмов
        let allDates = appState.meals.map { cal.startOfDay(for: $0.date) }
        let start = allDates.min() ?? today
        let days = daysBetweenInclusive(start, today)

        // Суммируем intake по дням
        var map: [Date: Int] = [:]
        for m in appState.meals {
            let d = cal.startOfDay(for: m.date)
            map[d, default: 0] += max(0, m.kcal)
        }

        // Формируем непрерывный ряд DailyTotal (пропущенные дни = 0 ккал, что корректно для цели «≤ goal»)
        let points: [DailyTotal] = days.map { d in
            DailyTotal(date: d, kcal: map[d] ?? 0)
        }

        // Считаем streaks: успешный день — intake <= goal
        return StreaksCalculator.compute(points: points, goal: dailyGoal, rule: .atOrBelowGoal)
    }

    /// Возвращает массив дней от start до end включительно.
    private func daysBetweenInclusive(_ start: Date, _ end: Date) -> [Date] {
        let cal = Calendar.current
        let s = cal.startOfDay(for: start)
        let e = cal.startOfDay(for: end)
        guard s <= e else { return [] }
        var days: [Date] = []
        var d = s
        while d <= e {
            days.append(d)
            d = cal.date(byAdding: .day, value: 1, to: d)!
        }
        return days
    }
}

// MARK: - Previews
#Preview {
    StatsScreen()
        .environmentObject(AppState())
}
