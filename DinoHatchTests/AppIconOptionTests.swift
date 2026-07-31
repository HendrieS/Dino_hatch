import XCTest
@testable import DinoHatch

final class AppIconOptionTests: XCTestCase {
    func testEveryHatchRequirementMatchesARealCatalogEntry() {
        for option in AppIconOption.allCases {
            guard case .hatch(let dinosaurID) = option.unlockRequirement else { continue }
            XCTAssertTrue(
                DinosaurCatalog.all.contains { $0.id == dinosaurID },
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

    func testCollectionSizeLockedBelowThreshold() {
        let unlockedIDs = Set(["t-rex", "triceratops", "velociraptor", "stegosaurus"]) // 4
        XCTAssertFalse(AppIconOption.isUnlocked(.velociraptor, unlockedIDs: unlockedIDs))
    }

    func testCollectionSizeUnlockedAtThreshold() {
        let unlockedIDs = Set(["t-rex", "triceratops", "velociraptor", "stegosaurus", "spinosaurus"]) // 5
        XCTAssertTrue(AppIconOption.isUnlocked(.velociraptor, unlockedIDs: unlockedIDs))
    }

    func testHigherCollectionSizeThresholdStaysLockedInBetween() {
        let unlockedIDs = Set([
            "t-rex", "triceratops", "velociraptor", "stegosaurus", "spinosaurus",
            "ankylosaurus", "pteranodon", "parasaurolophus",
        ]) // 8, below the Spinosaurus icon's threshold of 10
        XCTAssertFalse(AppIconOption.isUnlocked(.spinosaurus, unlockedIDs: unlockedIDs))
    }

    func testAssetNamesAreUnique() {
        let names = Set(AppIconOption.allCases.map(\.assetName))
        XCTAssertEqual(names.count, AppIconOption.allCases.count)
    }
}
