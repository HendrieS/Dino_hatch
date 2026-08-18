import Foundation
import SwiftData

@Model
final class UnlockedDinosaur {
    var dinosaurID: String = ""
    var unlockedAt: Date = Date.now
    var isFavorite: Bool = false

    init(dinosaurID: String, unlockedAt: Date = .now) {
        self.dinosaurID = dinosaurID
        self.unlockedAt = unlockedAt
    }
}
