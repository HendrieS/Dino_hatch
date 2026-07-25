import Foundation

/// The `dinohatch://start-timer?minutes=N` deep link the Quick Timer widget
/// uses to start a timer. Compiled into both targets: the widget builds the
/// URL for each button, the app parses it back in `RootTabView`.
///
/// A URL scheme (rather than a shared SwiftData/App Group write) is used on
/// purpose — starting a timer picks a random unhatched dinosaur and needs to
/// show the countdown/hatch animation, so opening the app to it is the right
/// behavior anyway, not just a fallback.
enum QuickStartLink {
    static let scheme = "dinohatch"
    static let host = "start-timer"
    static let allowedMinutes: [Int] = [5, 10, 15, 30]

    static func url(forMinutes minutes: Int) -> URL {
        URL(string: "\(scheme)://\(host)?minutes=\(minutes)")!
    }

    /// Returns the requested duration in minutes, or `nil` if `url` isn't a
    /// recognized quick-start link or requests a duration outside the
    /// widget's fixed button set — rejecting anything else is a deliberate
    /// safeguard since any app can invoke a custom URL scheme.
    static func minutes(from url: URL) -> Int? {
        guard url.scheme == scheme, url.host == host,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let minutesValue = components.queryItems?.first(where: { $0.name == "minutes" })?.value,
              let minutes = Int(minutesValue),
              allowedMinutes.contains(minutes) else { return nil }
        return minutes
    }
}
