import Foundation
import UserNotifications

/// Shared local-notification permission request, used by both the dino
/// alarm and the timer's hatch-ready notification. Neither feature depends
/// on permission being granted — both still work correctly in-app on
/// foreground regardless — so this is a best-effort nudge, not a gate.
enum NotificationAuthorization {
    static func requestIfNeeded(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                completion(true)
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
                    completion(granted)
                }
            default:
                completion(false)
            }
        }
    }
}
