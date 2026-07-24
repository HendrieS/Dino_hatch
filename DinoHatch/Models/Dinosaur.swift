import Foundation

struct Dinosaur: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let era: String
    let diet: Diet
    let length: String
    /// Estimated weight, formatted like `length` (e.g. "8,000 kg (17,600
    /// lb)") — a measurement notation shown verbatim rather than routed
    /// through localization. Optional/defaulted to nil so existing catalog
    /// entries compile unchanged.
    let weight: String?
    let funFact: String
    let symbolName: String
    let emoji: String
    let imageAssetName: String?
    /// Name of the skeleton asset in Assets.xcassets, used by
    /// `DinoAnatomyView` for the press & hold x-ray reveal. Optional and
    /// defaulted to nil so existing catalog entries compile unchanged and
    /// older saved data decodes without this key.
    let skeletonAssetName: String?
    /// Name of the shared region-map asset (one of a handful of reusable
    /// world maps, not one per dinosaur) shown as a "Found in" card on the
    /// detail screen — see `DinosaurDetailView`. Optional/defaulted to nil.
    let rangeMapAssetName: String?
    /// Short caption under the map, e.g. "Western North America". Routed
    /// through `Text(localizedContent:)` like `era`/`funFact` since it's
    /// user-facing copy. Optional/defaulted to nil.
    let rangeLabel: String?
    let rarity: Rarity
    /// Excluded from the Collection grid entirely while locked (no
    /// silhouette, no count) and from `HatchSelector`'s pool until every
    /// non-secret dinosaur has been unlocked. Defaulted to `false` so
    /// existing catalog entries are unaffected.
    let isSecret: Bool

    enum Diet: String, Codable, CaseIterable {
        case carnivore
        case herbivore
        case omnivore

        var symbolName: String {
            switch self {
            case .carnivore: return "fork.knife"
            case .herbivore: return "leaf.fill"
            case .omnivore: return "circle.grid.cross.fill"
            }
        }
    }

    enum Rarity: String, Codable, CaseIterable {
        case common
        case uncommon
        case rare
        /// The tier for `isSecret` dinosaurs — a step above `rare` so the
        /// four hidden ones stand apart from the regular rare pool once
        /// they're unlocked, instead of blending in as more of the same.
        case secretRare
    }

    init(
        id: String,
        name: String,
        era: String,
        diet: Diet,
        length: String,
        weight: String? = nil,
        funFact: String,
        symbolName: String,
        emoji: String,
        imageAssetName: String? = nil,
        skeletonAssetName: String? = nil,
        rangeMapAssetName: String? = nil,
        rangeLabel: String? = nil,
        rarity: Rarity,
        isSecret: Bool = false
    ) {
        self.id = id
        self.name = name
        self.era = era
        self.diet = diet
        self.length = length
        self.weight = weight
        self.funFact = funFact
        self.symbolName = symbolName
        self.emoji = emoji
        self.imageAssetName = imageAssetName
        self.skeletonAssetName = skeletonAssetName
        self.rangeMapAssetName = rangeMapAssetName
        self.rangeLabel = rangeLabel
        self.rarity = rarity
        self.isSecret = isSecret
    }

    // Decoding tolerates catalogs/saved data without `skeletonAssetName`,
    // `rangeMapAssetName`/`rangeLabel`, `weight`, or `isSecret`.
    enum CodingKeys: String, CodingKey {
        case id, name, era, diet, length, weight, funFact
        case symbolName, emoji, imageAssetName, skeletonAssetName
        case rangeMapAssetName, rangeLabel, rarity, isSecret
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        era = try c.decode(String.self, forKey: .era)
        diet = try c.decode(Diet.self, forKey: .diet)
        length = try c.decode(String.self, forKey: .length)
        weight = try c.decodeIfPresent(String.self, forKey: .weight)
        funFact = try c.decode(String.self, forKey: .funFact)
        symbolName = try c.decode(String.self, forKey: .symbolName)
        emoji = try c.decode(String.self, forKey: .emoji)
        imageAssetName = try c.decodeIfPresent(String.self, forKey: .imageAssetName)
        skeletonAssetName = try c.decodeIfPresent(String.self, forKey: .skeletonAssetName)
        rangeMapAssetName = try c.decodeIfPresent(String.self, forKey: .rangeMapAssetName)
        rangeLabel = try c.decodeIfPresent(String.self, forKey: .rangeLabel)
        rarity = try c.decode(Rarity.self, forKey: .rarity)
        isSecret = try c.decodeIfPresent(Bool.self, forKey: .isSecret) ?? false
    }
}
