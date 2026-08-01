import XCTest
@testable import DinoHatch

final class UnlockedDinosaurOrderingTests: XCTestCase {
    func testNoDuplicatesMapsEachIDToItsDate() {
        let early = Date(timeIntervalSince1970: 100)
        let later = Date(timeIntervalSince1970: 200)
        let result = UnlockedDinosaurOrdering.earliestUnlockDateByID([
            (id: "t-rex", date: early),
            (id: "triceratops", date: later),
        ])
        XCTAssertEqual(result, ["t-rex": early, "triceratops": later])
    }

    /// The crash this guards against: two `UnlockedDinosaur` rows for the
    /// same dinosaur ID (e.g. synced in independently from two devices)
    /// used to trap `Dictionary(uniqueKeysWithValues:)` outright.
    func testDuplicateIDKeepsEarliestDateInsteadOfCrashing() {
        let earlier = Date(timeIntervalSince1970: 100)
        let laterDuplicate = Date(timeIntervalSince1970: 500)
        let result = UnlockedDinosaurOrdering.earliestUnlockDateByID([
            (id: "t-rex", date: earlier),
            (id: "t-rex", date: laterDuplicate),
        ])
        XCTAssertEqual(result, ["t-rex": earlier])
    }

    func testDuplicateIDKeepsEarliestDateRegardlessOfOrder() {
        let earlier = Date(timeIntervalSince1970: 100)
        let laterDuplicate = Date(timeIntervalSince1970: 500)
        let result = UnlockedDinosaurOrdering.earliestUnlockDateByID([
            (id: "t-rex", date: laterDuplicate),
            (id: "t-rex", date: earlier),
        ])
        XCTAssertEqual(result, ["t-rex": earlier])
    }

    func testEmptyInput() {
        XCTAssertEqual(UnlockedDinosaurOrdering.earliestUnlockDateByID([]), [:])
    }
}
