import Foundation

/// Pure "when does the alarm next fire" calculation — the mirror image of
/// `AlarmStreak.previousScheduledDay`, but looking forward instead of back.
/// `AlarmScheduler` never needs this itself (it hands `weekday`-matching
/// `DateComponents` to `UNCalendarNotificationTrigger` and lets iOS resolve
/// the actual next date), but the widget's live countdown needs a concrete
/// `Date` to hand to `Text(_:style: .timer)`.
enum AlarmNextFireDate {
    /// Bounded to a week of lookahead (inclusive of today) since `weekdays`
    /// can't repeat less often than that — returns `nil` only if `weekdays`
    /// is empty.
    static func next(hour: Int, minute: Int, weekdays: [Int], now: Date = .now, calendar: Calendar = .current) -> Date? {
        guard !weekdays.isEmpty else { return nil }
        for dayOffset in 0...7 {
            guard let candidateDay = calendar.date(byAdding: .day, value: dayOffset, to: now),
                  weekdays.contains(calendar.component(.weekday, from: candidateDay)),
                  let candidate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: candidateDay),
                  candidate > now else { continue }
            return candidate
        }
        return nil
    }
}
