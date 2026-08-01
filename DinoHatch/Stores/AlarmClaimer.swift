import Foundation

/// Pure claim logic, deliberately independent of `UNUserNotificationCenter`
/// and SwiftData: the app can't run custom code at the exact moment a
/// background notification fires, so instead we check, every time the app
/// becomes active, whether "now" is within the response window of today's
/// alarm time on a selected weekday and no reward has been claimed yet
/// today. This means the reward still works even if the user never taps
/// the notification banner, and even if notification permission was
/// denied entirely — but unlike a plain "any time after the alarm" check,
/// missing the window means no dinosaur until the alarm's next scheduled
/// occurrence, encouraging an actual prompt response rather than opening
/// the app hours later.
enum AlarmClaimer {
    /// How long after the scheduled alarm time the reward stays claimable.
    static let responseWindow: TimeInterval = 15 * 60

    static func isReady(
        hour: Int,
        minute: Int,
        weekdays: [Int],
        lastHatchDate: Date?,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Bool {
        guard weekdays.contains(calendar.component(.weekday, from: now)) else { return false }
        guard let alarmTimeToday = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now) else {
            return false
        }
        guard now >= alarmTimeToday else { return false }
        guard now <= alarmTimeToday.addingTimeInterval(responseWindow) else { return false }
        if let lastHatchDate, calendar.isDate(lastHatchDate, inSameDayAs: now) {
            return false
        }
        return true
    }

    /// True once today's response window has closed without a claim — used
    /// purely for the sad-dino status art on `AlarmView`, not for gating the
    /// reward itself (that stays `isReady`'s job).
    ///
    /// - Parameter enabledAt: when the alarm was last turned on (see
    ///   `AlarmSettings.enabledAt`). If the alarm was only armed after
    ///   today's window had already closed, there was never a real chance
    ///   to claim it — that's not a miss, see `isPendingFirstChance`.
    static func wasMissedToday(
        hour: Int,
        minute: Int,
        weekdays: [Int],
        lastHatchDate: Date?,
        enabledAt: Date? = nil,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Bool {
        guard weekdays.contains(calendar.component(.weekday, from: now)) else { return false }
        guard let alarmTimeToday = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now) else {
            return false
        }
        guard now > alarmTimeToday.addingTimeInterval(responseWindow) else { return false }
        if let lastHatchDate, calendar.isDate(lastHatchDate, inSameDayAs: now) {
            return false
        }
        if let enabledAt, enabledAt > alarmTimeToday.addingTimeInterval(responseWindow) {
            return false
        }
        return true
    }

    /// True the first time today's window closes after the alarm was armed
    /// too late to catch it — the flip side of `wasMissedToday`'s
    /// `enabledAt` guard. Drives an encouraging "get ready for tomorrow"
    /// message instead of the sad "missed it" one, since there was nothing
    /// to actually miss.
    static func isPendingFirstChance(
        hour: Int,
        minute: Int,
        weekdays: [Int],
        lastHatchDate: Date?,
        enabledAt: Date?,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Bool {
        guard let enabledAt else { return false }
        guard weekdays.contains(calendar.component(.weekday, from: now)) else { return false }
        guard let alarmTimeToday = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now) else {
            return false
        }
        guard now > alarmTimeToday.addingTimeInterval(responseWindow) else { return false }
        guard enabledAt > alarmTimeToday.addingTimeInterval(responseWindow) else { return false }
        if let lastHatchDate, calendar.isDate(lastHatchDate, inSameDayAs: now) {
            return false
        }
        return true
    }

    /// True when today isn't one of the alarm's scheduled weekdays at all,
    /// so there was never a window to catch or miss today — the case
    /// `wasMissedToday`/`isPendingFirstChance` don't cover, since both are
    /// specifically about *today's* window and return `false` outright when
    /// today isn't selected. Drives the same "get ready" messaging as
    /// `isPendingFirstChance`, just for the opposite reason (nothing
    /// scheduled today vs. armed too late for today), so which weekday
    /// happens to include "today" doesn't make the message flicker in and
    /// out as someone edits the weekday picker.
    static func isTodayUnscheduled(
        weekdays: [Int],
        lastHatchDate: Date?,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Bool {
        guard !weekdays.isEmpty else { return false }
        if let lastHatchDate, calendar.isDate(lastHatchDate, inSameDayAs: now) {
            return false
        }
        return !weekdays.contains(calendar.component(.weekday, from: now))
    }
}
