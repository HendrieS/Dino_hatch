import XCTest
@testable import DinoHatch

final class QuickStartLinkTests: XCTestCase {
    func testRoundTripsEveryAllowedDuration() {
        for minutes in QuickStartLink.allowedMinutes {
            let url = QuickStartLink.url(forMinutes: minutes)
            XCTAssertEqual(QuickStartLink.minutes(from: url), minutes)
        }
    }

    func testRejectsUnsupportedDuration() {
        let url = URL(string: "dinohatch://start-timer?minutes=7")!
        XCTAssertNil(QuickStartLink.minutes(from: url))
    }

    func testRejectsWrongScheme() {
        let url = URL(string: "https://start-timer?minutes=5")!
        XCTAssertNil(QuickStartLink.minutes(from: url))
    }

    func testRejectsWrongHost() {
        let url = URL(string: "dinohatch://something-else?minutes=5")!
        XCTAssertNil(QuickStartLink.minutes(from: url))
    }

    func testRejectsMissingMinutes() {
        let url = URL(string: "dinohatch://start-timer")!
        XCTAssertNil(QuickStartLink.minutes(from: url))
    }

    func testRejectsNonNumericMinutes() {
        let url = URL(string: "dinohatch://start-timer?minutes=abc")!
        XCTAssertNil(QuickStartLink.minutes(from: url))
    }
}
