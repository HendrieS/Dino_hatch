import XCTest
@testable import DinoHatch

final class CollectionCompleteGateTests: XCTestCase {
    private let allIDs = Set(DinosaurCatalog.all.map(\.id))

    func testCelebratesOnceEveryDinosaurIsHatched() {
        XCTAssertTrue(CollectionCompleteGate.shouldCelebrate(unlockedIDs: allIDs, lastCelebratedCatalogSize: nil))
    }

    func testDoesNotCelebrateWithAnyDinosaurStillLocked() {
        let unlockedIDs = Set(allIDs.dropFirst())
        XCTAssertFalse(CollectionCompleteGate.shouldCelebrate(unlockedIDs: unlockedIDs, lastCelebratedCatalogSize: nil))
    }

    func testDoesNotCelebrateWithOnlyTheRegularDinosaursHatched() {
        let regularIDs = Set(DinosaurCatalog.all.filter { !$0.isSecret }.map(\.id))
        XCTAssertFalse(CollectionCompleteGate.shouldCelebrate(unlockedIDs: regularIDs, lastCelebratedCatalogSize: nil))
    }

    func testDoesNotCelebrateTheSameCatalogSizeTwice() {
        XCTAssertFalse(CollectionCompleteGate.shouldCelebrate(
            unlockedIDs: allIDs,
            lastCelebratedCatalogSize: DinosaurCatalog.all.count
        ))
    }

    func testCelebratesAgainAfterTheCatalogGrows() {
        XCTAssertTrue(CollectionCompleteGate.shouldCelebrate(
            unlockedIDs: allIDs,
            lastCelebratedCatalogSize: DinosaurCatalog.all.count - 3
        ))
    }

    func testUnknownIDsDoNotCountTowardCompletion() {
        // A record for a dinosaur no longer in the catalog shouldn't stand in
        // for a missing one, even though the total count matches.
        let unlockedIDs = Set(allIDs.dropFirst()).union(["retired-dinosaur"])
        XCTAssertEqual(unlockedIDs.count, allIDs.count)
        XCTAssertFalse(CollectionCompleteGate.shouldCelebrate(unlockedIDs: unlockedIDs, lastCelebratedCatalogSize: nil))
    }
}
