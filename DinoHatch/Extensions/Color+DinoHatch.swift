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
                // .scaledToFit(), width-capped at 500 (matching the app's
                // max-content-width convention, e.g. TimerSetupView) so it
                // spans the full device width on iPhone but doesn't grow
                // oversized on iPad, with height following the art's own
                // aspect ratio — no separate height cap, so it reads as a
                // full-width arch rather than a small centered patch. (An
                // earlier attempt capped height too, which looked right in
                // isolation but turned out to be overcorrecting for what
                // was actually a *positioning* bug — see below.) A
                // fixed-height .fill()+.clipped() was tried even earlier
                // and hard-cropped the vine's own dangling leaf strands
                // mid-shape — .scaledToFit() never crops, so the full
                // artwork's natural taper always shows.
                Image("vine-top-canopy")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 500)
                    // maxHeight: .infinity here (matching the leaf corners
                    // below) is what makes `alignment: .top` do anything —
                    // without it this frame's height is just the image's
                    // own content height, leaving no extra space for "top"
                    // to mean anything, so it previously fell back to the
                    // ZStack's own default center alignment and rendered
                    // mid-screen instead of at the top.
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
