import Foundation
import UserNotifications

/// Schedules a one-shot local notification for when a running timer's egg
/// finishes, so backgrounding the app doesn't mean missing the hatch
/// entirely. Best-effort only, same as the dino alarm's notification —
/// `TimerEngine` and `TimerHomeView` work exactly as before if permission
/// is denied; this just adds an OS-level nudge on top. Deliberately doesn't
/// implement `UNUserNotificationCenterDelegate` to show a banner while the
/// app is in the foreground — `RootTabView`'s `TimerReadyBanner` already
/// covers that case, and showing both would be redundant.
enum TimerNotificationScheduler {
    private static let identifier = "dino-timer-hatch-ready"

    static func scheduleHatchNotification(at date: Date) {
        NotificationAuthorization.requestIfNeeded { granted in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("Your egg is ready!", comment: "Timer hatch notification title")
            content.body = NSLocalizedString(
                "Open Dino Hatch to see which dinosaur hatched!",
                comment: "Timer hatch notification body"
            )
            content.sound = .default

            let interval = max(date.timeIntervalSinceNow, 1)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }

    static func cancelHatchNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
}
