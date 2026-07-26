import Foundation

/// The fixed set of durations the Quick Timer widget offers — shared so
/// `StartTimerIntent` (widget target) can validate its input against the
/// exact same set `DinoHatchQuickTimerWidgetView` (widget target) renders
/// buttons for.
enum QuickTimerDurations {
    static let allowedMinutes: [Int] = [5, 10, 15, 30]
}
