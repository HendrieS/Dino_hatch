import ActivityKit
import Foundation

/// Thin wrapper around `Activity<DinoTimerActivityAttributes>` so
/// `TimerEngine.start()`/`cancel()` (main app) and `StartTimerIntent.
/// perform()` (widget extension) share one place that knows how to
/// start/end the timer's Live Activity, rather than duplicating the
/// ActivityKit calls in both. Best-effort, same philosophy as
/// `NotificationAuthorization` — a timer works exactly the same in-app
/// whether or not the Live Activity could be created (Live Activities can
/// be turned off system-wide in Settings).
enum DinoTimerActivityController {
    static func start(endDate: Date, dinosaurEmoji: String?) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        // Only one dino timer runs at a time — clear out anything stale
        // (e.g. from a previous run that never got ended) before starting.
        end()
        let state = DinoTimerActivityAttributes.ContentState(endDate: endDate, dinosaurEmoji: dinosaurEmoji)
        let content = ActivityContent(state: state, staleDate: endDate)
        _ = try? Activity.request(attributes: DinoTimerActivityAttributes(), content: content)
    }

    static func end() {
        Task {
            for activity in Activity<DinoTimerActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
