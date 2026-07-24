import Foundation
import SwiftData

/// Single-row settings record for the dino alarm. `repeatWeekdays` uses
/// `Calendar`'s convention (1 = Sunday ... 7 = Saturday) so it maps
/// directly onto `DateComponents.weekday` for scheduling notifications.
///
/// `lastHatchDate` guards against claiming more than one alarm reward on
/// the same calendar day — see `AlarmClaimer`.
@Model
final class AlarmSettings {
    var isEnabled: Bool = false
    var hour: Int = 7
    var minute: Int = 0
    var repeatWeekdays: [Int] = []
    var lastHatchDate: Date?
    /// Consecutive scheduled alarms claimed in a row — see `AlarmStreak`.
    /// Not tied to literal calendar days, since the alarm might only be set
    /// for a subset of weekdays (e.g. weekdays only); missing a day that
    /// isn't even selected shouldn't break the streak.
    var streakCount: Int = 0

    init() {}
}
