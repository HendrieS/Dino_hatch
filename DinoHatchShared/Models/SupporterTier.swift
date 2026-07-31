import Foundation

/// A parent's optional one-time support purchase (see `SupportUsView`),
/// shown as a small badge in the corner of the main screens. Deliberately
/// separate from `Dinosaur.Rarity` even though the colors match in the UI
/// layer (`SupporterTier+UI.swift`) — donor status isn't dinosaur game
/// data, and the two shouldn't be coupled just because they happen to
/// share a palette today.
///
/// Each case is a distinct non-consumable StoreKit product (see
/// `productID`) rather than tiers of a single product, since a permanent
/// badge unlock is exactly what non-consumables are for — StoreKit tracks
/// ownership and `Restore Purchases` for us, so there's no need for our
/// own purchase ledger.
enum SupporterTier: String, Codable, CaseIterable, Comparable {
    case gray
    case green
    case gold
    case purple

    /// Bundle ID prefix shared with `project.yml`'s `bundleIdPrefix`.
    private static let productIDPrefix = "com.dinohatchtimer.app.support"

    var productID: String {
        "\(Self.productIDPrefix).\(rawValue)"
    }

    init?(productID: String) {
        guard let tier = Self.allCases.first(where: { $0.productID == productID }) else { return nil }
        self = tier
    }

    /// Ascending rarity order, so the highest owned tier can be picked with
    /// a plain `max()` over currently-entitled products.
    private var rank: Int {
        switch self {
        case .gray: 0
        case .green: 1
        case .gold: 2
        case .purple: 3
        }
    }

    static func < (lhs: SupporterTier, rhs: SupporterTier) -> Bool {
        lhs.rank < rhs.rank
    }
}
