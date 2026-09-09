import SwiftUI
import SwiftData
import UIKit

/// Interactive "press & hold to x-ray" viewer for a dinosaur.
///
/// Shows the skin artwork; while the child presses and holds, the skeleton
/// artwork fades in over it with a cool x-ray tint and a sweeping scan line.
/// Releasing returns to the skin.
///
/// Degrades gracefully — falling back to the standard `DinoImageView` (still
/// the real skin illustration for every current catalog dinosaur, just
/// without the interactive x-ray toggle) — in two cases: the dinosaur is
/// missing its skin/skeleton art, or `XRayEligibility` says the feature
/// isn't unlocked yet — the latter being the common case early on, since
/// x-ray needs 1-2 hatches first (see `XRayEligibility`). Neither case
/// shows any hint that x-ray exists; it just quietly starts working once
/// both are satisfied.
///
/// Requires iOS 17+ for `onChange(of:_:)` (two-parameter form) and
/// `sensoryFeedback`. If you target iOS 16, see the notes in README.md for
/// the two-line downgrade.
struct DinoAnatomyView: View {
    let dinosaur: Dinosaur
    var size: CGFloat = 300

    @Query private var unlocked: [UnlockedDinosaur]
    @Query(sort: \AppSettings.createdAt) private var appSettings: [AppSettings]

    @State private var isHeld = false
    @State private var scanPhase: CGFloat = 0

    /// True only when x-ray is unlocked AND both the skin and skeleton
    /// assets are present in the asset catalog. Anything less falls back
    /// to the emoji/skin placeholder.
    private var hasAnatomy: Bool {
        guard XRayEligibility.isUnlocked(childAge: appSettings.first?.childAge, totalHatched: unlocked.count) else {
            return false
        }
        guard let skin = dinosaur.imageAssetName,
              let skeleton = dinosaur.skeletonAssetName else { return false }
        return UIImage(named: skin) != nil && UIImage(named: skeleton) != nil
    }

    var body: some View {
        Group {
            if hasAnatomy {
                anatomyViewer
            } else {
                DinoImageView(dinosaur: dinosaur, size: size)
            }
        }
    }

    private var anatomyViewer: some View {
        ZStack {
            // Soft studio backdrop (matches the prototype gradient).
            LinearGradient(
                colors: [Color(red: 0.93, green: 0.96, blue: 1.00),
                         Color(red: 0.89, green: 0.94, blue: 0.84)],
                startPoint: .top, endPoint: .bottom
            )

            // Skin — always visible underneath.
            Image(dinosaur.imageAssetName!)
                .resizable()
                .scaledToFit()
                .padding(24)

            // Skeleton — fades in while held.
            Image(dinosaur.skeletonAssetName!)
                .resizable()
                .scaledToFit()
                .padding(24)
                .opacity(isHeld ? 1 : 0)
                .animation(.easeInOut(duration: 0.42), value: isHeld)

            // Cool x-ray tint over the whole scene while held.
            RadialGradient(
                colors: [Color(red: 0.31, green: 0.75, blue: 1.00).opacity(0.12),
                         Color(red: 0.08, green: 0.24, blue: 0.43).opacity(0.30)],
                center: .center, startRadius: 10, endRadius: size * 0.7
            )
            .blendMode(.multiply)
            .opacity(isHeld ? 1 : 0)
            .animation(.easeInOut(duration: 0.42), value: isHeld)
            .allowsHitTesting(false)

            // Sweeping scan line while held.
            if isHeld {
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear,
                                 Color(red: 0.47, green: 0.86, blue: 1.00).opacity(0.55),
                                 Color(red: 0.78, green: 0.96, blue: 1.00).opacity(0.90)],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(height: geo.size.height * 0.26)
                    .blur(radius: 1)
                    .offset(y: -geo.size.height * 0.26 + scanPhase * (geo.size.height * 1.26))
                }
                .allowsHitTesting(false)
                .transition(.opacity)
            }

            // Hint pill, pinned to the bottom.
            VStack {
                Spacer()
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(red: 0.50, green: 0.89, blue: 0.69))
                        .frame(width: 7, height: 7)
                    Text(isHeld ? "Release to see skin" : "Hold to x-ray")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(.black.opacity(0.72), in: Capsule())
                .padding(.bottom, 12)
            }
            .allowsHitTesting(false)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.black.opacity(0.05), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        // Press & hold: touch-down holds, release lets go. minimumDistance 0
        // makes it fire immediately on touch without needing a drag.
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if !isHeld { isHeld = true } }
                .onEnded { _ in isHeld = false }
        )
        // VoiceOver can't perform a press-and-hold drag, so it gets its own
        // element with a double-tap action that toggles the same state a
        // sighted child would get by holding down.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(localizedContent: dinosaur.name))
        .accessibilityValue(isHeld ? Text("Showing x-ray skeleton") : Text("Showing skin"))
        .accessibilityHint(Text("Double tap to toggle x-ray view"))
        .accessibilityAddTraits(.isButton)
        .accessibilityAction {
            isHeld.toggle()
        }
        .onChange(of: isHeld) { _, held in
            if held {
                scanPhase = 0
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: false)) {
                    scanPhase = 1
                }
            } else {
                withAnimation(.default) { scanPhase = 0 }
            }
        }
        // Gentle haptic tap when the x-ray engages (iOS 17+).
        .sensoryFeedback(.impact(weight: .light), trigger: isHeld) { _, held in held }
    }
}

#Preview {
    DinoAnatomyView(dinosaur: DinosaurCatalog.all[0], size: 320)
        .padding()
}
