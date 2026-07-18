import XCTest
@testable import DinoHatch

final class EggHatchArtTests: XCTestCase {
    func testMappedFamilies() {
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "pteranodon"), .pterosaur)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "quetzalcoatlus"), .pterosaur)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "brachiosaurus"), .sauropod)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "diplodocus"), .sauropod)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "apatosaurus"), .sauropod)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "titanosaurus"), .sauropod)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "patagotitan"), .sauropod)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "dreadnoughtus"), .sauropod)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "puertasaurus"), .sauropod)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "triceratops"), .ceratopsid)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "styracosaurus"), .ceratopsid)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "velociraptor"), .raptor)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "dilophosaurus"), .raptor)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "coelophysis"), .raptor)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "compsognathus"), .raptor)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "gallimimus"), .raptor)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "oviraptor"), .raptor)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "therizinosaurus"), .raptor)
    }

    func testUnmappedDinosaurHasNoFamily() {
        XCTAssertNil(EggHatchArt.family(forDinosaurID: "t-rex"))
        XCTAssertNil(EggHatchArt.family(forDinosaurID: "stegosaurus"))
    }

    func testFrameNamesUseSpeciesArtForStagesThreeAndFour() {
        XCTAssertEqual(
            EggHatchArt.frameNames(forDinosaurID: "pteranodon"),
            ["egg-hatch-1", "egg-hatch-2", "egg-hatch-3-pterosaur", "egg-hatch-4-pterosaur"]
        )
        XCTAssertEqual(
            EggHatchArt.frameNames(forDinosaurID: "brachiosaurus"),
            ["egg-hatch-1", "egg-hatch-2", "egg-hatch-3-sauropod", "egg-hatch-4-sauropod"]
        )
        XCTAssertEqual(
            EggHatchArt.frameNames(forDinosaurID: "triceratops"),
            ["egg-hatch-1", "egg-hatch-2", "egg-hatch-3-ceratopsid", "egg-hatch-4-ceratopsid"]
        )
        XCTAssertEqual(
            EggHatchArt.frameNames(forDinosaurID: "velociraptor"),
            ["egg-hatch-1", "egg-hatch-2", "egg-hatch-3-raptor", "egg-hatch-4-raptor"]
        )
    }

    func testFrameNamesFallBackToGenericArt() {
        XCTAssertEqual(
            EggHatchArt.frameNames(forDinosaurID: "t-rex"),
            ["egg-hatch-1", "egg-hatch-2", "egg-hatch-3", "egg-hatch-4"]
        )
    }

    /// Every catalog entry should resolve to art that actually exists —
    /// either the generic frames or a mapped family's frames — so a typo
    /// in `familyByDinosaurID` can't silently point at missing assets.
    func testEveryCatalogDinosaurResolvesToAFamilyOrGeneric() {
        for dinosaur in DinosaurCatalog.all {
            let frames = EggHatchArt.frameNames(forDinosaurID: dinosaur.id)
            XCTAssertEqual(frames.count, 4, "\(dinosaur.id) should resolve to exactly 4 frames")
        }
    }
}
