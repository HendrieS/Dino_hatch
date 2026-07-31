import ActivityKit
import Foundation

/// Drives the Lock Screen/Dynamic Island Live Activity for a running timer.
/// Compiled into both targets: the app and the widget extension's
/// `StartTimerIntent` both start one (a timer can begin from either), and
/// `DinoHatchWidget` renders it.
struct DinoTimerActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var endDate: Date
        var dinosaurEmoji: String?
        var dinosaurImageAssetName: String?
        /// Raw `SupporterTier`, captured once at Live Activity start —
        /// same reasoning as `dinosaurEmoji`/`dinosaurImageAssetName` not
        /// updating mid-countdown, see `DinoTimerActivityController`.
        var supporterTierRawValue: String?
    }
}
