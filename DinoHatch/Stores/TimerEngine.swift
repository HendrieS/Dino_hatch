import Foundation
import Observation
import SwiftData

/// Drives the countdown using an absolute end date persisted in `AppSettings`,
/// rather than an elapsed-tick counter. That means a running timer survives
/// backgrounding *and* a full app kill/relaunch: `restoreFromSettings()` just
/// compares `Date.now` to the stored end date.
@Observable
final class TimerEngine {
    private(set) var endDate: Date?
    private(set) var totalSeconds: Int = 0
    private(set) var pendingDinosaurID: String?

    private var modelContext: ModelContext?

    var isRunning: Bool { endDate != nil }

    func configure(context: ModelContext) {
        modelContext = context
        restoreFromSettings()
    }

    var lastUsedDuration: Int {
        settings().lastUsedDurationSeconds
    }

    func restoreFromSettings() {
        let settings = settings()
        endDate = settings.activeTimerEndDate
        totalSeconds = settings.activeTimerTotalSeconds
        pendingDinosaurID = settings.pendingDinosaurID
    }

    func start(duration: TimeInterval, hatching dinosaurID: String) {
        let settings = settings()
        let end = Date.now.addingTimeInterval(duration)
        settings.activeTimerEndDate = end
        settings.activeTimerTotalSeconds = Int(duration)
        settings.lastUsedDurationSeconds = Int(duration)
        settings.pendingDinosaurID = dinosaurID

        endDate = end
        totalSeconds = Int(duration)
        pendingDinosaurID = dinosaurID

        TimerNotificationScheduler.scheduleHatchNotification(at: end)
        DinoTimerActivityController.start(
            endDate: end,
            supporterTierRawValue: settings.supporterTierRawValue
        )
    }

    func cancel() {
        let settings = settings()
        settings.activeTimerEndDate = nil
        settings.activeTimerTotalSeconds = 0
        settings.pendingDinosaurID = nil

        endDate = nil
        totalSeconds = 0
        pendingDinosaurID = nil

        TimerNotificationScheduler.cancelHatchNotification()
        DinoTimerActivityController.end()
    }

    /// Same as `cancel()`, named separately so call sites read as "the hatch
    /// finished" rather than "the timer was cancelled".
    func completeHatch() {
        cancel()
    }

    func remainingFraction(at date: Date = .now) -> Double {
        guard let endDate, totalSeconds > 0 else { return 0 }
        let remaining = max(0, endDate.timeIntervalSince(date))
        return remaining / Double(totalSeconds)
    }

    func isComplete(at date: Date = .now) -> Bool {
        guard let endDate else { return false }
        return date >= endDate
    }

    private func settings() -> AppSettings {
        guard let modelContext else {
            fatalError("TimerEngine.configure(context:) must be called before use")
        }
        let descriptor = FetchDescriptor<AppSettings>(sortBy: [SortDescriptor(\.createdAt)])
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        let created = AppSettings()
        modelContext.insert(created)
        return created
    }
}
