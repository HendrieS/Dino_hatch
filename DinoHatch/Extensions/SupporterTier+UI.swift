import SwiftUI

extension SupporterTier {
    /// Same palette as `Dinosaur.Rarity.tint` (gray/green/gold/purple), kept
    /// as separate literal values rather than a shared lookup — see the
    /// type's doc comment for why the two enums stay decoupled.
    var tint: Color {
        switch self {
        case .gray: Color(red: 0.55, green: 0.58, blue: 0.62)
        case .green: Color(red: 0.20, green: 0.62, blue: 0.42)
        case .gold: Color(red: 0.83, green: 0.62, blue: 0.09)
        case .purple: Color(red: 0.56, green: 0.27, blue: 0.68)
        }
    }

    /// Enum-driven, same reasoning as `Dinosaur.Rarity.localizedLabel`.
    var localizedLabel: Text {
        switch self {
        case .gray: Text("Supporter")
        case .green: Text("Green Supporter")
        case .gold: Text("Gold Supporter")
        case .purple: Text("Purple Supporter")
        }
    }
}
