import XCTest
@testable import DinoHatch

final class AlarmStreakTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    /// July 6, 2026 is a Monday (weekday == 2); the week runs Mon(6) Tue(7)
    /// Wed(8) Thu(9) Fri(10) Sat(11) Sun(12), then Mon(13) again — asserted
    /// below so a wrong hand-picked date fails loudly.
    private func date(day: Int, hour: Int = 7, minute: Int = 5) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 7
        components.day = day
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components)!
    }

    override func setUpWithError() throws {
        XCTAssertEqual(calendar.component(.weekday, from: date(day: 6)), 2) // Monday
        XCTAssertEqual(calendar.component(.weekday, from: date(day: 10)), 6) // Friday
        XCTAssertEqual(calendar.component(.weekday, from: date(day: 13)), 2) // Monday
    }

    func testFirstClaimStartsStreakAtOne() {
        let streak = AlarmStreak.nextStreak(
            currentStreak: 0,
            lastHatchDate: nil,
            weekdays: [1, 2, 3, 4, 5, 6, 7],
            now: date(day: 8),
            calendar: calendar
        )
        XCTAssertEqual(streak, 1)
    }

    func testConsecutiveDailyClaimsIncrement() {
        let streak = AlarmStreak.nextStreak(
            currentStreak: 3,
            lastHatchDate: date(day: 7),
            weekdays: [1, 2, 3, 4, 5, 6, 7],
            now: date(day: 8),
            calendar: calendar
        )
        XCTAssertEqual(streak, 4)
    }

    func testGapBreaksStreak() {
        let streak = AlarmStreak.nextStreak(
            currentStreak: 5,
            lastHatchDate: date(day: 6),
            weekdays: [1, 2, 3, 4, 5, 6, 7],
            now: date(day: 8), // skipped July 7
            calendar: calendar
        )
        XCTAssertEqual(streak, 1)
    }

    func testWeekdayOnlyAlarmSkipsWeekendWithoutBreakingStreak() {
        let weekdaysOnly = [2, 3, 4, 5, 6] // Mon...Fri
        let streak = AlarmStreak.nextStreak(
            currentStreak: 4,
            lastHatchDate: date(day: 10), // Friday
            weekdays: weekdaysOnly,
            now: date(day: 13), // Monday — weekend in between was never scheduled
            calendar: calendar
        )
        XCTAssertEqual(streak, 5)
    }

    func testWeekdayOnlyAlarmBreaksIfAScheduledDayIsMissed() {
        let weekdaysOnly = [2, 3, 4, 5, 6] // Mon...Fri
        let streak = AlarmStreak.nextStreak(
            currentStreak: 4,
            lastHatchDate: date(day: 6), // Monday
            weekdays: weekdaysOnly,
            now: date(day: 8), // Wednesday — Tuesday (scheduled) was skipped
            calendar: calendar
        )
        XCTAssertEqual(streak, 1)
    }
}
