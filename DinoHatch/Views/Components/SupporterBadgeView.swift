import SwiftUI
import SwiftData

/// Small corner badge shown once a parent has made a one-time support
/// purchase (see `SupportUsView`/`SupporterStore`) — renders nothing if
/// `AppSettings.supporterTier` is nil, so it's invisible for anyone who
/// hasn't donated. Tapping it opens `SupporterThankYouView`, a pure
/// thank-you message with no purchase UI — this badge is reachable from the
/// Timer/Alarm/Collection tabs a child uses unsupervised, so it must never
/// be a path to StoreKit. Buying (or moving up a tier) only ever happens
/// from Settings → Support Dino Hatch, behind `ParentalGateView`.
struct SupporterBadgeView: View {
    @Query private var settings: [AppSettings]
    @State private var showThankYou = false

    private var tier: SupporterTier? {
        settings.first?.supporterTier
    }

    var body: some View {
        if let tier {
            Button {
                showThankYou = true
            } label: {
                Image(systemName: "heart.fill")
                    .font(.footnote.bold())
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(tier.tint, in: Circle())
            }
            .accessibilityLabel(tier.localizedLabel)
            .sheet(isPresented: $showThankYou) {
                SupporterThankYouView(tier: tier)
            }
        }
    }
}

#Preview {
    SupporterBadgeView()
        .modelContainer(for: [AppSettings.self], inMemory: true)
}
