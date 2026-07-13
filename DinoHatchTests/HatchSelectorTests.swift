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

    func testSecretDinosaursExcludedWhileAnyRegularDinosaurIsLocked() {
        let regularIDs = DinosaurCatalog.all.filter { !$0.isSecret }.map(\.id)
        // Leave one regular dinosaur locked; nothing else unlocked.
        let unlockedIDs = Set(regularIDs.dropLast())

        for _ in 0..<30 {
            let picked = HatchSelector.pickNext(unlockedIDs: unlockedIDs)
            XCTAssertFalse(picked.isSecret)
        }
    }

    func testSecretDinosaursBecomeEligibleOnceAllRegularDinosaursUnlocked() {
        let regularIDs = Set(DinosaurCatalog.all.filter { !$0.isSecret }.map(\.id))

        for _ in 0..<30 {
            let picked = HatchSelector.pickNext(unlockedIDs: regularIDs)
            XCTAssertTrue(picked.isSecret)
        }
    }
}
