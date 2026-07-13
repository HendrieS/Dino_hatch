import Foundation

enum HatchSelector {
    /// Picks a random dinosaur that hasn't been unlocked yet. `isSecret`
    /// dinosaurs are excluded from the pool until every non-secret one has
    /// been unlocked — no UI ever hints they exist, they just quietly
    /// become reachable once the regular set is complete. Once the whole
    /// catalog (secrets included) is unlocked, falls back to replaying a
    /// random already-owned dinosaur so the reward loop never dead-ends.
    static func pickNext(from catalog: [Dinosaur] = DinosaurCatalog.all, unlockedIDs: Set<String>) -> Dinosaur {
        let locked = catalog.filter { !unlockedIDs.contains($0.id) }

        let lockedRegular = locked.filter { !$0.isSecret }
        if let pick = lockedRegular.randomElement() {
            return pick
        }

        let lockedSecret = locked.filter(\.isSecret)
        if let pick = lockedSecret.randomElement() {
            return pick
        }

        return catalog.randomElement()!
    }
}
