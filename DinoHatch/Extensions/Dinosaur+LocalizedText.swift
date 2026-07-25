import SwiftUI

extension Dinosaur {
    /// Resolves `name` (the English catalog string, doubling as its own
    /// localization key — see `Text(localizedContent:)`) against the
    /// current locale as a plain `String`, for contexts like search
    /// matching where a `Text` view won't do.
    var localizedName: String {
        String(localized: String.LocalizationValue(name))
    }
}

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

extension Dinosaur.Rarity {
    /// Enum-driven, same reasoning as `Diet.localizedLabel` above.
    var localizedLabel: Text {
        switch self {
        case .common: Text("Common")
        case .uncommon: Text("Uncommon")
        case .rare: Text("Rare")
        case .secretRare: Text("Secret Rare")
        }
    }

    /// Trading-card-style star count: 1 for common up to 4 for secret rare.
    var starCount: Int {
        switch self {
        case .common: 1
        case .uncommon: 2
        case .rare: 3
        case .secretRare: 4
        }
    }

    var tint: Color {
        switch self {
        case .common: Color(red: 0.55, green: 0.58, blue: 0.62)
        case .uncommon: Color(red: 0.20, green: 0.62, blue: 0.42)
        case .rare: Color(red: 0.83, green: 0.62, blue: 0.09)
        case .secretRare: Color(red: 0.56, green: 0.27, blue: 0.68)
        }
    }
}
