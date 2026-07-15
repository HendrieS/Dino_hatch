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
}
