import XCTest
@testable import DinoHatch

final class AlarmNextFireDateTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    /// July 6, 2026 is a Monday (weekday == 2) — same reference week as
    /// `AlarmStreakTests`.
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
    }

    func testEmptyWeekdaysReturnsNil() {
        let next = AlarmNextFireDate.next(hour: 7, minute: 0, weekdays: [], now: date(day: 6), calendar: calendar)
        XCTAssertNil(next)
    }

    func testLaterTodayReturnsToday() {
        let now = date(day: 6, hour: 6, minute: 0) // Monday 6:00am
        let next = AlarmNextFireDate.next(hour: 7, minute: 0, weekdays: [1, 2, 3, 4, 5, 6, 7], now: now, calendar: calendar)
        XCTAssertEqual(next, date(day: 6, hour: 7, minute: 0))
    }

    func testPastTimeTodayRollsToTomorrow() {
        let now = date(day: 6, hour: 8, minute: 0) // Monday 8:00am, alarm was 7:00am
        let next = AlarmNextFireDate.next(hour: 7, minute: 0, weekdays: [1, 2, 3, 4, 5, 6, 7], now: now, calendar: calendar)
        XCTAssertEqual(next, date(day: 7, hour: 7, minute: 0))
    }

    func testWeekdayOnlyAlarmSkipsWeekend() {
        let weekdaysOnly = [2, 3, 4, 5, 6] // Mon...Fri
        let now = date(day: 10, hour: 8, minute: 0) // Friday, after 7am
        let next = AlarmNextFireDate.next(hour: 7, minute: 0, weekdays: weekdaysOnly, now: now, calendar: calendar)
        XCTAssertEqual(next, date(day: 13, hour: 7, minute: 0)) // next Monday
    }

    func testExactlyAtFireTimeCountsAsPassed() {
        let now = date(day: 6, hour: 7, minute: 0) // exactly 7:00am
        let next = AlarmNextFireDate.next(hour: 7, minute: 0, weekdays: [2], now: now, calendar: calendar)
        XCTAssertEqual(next, date(day: 13, hour: 7, minute: 0)) // next Monday, not today
    }
}
