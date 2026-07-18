import XCTest
@testable import DinoHatch

final class XRayEligibilityTests: XCTestCase {
    func testLockedWhenAgeNotSet() {
        XCTAssertFalse(XRayEligibility.isUnlocked(childAge: nil, totalHatched: 5))
    }

    func testYoungChildLockedBeforeAnyHatch() {
        XCTAssertFalse(XRayEligibility.isUnlocked(childAge: 5, totalHatched: 0))
    }

    func testYoungChildUnlockedAfterFirstHatch() {
        XCTAssertTrue(XRayEligibility.isUnlocked(childAge: 5, totalHatched: 1))
    }

    func testYoungChildStaysUnlockedWellPastFirstHatch() {
        XCTAssertTrue(XRayEligibility.isUnlocked(childAge: 1, totalHatched: 8))
    }

    func testOlderChildLockedBelowHatchCountEvenIfOldEnough() {
        XCTAssertFalse(XRayEligibility.isUnlocked(childAge: 10, totalHatched: 1))
    }

    func testOlderChildUnlockedAtExactThreshold() {
        XCTAssertTrue(XRayEligibility.isUnlocked(childAge: 6, totalHatched: 2))
    }

    func testOlderChildUnlockedWellPastThreshold() {
        XCTAssertTrue(XRayEligibility.isUnlocked(childAge: 9, totalHatched: 12))
    }

    func testAgeThresholdBoundary() {
        // Age 5 uses the younger, easier threshold (1 hatch); age 6 needs 2.
        XCTAssertTrue(XRayEligibility.isUnlocked(childAge: 5, totalHatched: 1))
        XCTAssertFalse(XRayEligibility.isUnlocked(childAge: 6, totalHatched: 1))
    }
}
