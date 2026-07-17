import XCTest
@testable import DinoHatch

final class XRayEligibilityTests: XCTestCase {
    func testLockedWhenAgeNotSet() {
        XCTAssertFalse(XRayEligibility.isUnlocked(childAge: nil, totalHatched: 5))
    }

    func testLockedWhenUnderMinimumAge() {
        XCTAssertFalse(XRayEligibility.isUnlocked(childAge: 5, totalHatched: 5))
    }

    func testLockedWhenBelowHatchCountEvenIfOldEnough() {
        XCTAssertFalse(XRayEligibility.isUnlocked(childAge: 10, totalHatched: 1))
    }

    func testUnlockedAtExactThresholds() {
        XCTAssertTrue(XRayEligibility.isUnlocked(childAge: 6, totalHatched: 2))
    }

    func testUnlockedWellPastThresholds() {
        XCTAssertTrue(XRayEligibility.isUnlocked(childAge: 9, totalHatched: 12))
    }
}
