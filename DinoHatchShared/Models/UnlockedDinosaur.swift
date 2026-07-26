import Foundation
import SwiftData

@Model
final class UnlockedDinosaur {
    var dinosaurID: String = ""
    var unlockedAt: Date = Date.now

    init(dinosaurID: String, unlockedAt: Date = .now) {
        self.dinosaurID = dinosaurID
        self.unlockedAt = unlockedAt
    }
}
