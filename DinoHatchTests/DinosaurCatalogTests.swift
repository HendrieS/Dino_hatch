import XCTest
@testable import DinoHatch

final class DinosaurCatalogTests: XCTestCase {
    func testIDsAreUnique() {
        let ids = DinosaurCatalog.all.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    func testRegularCatalogSizeInExpectedRange() {
        let regularCount = DinosaurCatalog.all.filter { !$0.isSecret }.count
        XCTAssertGreaterThanOrEqual(regularCount, 24)
        XCTAssertLessThanOrEqual(regularCount, 30)
    }

    func testHasFourSecretDinosaurs() {
        XCTAssertEqual(DinosaurCatalog.all.filter(\.isSecret).count, 4)
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
