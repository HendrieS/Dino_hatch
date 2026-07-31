import SwiftUI
import SwiftData

/// Small corner badge shown once a parent has made a one-time support
/// purchase (see `SupportUsView`/`SupporterStore`) — renders nothing if
/// `AppSettings.supporterTier` is nil, so it's invisible for anyone who
/// hasn't donated. Tapping it opens the same support screen, both to say
/// thanks again and to make it easy to move up a tier.
struct SupporterBadgeView: View {
    @Query private var settings: [AppSettings]
    @State private var showSupportSheet = false

    private var tier: SupporterTier? {
        settings.first?.supporterTier
    }

    var body: some View {
        if let tier {
            Button {
                showSupportSheet = true
            } label: {
                Image(systemName: "heart.fill")
                    .font(.footnote.bold())
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(tier.tint, in: Circle())
            }
            .accessibilityLabel(tier.localizedLabel)
            .sheet(isPresented: $showSupportSheet) {
                SupportUsView()
            }
        }
    }
}

#Preview {
    SupporterBadgeView()
        .modelContainer(for: [AppSettings.self], inMemory: true)
}
