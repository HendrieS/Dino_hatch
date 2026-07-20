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

    /// `rangeMapAssetName` and `rangeLabel` are meant to always be set (or
    /// unset) together — a "Found in" card with a map but no caption, or a
    /// caption with no map, would both be typos rather than intentional.
    func testRangeMapAndLabelAreSetTogether() {
        for dinosaur in DinosaurCatalog.all {
            XCTAssertEqual(
                dinosaur.rangeMapAssetName == nil,
                dinosaur.rangeLabel == nil,
                "\(dinosaur.id) should have both rangeMapAssetName and rangeLabel, or neither"
            )
        }
    }

    /// Every dinosaur is expected to have a region map for now — catches a
    /// dinosaur silently falling through the region-grouping table.
    func testEveryDinosaurHasARangeMap() {
        for dinosaur in DinosaurCatalog.all {
            XCTAssertNotNil(dinosaur.rangeMapAssetName, "\(dinosaur.id) is missing a rangeMapAssetName")
        }
    }
}
