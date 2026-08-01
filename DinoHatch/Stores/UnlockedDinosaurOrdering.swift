import Foundation

/// Pure helper behind `CollectionView`'s "Collection Order" sort — pulled
/// out so the duplicate-key handling below is unit-testable.
enum UnlockedDinosaurOrdering {
    /// Earliest `unlockedAt` per dinosaur ID.
    ///
    /// `records` can contain more than one entry for the same ID —
    /// CloudKit-backed SwiftData can't enforce a unique constraint (see
    /// `SharedModelContainer`), so two devices racing to unlock the same
    /// dinosaur — most plausibly once the whole catalog is already unlocked
    /// and `HatchSelector` starts replaying already-owned ones — can each
    /// pass their own "not already unlocked" guard and insert their own
    /// row, which then both sync down locally. `Dictionary(uniqueKeysWithValues:)`
    /// traps on that duplicate; this keeps the earliest date instead, since
    /// that's the dinosaur's true original unlock time for ordering
    /// purposes.
    static func earliestUnlockDateByID(_ records: [(id: String, date: Date)]) -> [String: Date] {
        Dictionary(records.map { ($0.id, $0.date) }, uniquingKeysWith: min)
    }
}
