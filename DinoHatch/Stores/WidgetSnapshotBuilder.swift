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

    struct AlarmInfo {
        let hour: Int
        let minute: Int
        let weekdays: [Int]
        let isEnabled: Bool
    }

    static func build(
        unlocked: [UnlockRecord],
        alarm: AlarmInfo? = nil,
        activeTimerEndDate: Date? = nil,
        supporterTier: SupporterTier? = nil,
        catalog: [Dinosaur] = DinosaurCatalog.all,
        now: Date = .now
    ) -> WidgetSnapshot {
        let totalCount = catalog.filter { !$0.isSecret }.count
        let mostRecent = unlocked.max(by: { $0.unlockedAt < $1.unlockedAt })
        let dinosaur = mostRecent.flatMap { record in catalog.first { $0.id == record.dinosaurID } }

        let alarmEnabled = alarm?.isEnabled ?? false
        let nextAlarmFireDate = alarm.flatMap { alarm in
            alarm.isEnabled ? AlarmNextFireDate.next(hour: alarm.hour, minute: alarm.minute, weekdays: alarm.weekdays, now: now) : nil
        }

        return WidgetSnapshot(
            unlockedCount: unlocked.count,
            totalCount: totalCount,
            lastDinosaurEmoji: dinosaur?.emoji,
            lastDinosaurImageAssetName: dinosaur?.imageAssetName,
            lastDinosaurName: dinosaur?.localizedName,
            alarmEnabled: alarmEnabled,
            nextAlarmFireDate: nextAlarmFireDate,
            alarmHour: alarm?.hour,
            alarmMinute: alarm?.minute,
            alarmWeekdays: alarm?.weekdays,
            activeTimerEndDate: activeTimerEndDate,
            supporterTierRawValue: supporterTier?.rawValue
        )
    }
}
