import Foundation

/// Picks which stage-3/4 hatch illustration to show for a given dinosaur.
/// Stages 1-2 (the closed, then first-cracked egg) stay the shared generic
/// art regardless of species — nothing distinguishing has emerged yet.
/// Stages 3-4 switch to art for the dinosaur's broad body-plan "family"
/// when one exists, so what's peeking out actually looks like what's about
/// to hatch instead of always reading as the same silhouette. Only a
/// handful of families have dedicated art; everything else keeps the
/// original generic stage-3/4 frames.
enum EggHatchArt {
    enum Family: String, CaseIterable {
        case pterosaur
        case sauropod
        case ceratopsid
        case raptor
        case armored
        case duckbill
        case sailback
        case theropod
        case domehead
        case prosauropod
    }

    private static let familyByDinosaurID: [String: Family] = [
        "pteranodon": .pterosaur,
        "quetzalcoatlus": .pterosaur,

        "brachiosaurus": .sauropod,
        "diplodocus": .sauropod,
        "apatosaurus": .sauropod,
        "titanosaurus": .sauropod,
        "patagotitan": .sauropod,
        "dreadnoughtus": .sauropod,
        "puertasaurus": .sauropod,

        "triceratops": .ceratopsid,
        "styracosaurus": .ceratopsid,

        "velociraptor": .raptor,
        "dilophosaurus": .raptor,
        "coelophysis": .raptor,
        "compsognathus": .raptor,
        "gallimimus": .raptor,
        "oviraptor": .raptor,
        "therizinosaurus": .raptor,

        "stegosaurus": .armored,
        "ankylosaurus": .armored,

        "parasaurolophus": .duckbill,
        "iguanodon": .duckbill,

        "spinosaurus": .sailback,
        "baryonyx": .sailback,

        "t-rex": .theropod,
        "allosaurus": .theropod,
        "carnotaurus": .theropod,
        "giganotosaurus": .theropod,

        "pachycephalosaurus": .domehead,

        "plateosaurus": .prosauropod,
    ]

    static func family(forDinosaurID dinosaurID: String) -> Family? {
        familyByDinosaurID[dinosaurID]
    }

    /// The 4 frame asset names to cross-fade through, in order.
    static func frameNames(forDinosaurID dinosaurID: String) -> [String] {
        guard let family = family(forDinosaurID: dinosaurID) else {
            return ["egg-hatch-1", "egg-hatch-2", "egg-hatch-3", "egg-hatch-4"]
        }
        return [
            "egg-hatch-1",
            "egg-hatch-2",
            "egg-hatch-3-\(family.rawValue)",
            "egg-hatch-4-\(family.rawValue)",
        ]
    }
}
