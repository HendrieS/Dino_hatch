import XCTest
@testable import DinoHatch

final class AlarmClaimerTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    /// July 8, 2026 is a Wednesday (Calendar.Component.weekday == 4), and
    /// July 9 is a Thursday (== 5) — asserted below so a wrong hand-picked
    /// date fails loudly instead of silently miscalibrating every test.
    private func date(day: Int, hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 7
        components.day = day
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components)!
    }

    override func setUpWithError() throws {
        XCTAssertEqual(calendar.component(.weekday, from: date(day: 8, hour: 12, minute: 0)), 4)
        XCTAssertEqual(calendar.component(.weekday, from: date(day: 9, hour: 12, minute: 0)), 5)
    }

    func testNotReadyWhenWeekdayNotSelected() {
        let now = date(day: 8, hour: 8, minute: 0) // Wednesday (4)
        let ready = AlarmClaimer.isReady(
            hour: 7, minute: 0, weekdays: [2, 3], // Mon, Tue only
            lastHatchDate: nil, now: now, calendar: calendar
        )
        XCTAssertFalse(ready)
    }

    func testNotReadyBeforeAlarmTime() {
        let now = date(day: 8, hour: 6, minute: 59)
        let ready = AlarmClaimer.isReady(
            hour: 7, minute: 0, weekdays: [4],
            lastHatchDate: nil, now: now, calendar: calendar
        )
        XCTAssertFalse(ready)
    }

    func testReadyAtOrAfterAlarmTimeOnSelectedDay() {
        let now = date(day: 8, hour: 7, minute: 15)
        let ready = AlarmClaimer.isReady(
            hour: 7, minute: 0, weekdays: [4],
            lastHatchDate: nil, now: now, calendar: calendar
        )
        XCTAssertTrue(ready)
    }

    func testNotReadyIfAlreadyClaimedToday() {
        let now = date(day: 8, hour: 8, minute: 0)
        let claimedEarlierToday = date(day: 8, hour: 7, minute: 5)
        let ready = AlarmClaimer.isReady(
            hour: 7, minute: 0, weekdays: [4],
            lastHatchDate: claimedEarlierToday, now: now, calendar: calendar
        )
        XCTAssertFalse(ready)
    }

    func testReadyAgainOnANewDay() {
        let now = date(day: 9, hour: 7, minute: 30) // Thursday
        let claimedYesterday = date(day: 8, hour: 7, minute: 5) // Wednesday
        let ready = AlarmClaimer.isReady(
            hour: 7, minute: 0, weekdays: [4, 5],
            lastHatchDate: claimedYesterday, now: now, calendar: calendar
        )
        XCTAssertTrue(ready)
    }
}
