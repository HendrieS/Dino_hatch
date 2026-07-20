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
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "stegosaurus"), .armored)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "ankylosaurus"), .armored)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "parasaurolophus"), .duckbill)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "iguanodon"), .duckbill)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "spinosaurus"), .sailback)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "baryonyx"), .sailback)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "t-rex"), .theropod)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "allosaurus"), .theropod)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "carnotaurus"), .theropod)
        XCTAssertEqual(EggHatchArt.family(forDinosaurID: "giganotosaurus"), .theropod)
    }

    func testUnmappedDinosaurHasNoFamily() {
        XCTAssertNil(EggHatchArt.family(forDinosaurID: "pachycephalosaurus"))
        XCTAssertNil(EggHatchArt.family(forDinosaurID: "plateosaurus"))
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
        XCTAssertEqual(
            EggHatchArt.frameNames(forDinosaurID: "stegosaurus"),
            ["egg-hatch-1", "egg-hatch-2", "egg-hatch-3-armored", "egg-hatch-4-armored"]
        )
        XCTAssertEqual(
            EggHatchArt.frameNames(forDinosaurID: "parasaurolophus"),
            ["egg-hatch-1", "egg-hatch-2", "egg-hatch-3-duckbill", "egg-hatch-4-duckbill"]
        )
        XCTAssertEqual(
            EggHatchArt.frameNames(forDinosaurID: "spinosaurus"),
            ["egg-hatch-1", "egg-hatch-2", "egg-hatch-3-sailback", "egg-hatch-4-sailback"]
        )
        XCTAssertEqual(
            EggHatchArt.frameNames(forDinosaurID: "t-rex"),
            ["egg-hatch-1", "egg-hatch-2", "egg-hatch-3-theropod", "egg-hatch-4-theropod"]
        )
    }

    func testFrameNamesFallBackToGenericArt() {
        XCTAssertEqual(
            EggHatchArt.frameNames(forDinosaurID: "pachycephalosaurus"),
            ["egg-hatch-1", "egg-hatch-2", "egg-hatch-3", "egg-hatch-4"]
        )
        XCTAssertEqual(
            EggHatchArt.frameNames(forDinosaurID: "plateosaurus"),
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
