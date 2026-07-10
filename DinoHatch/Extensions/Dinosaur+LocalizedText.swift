import SwiftUI

extension Dinosaur.Diet {
    /// Enum-driven, so these are real call-site literals (unlike
    /// `dinosaur.era`/`funFact`, which come from the runtime catalog and
    /// need `Text(localizedContent:)` instead).
    var localizedLabel: Text {
        switch self {
        case .carnivore: Text("Carnivore")
        case .herbivore: Text("Herbivore")
        case .omnivore: Text("Omnivore")
        }
    }
}
