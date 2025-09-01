import Foundation

/// Streaks utility for daily calorie targets.
/// Counts a day as "success" if it meets the rule (by default: intake <= goal).
enum StreakRule {
    case atOrBelowGoal
    case atOrAboveGoal

    func isSuccess(intake: Int, goal: Int) -> Bool {
        switch self {
        case .atOrBelowGoal: return intake <= goal
        case .atOrAboveGoal: return intake >= goal
        }
    }
}

/// Pre-aggregated daily point (one per day).
struct DailyTotal: Identifiable, Hashable {
    let date: Date            // normalized to startOfDay
    let kcal: Int

    var id: Date { date }

    init(date: Date, kcal: Int) {
        self.date = Calendar.current.startOfDay(for: date)
        self.kcal = max(0, kcal)
    }
}

/// Result of streak computation.
struct Streaks: Equatable {
    let current: Int   // consecutive success days counting back from the last point
    let best: Int      // best (max) consecutive success segment across all points
    let evaluatedDays: Int
}

/// Calculates streaks over a set of days.
/// IMPORTANT: Streaks are computed over the provided points only (no implicit gap-filling).
/// If you need gaps (missing days) to *break* the current streak, make sure you pass a
/// continuous range of days (e.g., produce points for each calendar day).
enum StreaksCalculator {

    /// Compute streaks from daily totals.
    /// - Parameters:
    ///   - points: Array of `DailyTotal` (can be unsorted or contain duplicate dates).
    ///   - goal: Daily goal in kcal. If `goal <= 0`, returns zeros.
    ///   - rule: Success rule (defaults to `.atOrBelowGoal`).
    static func compute(points: [DailyTotal], goal: Int, rule: StreakRule = .atOrBelowGoal) -> Streaks {
        guard goal > 0 else { return Streaks(current: 0, best: 0, evaluatedDays: 0) }

        // 1) Collapse duplicates by date (sum kcal within same day)
        let collapsed = collapse(points: points)

        // 2) Sort by date ascending
        let sorted = collapsed.sorted { $0.date < $1.date }

        // 3) Map to success flags
        let success = sorted.map { rule.isSuccess(intake: $0.kcal, goal: goal) }

        // 4) Best streak (max consecutive successes)
        var best = 0
        var run = 0
        for ok in success {
            run = ok ? (run + 1) : 0
            if run > best { best = run }
        }

        // 5) Current streak (from end)
        var current = 0
        for ok in success.reversed() {
            if ok { current += 1 } else { break }
        }

        return Streaks(current: current, best: best, evaluatedDays: sorted.count)
    }

    /// Build daily totals from any sequence using closures to read date & kcal.
    /// This avoids depending on your concrete `Meal` model.
    static func dailyTotals<S: Sequence>(
        from items: S,
        date dateProvider: (S.Element) -> Date,
        kcal kcalProvider: (S.Element) -> Int
    ) -> [DailyTotal] {
        var byDay: [Date: Int] = [:]
        let cal = Calendar.current
        for item in items {
            let d = cal.startOfDay(for: dateProvider(item))
            let v = max(0, kcalProvider(item))
            byDay[d, default: 0] += v
        }
        return byDay.map { DailyTotal(date: $0.key, kcal: $0.value) }
    }

    // MARK: - Internals

    private static func collapse(points: [DailyTotal]) -> [DailyTotal] {
        var map: [Date: Int] = [:]
        for p in points {
            map[p.date, default: 0] += p.kcal
        }
        return map.map { DailyTotal(date: $0.key, kcal: $0.value) }
    }
}
