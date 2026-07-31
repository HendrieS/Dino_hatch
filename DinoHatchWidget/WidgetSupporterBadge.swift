import SwiftUI

/// Small corner badge mirroring the in-app `SupporterBadgeView`, shown once
/// a parent has made a one-time support purchase (see `SupportUsView` in
/// the main app). Non-interactive here — widgets and Live Activities can't
/// present a sheet — so it's just a passive thank-you, not a tap target.
/// Renders nothing if `tier` is nil.
struct WidgetSupporterBadge: View {
    let tier: SupporterTier?

    var body: some View {
        if let tier {
            Image(systemName: "heart.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white)
                .padding(4)
                .background(tint(for: tier), in: Circle())
        }
    }

    /// Same palette as the in-app `SupporterTier.tint`/`Dinosaur.Rarity.tint`
    /// — duplicated rather than shared across targets, matching how this
    /// widget target already inlines its own color literals (e.g. the
    /// background gradients in each widget file) instead of importing
    /// SwiftUI-facing extensions from the app target.
    private func tint(for tier: SupporterTier) -> Color {
        switch tier {
        case .gray: Color(red: 0.55, green: 0.58, blue: 0.62)
        case .green: Color(red: 0.20, green: 0.62, blue: 0.42)
        case .gold: Color(red: 0.83, green: 0.62, blue: 0.09)
        case .purple: Color(red: 0.56, green: 0.27, blue: 0.68)
        }
    }
}
