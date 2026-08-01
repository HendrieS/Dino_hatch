import Foundation

/// Pure "which release notes (if any) should the What's New sheet show right
/// now" decision, kept separate from `RootTabView` so it's unit-testable
/// without SwiftData/SwiftUI.
enum WhatsNewGate {
    /// - `lastSeenVersion == currentVersion`: nothing changed since last
    ///   launch, never show anything.
    /// - `lastSeenVersion == nil`: either mid-onboarding on a fresh install
    ///   (never reaches this — `AgeOnboardingView.save()` stamps the version
    ///   silently before `RootTabView` ever checks) or an existing install
    ///   updating into the build that introduced this feature. Treated as
    ///   "just updated to `currentVersion`" but only that version's note is
    ///   shown, not the entire history, so it doesn't dump a changelog on
    ///   someone who's been using the app for months.
    /// - otherwise: every note strictly newer than `lastSeenVersion` and up
    ///   to `currentVersion`, oldest first, so skipping several TestFlight
    ///   builds between opens still surfaces everything missed.
    static func notesToShow(currentVersion: String, lastSeenVersion: String?, allNotes: [ReleaseNote] = ReleaseNotes.all) -> [ReleaseNote] {
        guard lastSeenVersion != currentVersion else { return [] }
        guard let lastSeenVersion else {
            return allNotes.filter { $0.version == currentVersion }
        }
        return allNotes
            .filter { $0.version.compareVersion(lastSeenVersion) == .orderedDescending
                && $0.version.compareVersion(currentVersion) != .orderedDescending }
            .sorted { $0.version.compareVersion($1.version) == .orderedAscending }
    }
}
