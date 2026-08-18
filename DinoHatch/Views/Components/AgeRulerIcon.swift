import SwiftUI

/// A vector "growth ruler + footprint" mark for the age-onboarding screen,
/// replacing the borrowed "alarm-egg" asset (an Alarm feature icon with no
/// connection to age at all). Drawn from primitives rather than commissioned
/// illustrated art — the same relationship `EggView`'s own vector fallback
/// has to the real `egg-hatch-1` asset — so it's easy to swap for hand-
/// painted art later without touching `AgeOnboardingView` itself.
struct AgeRulerIcon: View {
    private let rulerHeight: CGFloat = 140
    private let tickCount = 8

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ruler

            // A footprint "standing" partway up the ruler, like a growth
            // chart mark — ties the ruler back to the app's own dino
            // footprint motif (already used on Start/Cancel Timer and the
            // floating nav menu) rather than a generic height icon.
            Image(systemName: "pawprint.fill")
                .font(.system(size: 34))
                .foregroundStyle(Color.dinoGreen)
                .rotationEffect(.degrees(-10))
                .offset(x: 56, y: -50)
        }
        .frame(width: 150, height: 150, alignment: .bottomLeading)
    }

    private var ruler: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [Color.dinoDialTrack, Color.dinoDialTrack.opacity(0.82)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.dinoGreenShadow.opacity(0.35), lineWidth: 1.5))
                .frame(width: 34, height: rulerHeight)

            VStack(spacing: 0) {
                ForEach(0..<tickCount, id: \.self) { i in
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: i.isMultiple(of: 2) ? 18 : 10, height: 2)
                        Spacer(minLength: 0)
                    }
                    Spacer(minLength: 0)
                }
            }
            .padding(.leading, 5)
            .padding(.vertical, 8)
            .frame(width: 34, height: rulerHeight)
        }
    }
}

#Preview {
    AgeRulerIcon()
        .padding()
}
