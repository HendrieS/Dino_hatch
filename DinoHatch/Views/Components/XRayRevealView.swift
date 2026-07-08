import SwiftUI

/// Reusable "press & hold to x-ray" interaction chrome: backdrop, skeleton
/// cross-fade, cool-tint overlay, sweeping scan line, hint pill, gesture,
/// and haptic. Takes the skin/skeleton content as view builders so the same
/// interaction works with real image assets (`DinoAnatomyView`) or vector
/// placeholder art (debug demo) without duplicating the gesture/animation
/// logic in two places.
struct XRayRevealView<Skin: View, Skeleton: View>: View {
    var size: CGFloat
    let skin: () -> Skin
    let skeleton: () -> Skeleton

    @State private var isHeld = false
    @State private var scanPhase: CGFloat = 0

    init(
        size: CGFloat = 300,
        @ViewBuilder skin: @escaping () -> Skin,
        @ViewBuilder skeleton: @escaping () -> Skeleton
    ) {
        self.size = size
        self.skin = skin
        self.skeleton = skeleton
    }

    var body: some View {
        ZStack {
            // Soft studio backdrop.
            LinearGradient(
                colors: [Color(red: 0.93, green: 0.96, blue: 1.00),
                         Color(red: 0.89, green: 0.94, blue: 0.84)],
                startPoint: .top, endPoint: .bottom
            )

            // Skin — always visible underneath.
            skin()
                .padding(24)

            // Skeleton — fades in while held.
            skeleton()
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
