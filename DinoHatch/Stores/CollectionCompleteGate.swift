import Foundation

/// Pure "should the Collection Complete celebration play right now"
/// decision, kept separate from `RootTabView` so it's unit-testable without
/// SwiftData/SwiftUI.
enum CollectionCompleteGate {
    /// True once every catalog dinosaur (regular + Secret Rare) has been
    /// hatched, unless a catalog of this size was already celebrated — so it
    /// plays once, and again only if a future catalog expansion gets fully
    /// hatched too.
    ///
    /// Compares unique IDs rather than the number of `UnlockedDinosaur`
    /// records: iCloud sync can leave two records for the same dinosaur (two
    /// devices hatching it around the same time), and a plain record count
    /// of 31 would then never equal the 30-dinosaur catalog.
    static func shouldCelebrate(
        unlockedIDs: Set<String>,
        lastCelebratedCatalogSize: Int?,
        catalog: [Dinosaur] = DinosaurCatalog.all
    ) -> Bool {
        guard lastCelebratedCatalogSize != catalog.count else { return false }
        return Set(catalog.map(\.id)).isSubset(of: unlockedIDs)
    }
}
