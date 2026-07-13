import XCTest
@testable import DinoHatch

final class DinosaurCatalogTests: XCTestCase {
    func testIDsAreUnique() {
        let ids = DinosaurCatalog.all.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    func testCatalogSizeInExpectedRange() {
        XCTAssertGreaterThanOrEqual(DinosaurCatalog.all.count, 24)
        XCTAssertLessThanOrEqual(DinosaurCatalog.all.count, 27)
    }

    func testNoEmptyRequiredFields() {
        for dinosaur in DinosaurCatalog.all {
            XCTAssertFalse(dinosaur.name.isEmpty)
            XCTAssertFalse(dinosaur.era.isEmpty)
            XCTAssertFalse(dinosaur.length.isEmpty)
            XCTAssertFalse(dinosaur.funFact.isEmpty)
            XCTAssertFalse(dinosaur.emoji.isEmpty)
            XCTAssertFalse(dinosaur.symbolName.isEmpty)
        }
    }
}
