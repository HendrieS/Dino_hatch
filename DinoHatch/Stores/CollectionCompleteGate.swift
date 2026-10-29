import Foundation

/// Pure "which collection celebration (if any) should play right now"
/// decision, kept separate from `RootTabView` so it's unit-testable without
/// SwiftData/SwiftUI.
enum CollectionCompleteGate {
    enum Milestone: Equatable {
        /// Every regular dinosaur hatched (the Collection counter reads
        /// 27/27), with the Secret Rare ones still hidden in the eggs.
        case allRegular
        /// Every dinosaur hatched, Secret Rare ones included.
        case everything
    }

    /// Each milestone plays once per catalog size, and again only if a
    /// future catalog expansion gets fully hatched too. Hatching the whole
    /// catalog skips straight to `.everything` — there's no point teasing
    /// secret dinosaurs that have already been found.
    ///
    /// Compares unique IDs rather than the number of `UnlockedDinosaur`
    /// records: iCloud sync can leave two records for the same dinosaur (two
    /// devices hatching it around the same time), and a plain record count
    /// would then overshoot the catalog and never match it.
    static func milestoneToCelebrate(
        unlockedIDs: Set<String>,
        lastCelebratedCatalogSize: Int?,
        lastCelebratedRegularCount: Int?,
        catalog: [Dinosaur] = DinosaurCatalog.all
    ) -> Milestone? {
        if Set(catalog.map(\.id)).isSubset(of: unlockedIDs) {
            return lastCelebratedCatalogSize == catalog.count ? nil : .everything
        }
        let regularIDs = Set(catalog.filter { !$0.isSecret }.map(\.id))
        if regularIDs.isSubset(of: unlockedIDs), lastCelebratedRegularCount != regularIDs.count {
            return .allRegular
        }
        return nil
    }
}
