import Foundation

struct Dinosaur: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let era: String
    let diet: Diet
    let length: String
    let funFact: String
    let symbolName: String
    let emoji: String
    let imageAssetName: String?
    let rarity: Rarity

    enum Diet: String, Codable, CaseIterable {
        case carnivore
        case herbivore
        case omnivore

        var label: String {
            switch self {
            case .carnivore: return "Carnivore"
            case .herbivore: return "Herbivore"
            case .omnivore: return "Omnivore"
            }
        }

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
    }
}
