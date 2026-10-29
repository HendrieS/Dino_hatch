import XCTest
@testable import DinoHatch

final class CollectionCompleteGateTests: XCTestCase {
    private let allIDs = Set(DinosaurCatalog.all.map(\.id))
    private let regularIDs = Set(DinosaurCatalog.all.filter { !$0.isSecret }.map(\.id))
    private let regularCount = DinosaurCatalog.all.filter { !$0.isSecret }.count

    private func milestone(
        _ unlockedIDs: Set<String>,
        lastCatalogSize: Int? = nil,
        lastRegularCount: Int? = nil
    ) -> CollectionCompleteGate.Milestone? {
        CollectionCompleteGate.milestoneToCelebrate(
            unlockedIDs: unlockedIDs,
            lastCelebratedCatalogSize: lastCatalogSize,
            lastCelebratedRegularCount: lastRegularCount
        )
    }

    func testNothingWhileARegularDinosaurIsStillLocked() {
        XCTAssertNil(milestone(Set(regularIDs.dropFirst())))
    }

    func testAllRegularOnceEveryRegularDinosaurIsHatched() {
        XCTAssertEqual(milestone(regularIDs), .allRegular)
    }

    func testAllRegularOnlyOnce() {
        XCTAssertNil(milestone(regularIDs, lastRegularCount: regularCount))
    }

    func testAllRegularStillShownWithSomeSecretsFound() {
        let secretIDs = allIDs.subtracting(regularIDs)
        let unlockedIDs = regularIDs.union(secretIDs.prefix(1))
        XCTAssertEqual(milestone(unlockedIDs), .allRegular)
    }

    func testEverythingOnceTheWholeCatalogIsHatched() {
        XCTAssertEqual(milestone(allIDs, lastRegularCount: regularCount), .everything)
    }

    func testHatchingEverythingAtOnceSkipsStraightToEverything() {
        XCTAssertEqual(milestone(allIDs), .everything)
    }

    func testEverythingOnlyOnce() {
        XCTAssertNil(milestone(allIDs, lastCatalogSize: allIDs.count, lastRegularCount: regularCount))
    }

    func testNoTeaserForSomeoneWhoAlreadyCelebratedEverything() {
        // An install that finished the collection before the all-regular
        // celebration existed has no lastRegularCount yet — it shouldn't
        // get a "secret dinosaurs are still hiding" teaser now.
        XCTAssertNil(milestone(allIDs, lastCatalogSize: allIDs.count))
    }

    func testEverythingAgainAfterTheCatalogGrows() {
        XCTAssertEqual(milestone(allIDs, lastCatalogSize: allIDs.count - 3, lastRegularCount: regularCount), .everything)
    }

    func testUnknownIDsDoNotCountTowardCompletion() {
        // A record for a dinosaur no longer in the catalog shouldn't stand in
        // for a missing one, even though the total count matches.
        let unlockedIDs = Set(allIDs.dropFirst()).union(["retired-dinosaur"])
        XCTAssertEqual(unlockedIDs.count, allIDs.count)
        XCTAssertNotEqual(milestone(unlockedIDs), .everything)
    }
}
