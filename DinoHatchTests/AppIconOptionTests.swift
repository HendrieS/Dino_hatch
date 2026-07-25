import XCTest
@testable import DinoHatch

final class AppIconOptionTests: XCTestCase {
    func testEveryOptionMatchesARealCatalogEntry() {
        for option in AppIconOption.allCases {
            XCTAssertTrue(
                DinosaurCatalog.all.contains { $0.id == option.dinosaurID },
                "\(option) references a dinosaurID that isn't in the catalog"
            )
        }
    }

    func testLockedWithoutMatchingHatch() {
        XCTAssertFalse(AppIconOption.isUnlocked(.trex, unlockedIDs: ["triceratops"]))
    }

    func testUnlockedOnceThatDinosaurIsHatched() {
        XCTAssertTrue(AppIconOption.isUnlocked(.trex, unlockedIDs: ["t-rex", "triceratops"]))
    }

    func testAssetNamesAreUnique() {
        let names = Set(AppIconOption.allCases.map(\.assetName))
        XCTAssertEqual(names.count, AppIconOption.allCases.count)
    }
}
