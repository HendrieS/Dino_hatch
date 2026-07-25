import XCTest
@testable import DinoHatch

final class WidgetSnapshotBuilderTests: XCTestCase {
    func testEmptyCollectionHasNoLastDinosaur() {
        let snapshot = WidgetSnapshotBuilder.build(unlocked: [])
        XCTAssertEqual(snapshot.unlockedCount, 0)
        XCTAssertNil(snapshot.lastDinosaurEmoji)
        XCTAssertNil(snapshot.lastDinosaurName)
    }

    func testTotalCountExcludesSecretDinosaurs() {
        let regularCount = DinosaurCatalog.all.filter { !$0.isSecret }.count
        let snapshot = WidgetSnapshotBuilder.build(unlocked: [])
        XCTAssertEqual(snapshot.totalCount, regularCount)
        XCTAssertLessThan(snapshot.totalCount, DinosaurCatalog.all.count)
    }

    func testMostRecentUnlockWinsRegardlessOfArrayOrder() {
        let older = WidgetSnapshotBuilder.UnlockRecord(dinosaurID: "triceratops", unlockedAt: Date(timeIntervalSince1970: 100))
        let newer = WidgetSnapshotBuilder.UnlockRecord(dinosaurID: "t-rex", unlockedAt: Date(timeIntervalSince1970: 200))

        let snapshot = WidgetSnapshotBuilder.build(unlocked: [newer, older])
        let trex = DinosaurCatalog.all.first { $0.id == "t-rex" }!

        XCTAssertEqual(snapshot.unlockedCount, 2)
        XCTAssertEqual(snapshot.lastDinosaurEmoji, trex.emoji)
        XCTAssertEqual(snapshot.lastDinosaurName, trex.localizedName)
    }

    func testUnknownDinosaurIDLeavesLastDinosaurNil() {
        let record = WidgetSnapshotBuilder.UnlockRecord(dinosaurID: "not-a-real-id", unlockedAt: .now)
        let snapshot = WidgetSnapshotBuilder.build(unlocked: [record])
        XCTAssertEqual(snapshot.unlockedCount, 1)
        XCTAssertNil(snapshot.lastDinosaurEmoji)
        XCTAssertNil(snapshot.lastDinosaurName)
    }
}
