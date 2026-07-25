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

    func testNoAlarmLeavesAlarmFieldsAtDefault() {
        let snapshot = WidgetSnapshotBuilder.build(unlocked: [])
        XCTAssertFalse(snapshot.alarmEnabled)
        XCTAssertNil(snapshot.nextAlarmFireDate)
    }

    func testDisabledAlarmHasNoNextFireDate() {
        let alarm = WidgetSnapshotBuilder.AlarmInfo(hour: 7, minute: 0, weekdays: [1, 2, 3, 4, 5, 6, 7], isEnabled: false)
        let snapshot = WidgetSnapshotBuilder.build(unlocked: [], alarm: alarm)
        XCTAssertFalse(snapshot.alarmEnabled)
        XCTAssertNil(snapshot.nextAlarmFireDate)
    }

    func testEnabledAlarmComputesNextFireDate() {
        let now = Date(timeIntervalSince1970: 1_800_000_000) // fixed reference instant
        let alarm = WidgetSnapshotBuilder.AlarmInfo(hour: 7, minute: 0, weekdays: Array(1...7), isEnabled: true)
        let snapshot = WidgetSnapshotBuilder.build(unlocked: [], alarm: alarm, now: now)
        XCTAssertTrue(snapshot.alarmEnabled)
        XCTAssertEqual(
            snapshot.nextAlarmFireDate,
            AlarmNextFireDate.next(hour: 7, minute: 0, weekdays: Array(1...7), now: now)
        )
    }
}
