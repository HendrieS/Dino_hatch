import Foundation
import SwiftData

/// Single-row settings record. Persisting `activeTimerEndDate` (an absolute
/// wall-clock date, not an elapsed duration) lets an in-flight timer survive
/// not just backgrounding but a full app kill/relaunch: on relaunch we just
/// compare `Date.now` to this date instead of tracking elapsed ticks.
@Model
final class AppSettings {
    var lastUsedDurationSeconds: Int = 300
    var activeTimerEndDate: Date?
    var activeTimerTotalSeconds: Int = 0
    var pendingDinosaurID: String?

    init() {}
}
