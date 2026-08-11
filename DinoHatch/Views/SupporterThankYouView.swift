import SwiftUI

/// Shown when a kid (or anyone) taps `SupporterBadgeView` — a pure
/// thank-you screen with no path back to `SupportUsView`/StoreKit at all.
/// Purchasing only ever happens from Settings → Support Dino Hatch, behind
/// `ParentalGateView`'s math check; the badge itself must never be a way to
/// reach that purchase flow without an adult, since it's tappable from the
/// Timer/Alarm/Collection tabs a child uses unsupervised.
struct SupporterThankYouView: View {
    @Environment(\.dismiss) private var dismiss
    let tier: SupporterTier

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "heart.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
                    .padding(28)
                    .background(tier.tint, in: Circle())

                tier.localizedLabel
                    .font(.title2.bold())

                Text("Thank you so much for supporting Dino Hatch! Your kindness means a lot to our small team.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)

                Spacer()
                Spacer()

                Button("Awesome!") { dismiss() }
                    .buttonStyle(.dinoChunkyGreen)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 12)
            }
            .padding()
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
            .dinoWarmBackground()
        }
    }
}

#Preview {
    SupporterThankYouView(tier: .gold)
}
