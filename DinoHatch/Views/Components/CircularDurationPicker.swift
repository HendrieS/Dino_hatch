import SwiftUI

/// Clock-face style duration picker: drag anywhere on the dial to set a
/// duration up to 59:59, snapping to the nearest 5-minute stop — 12 stops
/// around the circle, same as the numbers on an analog clock, so it's fast
/// to land on a round time rather than fiddling for exact seconds. One
/// full lap covers the entire range (0 min at the top, sweeping clockwise);
/// dragging past the top wraps around, same as an analog clock hand has no
/// "stop" at 12 — that's the expected feel here, not a bug to guard against.
struct CircularDurationPicker: View {
    @Binding var totalSeconds: Int
    var diameter: CGFloat = 260

    static let maxSeconds = 3599
    static let snapSeconds = 300 // 5 minutes
    private let ringWidth: CGFloat = 18

    private var progress: Double {
        Double(totalSeconds) / Double(Self.maxSeconds)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.dinoCardBackground, lineWidth: ringWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.dinoGreen, style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

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

            VStack(spacing: 0) {
                Text(totalSeconds / 60, format: .number)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text("min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: diameter, height: diameter)
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in updateFromDrag(value.location) }
        )
        .accessibilityElement()
        .accessibilityLabel(Text("Duration"))
        .accessibilityValue(Text(totalSeconds / 60, format: .number) + Text(" ") + Text("min"))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                totalSeconds = min(totalSeconds + snapSeconds, Self.maxSeconds)
            case .decrement:
                totalSeconds = max(totalSeconds - snapSeconds, 0)
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

        let rawSeconds = Int((degrees / 360) * Double(Self.maxSeconds))
        let snapped = (rawSeconds / snapSeconds) * snapSeconds
        totalSeconds = min(max(snapped, 0), Self.maxSeconds)
    }
}

#Preview {
    CircularDurationPicker(totalSeconds: .constant(1500))
        .padding()
}
