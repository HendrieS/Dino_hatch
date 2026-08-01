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
    /// nil until the first-launch age prompt is answered (see
    /// AgeOnboardingView) — RootTabView gates the whole app behind that
    /// prompt while this is nil, including for existing installs updating
    /// into a build that first introduces this field.
    var childAge: Int?
    /// Raw `SupporterTier` of the highest-owned support purchase, nil if
    /// none. Stored as a plain String (like `pendingDinosaurID` elsewhere)
    /// rather than the enum directly, matching this model's existing
    /// CloudKit-safe-primitives convention. `SupporterStore` is the source
    /// of truth (rebuilt from StoreKit's `Transaction.currentEntitlements`
    /// on launch) — this field is just a cache for instant display before
    /// that reconciliation finishes, see `AppSettings.supporterTier`.
    var supporterTierRawValue: String?
    /// The `CFBundleShortVersionString` the "What's New" sheet was last
    /// shown for (or silently stamped for, on first launch — see
    /// `AgeOnboardingView.save()`). RootTabView compares this against the
    /// running app's version to decide whether an update just happened; nil
    /// means either a fresh install mid-onboarding, or an existing install
    /// updating into the build that first introduced this field, both
    /// handled in `WhatsNewGate`.
    var lastSeenAppVersion: String?

    init() {}
}

extension AppSettings {
    var supporterTier: SupporterTier? {
        get { supporterTierRawValue.flatMap(SupporterTier.init(rawValue:)) }
        set { supporterTierRawValue = newValue?.rawValue }
    }
}
