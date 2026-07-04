import SwiftUI

/// Egg-crack-and-hatch sequence built entirely from SwiftUI shapes/animations
/// (no external art or animation libraries): crack overlay -> egg halves
/// split apart -> dinosaur pops in -> confetti burst -> hand off to caller.
struct HatchAnimationView: View {
    let dinosaur: Dinosaur
    var onComplete: () -> Void

    @State private var stage: Stage = .cracking
    @State private var topOffset: CGSize = .zero
    @State private var topRotation: Double = 0
    @State private var bottomOffset: CGSize = .zero
    @State private var dinoScale: CGFloat = 0.1
    @State private var confetti: [ConfettiParticle] = []

    private enum Stage {
        case cracking, bursting, revealed
    }

    var body: some View {
        ZStack {
            ForEach(confetti) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(particle.offset)
                    .opacity(particle.opacity)
            }

            if stage != .revealed {
                ZStack {
                    EggTopHalf()
                        .fill(Color(white: 0.95))
                        .frame(width: 160, height: 100)
                        .offset(y: -50)
                        .offset(topOffset)
                        .rotationEffect(.degrees(topRotation))

                    EggBottomHalf()
                        .fill(Color(white: 0.88))
                        .frame(width: 160, height: 100)
                        .offset(y: 50)
                        .offset(bottomOffset)

                    if stage == .cracking {
                        CrackLines()
                            .stroke(Color.black.opacity(0.4), style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                            .frame(width: 160, height: 200)
                    }
                }
            }

            if stage != .cracking {
                DinoImageView(dinosaur: dinosaur, size: 140)
                    .scaleEffect(dinoScale)
            }
        }
        .frame(height: 260)
        .onAppear(perform: runSequence)
    }

    private func runSequence() {
        confetti = ConfettiParticle.makeBurst(count: 20)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            stage = .bursting
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                topOffset = CGSize(width: -40, height: -140)
                topRotation = -50
                bottomOffset = CGSize(width: 0, height: 30)
                dinoScale = 1.0
            }
            withAnimation(.easeOut(duration: 1.0)) {
                for index in confetti.indices {
                    confetti[index].offset = confetti[index].targetOffset
                    confetti[index].opacity = 0
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            stage = .revealed
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            onComplete()
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    var offset: CGSize
    var targetOffset: CGSize
    var opacity: Double

    static func makeBurst(count: Int) -> [ConfettiParticle] {
        let colors: [Color] = [.dinoGreen, .yellow, .orange, .pink, .blue, .purple]
        return (0..<count).map { _ in
            let angle = Double.random(in: 0..<(2 * .pi))
            let distance = Double.random(in: 60...140)
            let target = CGSize(width: cos(angle) * distance, height: sin(angle) * distance)
            return ConfettiParticle(
                color: colors.randomElement()!,
                size: CGFloat.random(in: 6...12),
                offset: .zero,
                targetOffset: target,
                opacity: 1
            )
        }
    }
}

private struct EggTopHalf: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addCurve(
            to: CGPoint(x: rect.width, y: rect.height),
            control1: CGPoint(x: 0, y: rect.height * 0.1),
            control2: CGPoint(x: rect.width, y: rect.height * 0.1)
        )
        path.closeSubpath()
        return path
    }
}

private struct EggBottomHalf: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addCurve(
            to: CGPoint(x: rect.width, y: 0),
            control1: CGPoint(x: 0, y: rect.height * 0.9),
            control2: CGPoint(x: rect.width, y: rect.height * 0.9)
        )
        path.closeSubpath()
        return path
    }
}

private struct CrackLines: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.3, y: rect.height * 0.35))
        path.addLine(to: CGPoint(x: rect.width * 0.45, y: rect.height * 0.48))
        path.addLine(to: CGPoint(x: rect.width * 0.35, y: rect.height * 0.55))
        path.addLine(to: CGPoint(x: rect.width * 0.55, y: rect.height * 0.68))
        return path
    }
}

#Preview {
    HatchAnimationView(dinosaur: DinosaurCatalog.all[0]) {}
}
