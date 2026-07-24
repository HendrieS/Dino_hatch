import Foundation

/// Pure streak-counting logic for the dino alarm, kept independent of
/// SwiftData/UI for the same reasons as `AlarmClaimer`. A "streak" counts
/// consecutive *scheduled* occurrences claimed in a row, not literal
/// calendar days — an alarm set for weekdays only shouldn't have its
/// streak broken by a weekend it was never going to fire on.
enum AlarmStreak {
    /// Call this at the moment a claim happens, with the *previous*
    /// `lastHatchDate` (before it gets overwritten) and the streak so far.
    static func nextStreak(
        currentStreak: Int,
        lastHatchDate: Date?,
        weekdays: [Int],
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Int {
        guard let lastHatchDate else { return 1 }
        guard let previous = previousScheduledDay(before: now, weekdays: weekdays, calendar: calendar) else {
            return 1
        }
        guard calendar.isDate(lastHatchDate, inSameDayAs: previous) else { return 1 }
        return currentStreak + 1
    }

    /// Walks backward from `date` (exclusive) to find the most recent day
    /// whose weekday is in `weekdays` — the alarm's previous scheduled
    /// occurrence before now, however many calendar days back that was.
    /// Bounded to a week of lookback since `weekdays` can't repeat faster
    /// than that.
    private static func previousScheduledDay(before date: Date, weekdays: [Int], calendar: Calendar) -> Date? {
        guard !weekdays.isEmpty else { return nil }
        var candidate = date
        for _ in 0..<7 {
            guard let dayBefore = calendar.date(byAdding: .day, value: -1, to: candidate) else { return nil }
            candidate = dayBefore
            if weekdays.contains(calendar.component(.weekday, from: candidate)) {
                return candidate
            }
        }
        return nil
    }
}
