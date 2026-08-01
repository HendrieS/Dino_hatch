import Foundation

/// Toggles for features staged out of a specific TestFlight phase without
/// deleting the underlying implementation.
enum FeatureFlags {
    /// Off for TestFlight phase 1 so testers focus on the core timer/hatch/
    /// collection loop first, and phase 1 doesn't need the Paid Applications
    /// Agreement or the four supporter IAP products set up in App Store
    /// Connect before it can ship. Only the entry points are hidden
    /// (`SettingsView`'s "Support Dino Hatch" row, `HelpCenterView`'s
    /// "Supporting Dino Hatch" section) — `SupportUsView`/`SupporterStore`
    /// and the badge display are untouched, so flipping this back to `true`
    /// for phase 2 is the entire re-enable.
    static let supporterDonationsEnabled = false
}
