import Foundation

/// Builds the `WidgetSnapshot` handed to `WidgetSnapshotStore.save` — pulled
/// out as a pure function (rather than inlined at the call site) so the
/// "which unlock counts as most recent" and "which count is the
/// denominator" logic is unit-testable, matching HatchSelector/AlarmStreak/
/// etc. Takes plain records rather than `UnlockedDinosaur` directly so it
/// doesn't need a SwiftData context to test.
enum WidgetSnapshotBuilder {
    struct UnlockRecord {
        let dinosaurID: String
        let unlockedAt: Date
    }

    static func build(unlocked: [UnlockRecord], catalog: [Dinosaur] = DinosaurCatalog.all) -> WidgetSnapshot {
        let totalCount = catalog.filter { !$0.isSecret }.count
        guard let mostRecent = unlocked.max(by: { $0.unlockedAt < $1.unlockedAt }) else {
            return WidgetSnapshot(unlockedCount: 0, totalCount: totalCount, lastDinosaurEmoji: nil, lastDinosaurName: nil)
        }
        let dinosaur = catalog.first { $0.id == mostRecent.dinosaurID }
        return WidgetSnapshot(
            unlockedCount: unlocked.count,
            totalCount: totalCount,
            lastDinosaurEmoji: dinosaur?.emoji,
            lastDinosaurName: dinosaur?.localizedName
        )
    }
}
