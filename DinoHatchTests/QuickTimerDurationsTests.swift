import XCTest
@testable import DinoHatch

final class QuickTimerDurationsTests: XCTestCase {
    func testAllowedDurationsMatchTheWidgetButtons() {
        XCTAssertEqual(QuickTimerDurations.allowedMinutes, [5, 10, 15, 30])
    }
}
