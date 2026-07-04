import XCTest
@testable import DinoHatch

final class HatchSelectorTests: XCTestCase {
    func testPicksOnlyFromLockedDinosaurs() {
        let allIDs = Set(DinosaurCatalog.all.map(\.id))
        let unlockedIDs = Set(allIDs.dropLast(2))

        for _ in 0..<20 {
            let picked = HatchSelector.pickNext(unlockedIDs: unlockedIDs)
            XCTAssertFalse(unlockedIDs.contains(picked.id))
        }
    }

    func testFallsBackToReplayWhenAllUnlocked() {
        let allIDs = Set(DinosaurCatalog.all.map(\.id))
        let picked = HatchSelector.pickNext(unlockedIDs: allIDs)
        XCTAssertTrue(allIDs.contains(picked.id))
    }

    func testReturnsOnlyRemainingDinosaurWhenOneLeft() {
        let allIDs = DinosaurCatalog.all.map(\.id)
        let lastID = allIDs.last!
        let unlockedIDs = Set(allIDs.dropLast())

        let picked = HatchSelector.pickNext(unlockedIDs: unlockedIDs)
        XCTAssertEqual(picked.id, lastID)
    }
}
