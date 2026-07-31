import XCTest
@testable import DinoHatch

final class SupporterTierTests: XCTestCase {
    func testProductIDsAreUnique() {
        let ids = SupporterTier.allCases.map(\.productID)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    func testProductIDsShareTheAppBundleIDPrefix() {
        for tier in SupporterTier.allCases {
            XCTAssertTrue(tier.productID.hasPrefix("com.dinohatchtimer.app.support."))
        }
    }

    func testInitFromKnownProductIDRoundTrips() {
        for tier in SupporterTier.allCases {
            XCTAssertEqual(SupporterTier(productID: tier.productID), tier)
        }
    }

    func testInitFromUnknownProductIDReturnsNil() {
        XCTAssertNil(SupporterTier(productID: "com.dinohatchtimer.app.support.diamond"))
        XCTAssertNil(SupporterTier(productID: ""))
    }

    func testTiersAreOrderedByAscendingRarity() {
        XCTAssertLessThan(SupporterTier.gray, SupporterTier.green)
        XCTAssertLessThan(SupporterTier.green, SupporterTier.gold)
        XCTAssertLessThan(SupporterTier.gold, SupporterTier.purple)
    }

    func testHighestOwnedTierPicksMax() {
        let owned: [SupporterTier] = [.gray, .purple, .green]
        XCTAssertEqual(owned.max(), .purple)
    }
}
