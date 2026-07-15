import Foundation
import UserNotifications

/// Schedules the local notifications that nudge a kid to open the app
/// around wake-up time. The actual hatch reward is decided in-app by
/// `AlarmClaimer` when the app becomes active, not by this notification —
/// so if permission is denied, or the notification is dismissed unread,
/// the reward still works as long as the app is opened within
/// `AlarmClaimer.responseWindow` of the set time.
enum AlarmScheduler {
    private static let identifierPrefix = "dino-alarm-weekday-"

    static func requestAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
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

    static func reschedule(hour: Int, minute: Int, weekdays: [Int]) {
        let center = UNUserNotificationCenter.current()
        cancelAll()

        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Time to wake up!", comment: "Alarm notification title")
        content.body = NSLocalizedString(
            "A dinosaur egg is ready to hatch! Open Dino Hatch in the next 15 minutes to see who it is.",
            comment: "Alarm notification body"
        )
        content.sound = .default

        for weekday in weekdays {
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            components.weekday = weekday
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: identifierPrefix + String(weekday),
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    static func cancelAll() {
        let identifiers = (1...7).map { identifierPrefix + String($0) }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
