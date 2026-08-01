import ActivityKit
import Foundation

/// Drives the Lock Screen/Dynamic Island Live Activity for a running timer.
/// Compiled into both targets: the app and the widget extension's
/// `StartTimerIntent` both start one (a timer can begin from either), and
/// `DinoHatchWidget` renders it.
struct DinoTimerActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var endDate: Date
        /// Raw `SupporterTier`, captured once at Live Activity start rather
        /// than updated mid-countdown if a purchase happens while a timer's
        /// already running — see `DinoTimerActivityController`.
        var supporterTierRawValue: String?
    }
}
