import SwiftUI

/// A pure function of `remainingFraction` and `date` — no animation state of
/// its own, so it stays perfectly in sync with the `TimelineView` tick that
/// drives it in `CountdownView`.
struct EggView: View {
    let remainingFraction: Double
    let date: Date

    private var shakeIntensity: Double {
        let threshold = 0.2
        guard remainingFraction < threshold else { return 0 }
        return 1 - (remainingFraction / threshold)
    }

    private var wobbleAngle: Double {
        guard shakeIntensity > 0 else { return 0 }
        let frequency = 10.0
        let amplitude = 6.0 * shakeIntensity
        return sin(date.timeIntervalSinceReferenceDate * frequency) * amplitude
    }

    private static let speckleOffsets: [CGSize] = [
        CGSize(width: -30, height: -50), CGSize(width: 20, height: -30),
        CGSize(width: -10, height: 10), CGSize(width: 35, height: 30),
        CGSize(width: -35, height: 55), CGSize(width: 5, height: 70)
    ]

    var body: some View {
        EggShape()
            .fill(LinearGradient(colors: [Color(white: 0.98), Color(white: 0.88)], startPoint: .top, endPoint: .bottom))
            .overlay(speckles)
            .overlay(EggShape().stroke(Color.black.opacity(0.08), lineWidth: 2))
            .frame(width: 160, height: 200)
            .rotationEffect(.degrees(wobbleAngle))
    }

    private var speckles: some View {
        ZStack {
            ForEach(Array(Self.speckleOffsets.enumerated()), id: \.offset) { _, offset in
                Circle()
                    .fill(Color.brown.opacity(0.25))
                    .frame(width: 8, height: 8)
                    .offset(offset)
            }
        }
    }
}

struct EggShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        path.move(to: CGPoint(x: width * 0.5, y: 0))
        path.addCurve(
            to: CGPoint(x: width, y: height * 0.62),
            control1: CGPoint(x: width * 0.85, y: 0),
            control2: CGPoint(x: width, y: height * 0.35)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height),
            control1: CGPoint(x: width, y: height * 0.9),
            control2: CGPoint(x: width * 0.78, y: height)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: height * 0.62),
            control1: CGPoint(x: width * 0.22, y: height),
            control2: CGPoint(x: 0, y: height * 0.9)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: 0),
            control1: CGPoint(x: 0, y: height * 0.35),
            control2: CGPoint(x: width * 0.15, y: 0)
        )
        path.closeSubpath()
        return path
    }
}

#Preview {
    EggView(remainingFraction: 0.1, date: .now)
}
