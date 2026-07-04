import Foundation

enum HatchSelector {
    /// Picks a random dinosaur that hasn't been unlocked yet. Once the whole
    /// catalog is unlocked, falls back to replaying a random already-owned
    /// dinosaur so the reward loop never dead-ends.
    static func pickNext(from catalog: [Dinosaur] = DinosaurCatalog.all, unlockedIDs: Set<String>) -> Dinosaur {
        let locked = catalog.filter { !unlockedIDs.contains($0.id) }
        if let pick = locked.randomElement() {
            return pick
        }
        return catalog.randomElement()!
    }
}
