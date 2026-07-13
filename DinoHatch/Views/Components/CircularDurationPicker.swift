import SwiftUI

/// Clock-face style duration picker: drag anywhere on the dial to set any
/// duration from 0:01 up to 59:59. One full lap of the circle covers the
/// entire range (0:00 at the top, sweeping clockwise up to just under
/// 60:00), same as how an analog clock hand has no "stop" at 12 —
/// dragging past the top wraps around, which is the expected feel for a
/// dial like this rather than a bug to guard against.
struct CircularDurationPicker: View {
    @Binding var totalSeconds: Int
    var diameter: CGFloat = 260

    static let maxSeconds = 3599
    static let snapSeconds = 5
    /// One full lap of the dial = 60 minutes exactly, so a round value like
    /// 5:00 lands precisely on the "5" tick. `maxSeconds` (59:59) is a
    /// separate clamp just short of that, not the angle denominator — using
    /// 3599 for both would leave every tick a hair off from where the
    /// pointer actually sits.
    private static let secondsPerLap = 3600
    private let ringWidth: CGFloat = 18

    private var progress: Double {
        Double(totalSeconds) / Double(Self.secondsPerLap)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.dinoCardBackground, lineWidth: ringWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.dinoGreen, style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

            ForEach(0..<60, id: \.self) { minute in
                if minute % 5 != 0 {
                    // dinoCardBackground (a near-white card-fill tone) was
                    // originally used here and was essentially invisible at
                    // this size — too little contrast against the screen
                    // background for a 4pt dot. .secondary matches the
                    // 5-minute number labels and actually shows up.
                    Circle()
                        .fill(Color.secondary.opacity(0.5))
                        .frame(width: 4, height: 4)
                        .offset(offset(forProgress: Double(minute) / 60, radius: diameter / 2 + ringWidth / 2 + 5))
                }
            }

            ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { minuteMark in
                Text(minuteMark, format: .number)
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                    .offset(offset(forProgress: Double(minuteMark) / 60, radius: diameter / 2 + 16))
            }

            Circle()
                .fill(Color.dinoGreen)
                .frame(width: 28, height: 28)
                .overlay(Circle().stroke(.white, lineWidth: 3))
                .shadow(radius: 1)
                .offset(offset(forProgress: progress, radius: diameter / 2))

            Text(String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
        .frame(width: diameter, height: diameter)
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in updateFromDrag(value.location) }
        )
        .accessibilityElement()
        .accessibilityLabel(Text("Duration"))
        .accessibilityValue(Text(String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                totalSeconds = min(totalSeconds + 30, Self.maxSeconds)
            case .decrement:
                totalSeconds = max(totalSeconds - 30, 0)
            default:
                break
            }
        }
    }

    /// `progress` is 0...1 around the dial, 0 = top, sweeping clockwise.
    /// Computed directly via sin/cos (rather than an `.offset` +
    /// `.rotationEffect` pair) so content stays upright — no ambiguity
    /// about what a chained rotation would do to already-offset content.
    private func offset(forProgress progress: Double, radius: CGFloat) -> CGSize {
        let angle = progress * 2 * .pi
        return CGSize(width: radius * sin(angle), height: -radius * cos(angle))
    }

    private func updateFromDrag(_ location: CGPoint) {
        let center = CGPoint(x: diameter / 2, y: diameter / 2)
        let vector = CGPoint(x: location.x - center.x, y: location.y - center.y)
        var degrees = atan2(vector.y, vector.x) * 180 / .pi + 90
        if degrees < 0 { degrees += 360 }

        let rawSeconds = Int((degrees / 360) * Double(Self.secondsPerLap))
        // Self-qualified: an earlier version referenced `snapSeconds` bare
        // here (unlike `Self.maxSeconds` above) and that failed to compile
        // — always qualify static member references from instance scope.
        let snapped = (rawSeconds / Self.snapSeconds) * Self.snapSeconds
        totalSeconds = min(max(snapped, 0), Self.maxSeconds)
    }
}

#Preview {
    CircularDurationPicker(totalSeconds: .constant(331))
        .padding()
}
