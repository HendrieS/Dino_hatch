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
                // Three-part canopy (left corner cluster, a tiling middle
                // strip, right corner cluster) rather than one single
                // fixed-aspect-ratio image — a single image stretched to
                // fill iPad's much wider screen either left huge gaps (when
                // width-capped) or grew far too tall (when left uncapped).
                // An HStack naturally solves this: the two corner images
                // keep their own fixed width, and the tiling middle image
                // (`.resizable(resizingMode: .tile)`, which repeats the
                // asset at its native pixel size rather than stretching it)
                // fills exactly whatever width remains between them,
                // however wide that turns out to be.
                HStack(alignment: .top, spacing: 0) {
                    Image("vine-canopy-left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 190)
                    Image("vine-canopy-middle")
                        .resizable(resizingMode: .tile)
                        .frame(maxWidth: .infinity)
                        // Bumped from 58pt to 160pt to match the new,
                        // deeper-hanging middle art (and read closer to the
                        // corner clusters' own ~185-190pt depth) — the
                        // first middle asset's tendrils were noticeably
                        // shorter than the corners', which read as three
                        // mismatched pieces instead of one canopy line.
                        .frame(height: 160)
                    Image("vine-canopy-right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170)
                }
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
