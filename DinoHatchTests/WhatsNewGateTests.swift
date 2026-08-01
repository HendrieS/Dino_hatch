import XCTest
@testable import DinoHatch

final class WhatsNewGateTests: XCTestCase {
    private let notes = [
        ReleaseNote(version: "1.0", highlights: ["Initial release."]),
        ReleaseNote(version: "1.1", highlights: ["Alarm streaks."]),
        ReleaseNote(version: "1.2", highlights: ["App icons."]),
    ]

    func testSameVersionShowsNothing() {
        let result = WhatsNewGate.notesToShow(currentVersion: "1.1", lastSeenVersion: "1.1", allNotes: notes)
        XCTAssertTrue(result.isEmpty)
    }

    func testNilLastSeenShowsOnlyCurrentVersionsNote() {
        let result = WhatsNewGate.notesToShow(currentVersion: "1.2", lastSeenVersion: nil, allNotes: notes)
        XCTAssertEqual(result.map(\.version), ["1.2"])
    }

    func testNilLastSeenWithNoMatchingNoteShowsNothing() {
        let result = WhatsNewGate.notesToShow(currentVersion: "1.3", lastSeenVersion: nil, allNotes: notes)
        XCTAssertTrue(result.isEmpty)
    }

    func testSkippedVersionsSurfaceEverythingMissed() {
        let result = WhatsNewGate.notesToShow(currentVersion: "1.2", lastSeenVersion: "1.0", allNotes: notes)
        XCTAssertEqual(result.map(\.version), ["1.1", "1.2"])
    }

    func testVersionBumpWithNoNoteShowsNothing() {
        let result = WhatsNewGate.notesToShow(currentVersion: "1.3", lastSeenVersion: "1.2", allNotes: notes)
        XCTAssertTrue(result.isEmpty)
    }

    func testNumericVersionCompareNotLexicographic() {
        let manyNotes = notes + [ReleaseNote(version: "1.10", highlights: ["Ten."])]
        let result = WhatsNewGate.notesToShow(currentVersion: "1.10", lastSeenVersion: "1.2", allNotes: manyNotes)
        XCTAssertEqual(result.map(\.version), ["1.10"])
    }
}
