import SwiftUI

/// Tap-to-jump banner shown over whichever tab is on screen once a running
/// timer finishes while the Timer tab isn't the active one — otherwise the
/// reward would just sit there unannounced. See `RootTabView.isTimerReady`.
struct TimerReadyBanner: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Text("🥚")
                    .font(.title2)
                Text("An egg is ready to hatch!")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right.circle.fill")
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.dinoGreen, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }
}

#Preview {
    TimerReadyBanner {}
        .padding(.top, 40)
}
