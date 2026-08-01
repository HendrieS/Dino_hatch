import AppIntents
import SwiftData
import WidgetKit
import Foundation

/// Backs the Quick Timer widget's duration buttons. Runs in the widget
/// extension's process without ever opening the app — the whole point of
/// this feature — so it has to do everything `TimerEngine.start()` does
/// itself: write `AppSettings` directly (via the shared App Group store,
/// see `SharedModelContainer`), schedule the hatch notification, start the
/// Lock Screen/Dynamic Island Live Activity, and update the widget's own
/// `WidgetSnapshot` so the countdown appears immediately rather than
/// waiting for the app to next run `refreshWidgetSnapshot()`.
struct StartTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Dino Timer"
    static var description = IntentDescription("Starts a Dino Hatch timer without opening the app.")

    @Parameter(title: "Minutes")
    var minutes: Int

    init() {
        minutes = QuickTimerDurations.allowedMinutes.first ?? 5
    }

    init(minutes: Int) {
        self.minutes = minutes
    }

    func perform() async throws -> some IntentResult {
        guard QuickTimerDurations.allowedMinutes.contains(minutes) else {
            return .result()
        }

        let context = ModelContext(SharedModelContainer.make())
        let settings = try Self.existingOrNewAppSettings(in: context)

        // A timer's already running — ignore, same as TimerHomeView's
        // silent-ignore guard for a stray quick-start while counting down.
        guard settings.activeTimerEndDate == nil else {
            return .result()
        }

        let unlockedIDs = Set(try context.fetch(FetchDescriptor<UnlockedDinosaur>()).map(\.dinosaurID))
        let dinosaur = HatchSelector.pickNext(unlockedIDs: unlockedIDs)
        let seconds = minutes * 60
        let end = Date.now.addingTimeInterval(TimeInterval(seconds))

        settings.activeTimerEndDate = end
        settings.activeTimerTotalSeconds = seconds
        settings.lastUsedDurationSeconds = seconds
        settings.pendingDinosaurID = dinosaur.id
        try context.save()

        TimerNotificationScheduler.scheduleHatchNotification(at: end)
        DinoTimerActivityController.start(
            endDate: end,
            supporterTierRawValue: settings.supporterTierRawValue
        )

        var snapshot = WidgetSnapshotStore.load() ?? .empty
        snapshot.activeTimerEndDate = end
        WidgetSnapshotStore.save(snapshot)

        WidgetCenter.shared.reloadTimelines(ofKind: WidgetSnapshotStore.quickTimerWidgetKind)

        return .result()
    }

    private static func existingOrNewAppSettings(in context: ModelContext) throws -> AppSettings {
        if let existing = try context.fetch(FetchDescriptor<AppSettings>()).first {
            return existing
        }
        let created = AppSettings()
        context.insert(created)
        return created
    }
}
