import SwiftUI
import UIKit

extension Color {
    static let dinoGreen = Color(red: 0.20, green: 0.62, blue: 0.42)
    /// For destructive actions styled as a full primary button (e.g.
    /// Cancel Timer) — a warm coral rather than the harsher system red, to
    /// match dinoGreen's softer illustrated-app tone.
    static let dinoRed = Color(red: 0.85, green: 0.34, blue: 0.32)
    static let dinoCardBackground = Color(uiColor: .secondarySystemBackground)
    /// Gradient stops for `View.dinoWarmBackground()` — a warm cream tone
    /// replacing the plain system white app-wide, in the same tone family
    /// as the egg-hatch art's nest. Approved from a background-only mockup
    /// before touching any view code, first on the Timer screens, then
    /// extended to Alarm/Collection for consistency across the app.
    static let dinoWarmBackgroundTop = Color(red: 0.984, green: 0.969, blue: 0.918)
    static let dinoWarmBackgroundBottom = Color(red: 0.945, green: 0.906, blue: 0.800)
    /// `CircularDurationPicker`'s ring track — `dinoCardBackground` (a
    /// near-white system tone) read as plain white against the warm cream
    /// background, so the track needs its own warmer, visibly darker tan to
    /// stay readable as a ring rather than blending into the background.
    static let dinoDialTrack = Color(red: 0.843, green: 0.776, blue: 0.612)
    /// `CollectionView`'s dinosaur cards (`DinoCardView`/`DinoSilhouetteView`)
    /// — `dinoCardBackground` (an opaque near-white system tone) read as too
    /// bright next to the locked "???" cards, which use this same
    /// semi-transparent black tint and so naturally pick up the warm cream
    /// background showing through underneath. Reused here so unlocked and
    /// locked cards share the exact same tone.
    static let dinoCollectionCardBackground = Color.black.opacity(0.06)
}

extension View {
    /// The warm cream gradient background used behind every main tab
    /// (Timer, Alarm, Collection) in place of the plain system white, with
    /// decorative fern/leaf clusters bleeding off both bottom corners, as
    /// in the approved mockup. Each image gets its own full-size frame
    /// with a corner alignment (rather than relying on the ZStack's own
    /// single alignment) so the two clusters can pin to opposite corners
    /// independently. `allowsHitTesting(false)` since they're purely
    /// decorative and shouldn't intercept taps near either corner.
    func dinoWarmBackground() -> some View {
        background(
            ZStack {
                LinearGradient(
                    colors: [Color.dinoWarmBackgroundTop, Color.dinoWarmBackgroundBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                // .scaledToFit() with no forced height — a fixed-height
                // .fill()+.clipped() was tried first, but hard-cropping the
                // image's own dangling leaf strands mid-shape reads as a
                // literal cut-off edge instead of their natural taper.
                // Capped at a max width (matching the app's existing
                // max-content-width convention, e.g. TimerSetupView) rather
                // than the full device width, so the vine doesn't grow
                // oversized on iPad — the source art is one continuous
                // edge-to-edge banner, not a fixed-size corner cluster like
                // the leaf clusters below.
                Image("vine-top-canopy")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 500)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .allowsHitTesting(false)
                Image("leaf-corner-left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .allowsHitTesting(false)
                Image("leaf-corner-right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    // Nudged further into the corner than plain alignment
                    // allows (alignment alone only gets it flush with the
                    // edge) — bleeds it slightly past the screen bounds to
                    // match the left cluster's tucked-in-the-corner feel.
                    .offset(x: 24, y: 24)
                    .allowsHitTesting(false)
            }
            .ignoresSafeArea()
        )
    }
}
